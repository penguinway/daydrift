const express = require('express');
const cors = require('cors');
const { WebSocketServer } = require('ws');
const http = require('http');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

// 配对关系（服务器端配置，两个用户互为对方）
// 可以改成从文件/数据库读取
const PAIRS = {
  // userId -> partnerId，双向配置
  // 示例：'alice': 'bob', 'bob': 'alice'
};

// 运行时数据
const statuses = new Map();    // userId -> { packageName, appName, updatedAt }
const wsClients = new Map();   // userId -> Set<WebSocket>

// === HTTP API ===

// 登录（验证身份 + 返回配对信息）
app.post('/api/login', (req, res) => {
  const { userId } = req.body;
  if (!userId) return res.status(400).json({ error: 'userId required' });

  const partnerId = PAIRS[userId];
  if (!partnerId) {
    return res.status(403).json({ error: 'user not registered or not paired' });
  }

  // 返回对方当前状态（如果有）
  const partnerStatus = statuses.get(partnerId) || null;
  res.json({ userId, partnerId, partnerStatus });
});

// 注册配对关系（管理接口）
app.post('/api/admin/pair', (req, res) => {
  const { user1, user2 } = req.body;
  if (!user1 || !user2) return res.status(400).json({ error: 'user1 and user2 required' });

  PAIRS[user1] = user2;
  PAIRS[user2] = user1;
  res.json({ ok: true, pair: [user1, user2] });
});

// 查看所有配对
app.get('/api/admin/pairs', (req, res) => {
  const seen = new Set();
  const pairs = [];
  for (const [u1, u2] of Object.entries(PAIRS)) {
    const key = [u1, u2].sort().join(':');
    if (!seen.has(key)) {
      seen.add(key);
      pairs.push([u1, u2]);
    }
  }
  res.json({ pairs });
});

// 更新状态
app.post('/api/status/update', (req, res) => {
  const { userId, packageName, appName, updatedAt } = req.body;
  if (!userId || !packageName) return res.status(400).json({ error: 'userId and packageName required' });

  const statusData = { userId, packageName, appName: appName || packageName, updatedAt: updatedAt || new Date().toISOString() };
  statuses.set(userId, statusData);

  // 推送给对方
  const partnerId = PAIRS[userId];
  if (partnerId) {
    _notifyUser(partnerId, { type: 'status_update', data: statusData });
  }

  res.json({ ok: true });
});

// 获取对方状态
app.get('/api/status/:userId', (req, res) => {
  const status = statuses.get(req.params.userId);
  if (!status) return res.status(404).json(null);
  res.json(status);
});

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    connections: wsClients.size,
    pairs: Object.keys(PAIRS).length / 2,
    uptime: process.uptime(),
  });
});

// === WebSocket ===

wss.on('connection', (ws, req) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const userId = url.searchParams.get('userId');

  if (!userId) {
    ws.close(4001, 'userId required');
    return;
  }

  if (!PAIRS[userId]) {
    ws.close(4003, 'user not registered');
    return;
  }

  // 注册连接
  if (!wsClients.has(userId)) {
    wsClients.set(userId, new Set());
  }
  wsClients.get(userId).add(ws);

  console.log(`[WS] ${userId} connected (${wsClients.get(userId).size} conns)`);

  // 连接后推送对方当前状态
  const partnerId = PAIRS[userId];
  if (partnerId) {
    const partnerStatus = statuses.get(partnerId);
    if (partnerStatus) {
      ws.send(JSON.stringify({ type: 'status_update', data: partnerStatus }));
    }
  }

  ws.on('close', () => {
    const clients = wsClients.get(userId);
    if (clients) {
      clients.delete(ws);
      if (clients.size === 0) wsClients.delete(userId);
    }
    console.log(`[WS] ${userId} disconnected`);
  });

  ws.on('error', () => {
    const clients = wsClients.get(userId);
    if (clients) {
      clients.delete(ws);
      if (clients.size === 0) wsClients.delete(userId);
    }
  });
});

function _notifyUser(userId, message) {
  const clients = wsClients.get(userId);
  if (!clients) return;
  const payload = JSON.stringify(message);
  for (const ws of clients) {
    if (ws.readyState === 1) {
      ws.send(payload);
    }
  }
}

// === 启动 ===

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Love Time server running on port ${PORT}`);
  console.log(`   HTTP: http://0.0.0.0:${PORT}`);
  console.log(`   WS:   ws://0.0.0.0:${PORT}/ws`);
  console.log('');
  console.log('📋 先注册配对关系:');
  console.log(`   curl -X POST http://localhost:${PORT}/api/admin/pair -H "Content-Type: application/json" -d '{"user1":"alice","user2":"bob"}'`);
});
