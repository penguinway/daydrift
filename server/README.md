# Love Time 实时状态同步服务端

轻量级 Node.js 服务器，为「TA在干嘛」功能提供实时状态同步。

## 快速启动

```bash
cd server
npm install
npm start
```

服务器默认运行在 `http://0.0.0.0:3000`。

## 配对管理

服务端通过 `PAIRS` 映射管理用户关系。**需要管理员先登记**：

```bash
# 把 alice 和 bob 配成一对
curl -X POST http://localhost:3000/api/admin/pair \
  -H "Content-Type: application/json" \
  -d '{"user1":"alice","user2":"bob"}'

# 查看所有配对
curl http://localhost:3000/api/admin/pairs
```

## API 接口

### 健康检查
```
GET /api/health
```

### 登录（验证身份）
```
POST /api/login
Body: { "userId": "alice" }
Response: { "userId": "alice", "partnerId": "bob", "partnerStatus": {...} }
```

### 更新状态（前台 App）
```
POST /api/status/update
Body: { "userId": "alice", "packageName": "com.tencent.mm", "appName": "微信", "updatedAt": "ISO" }
Response: { "ok": true }
```

### 获取指定用户状态
```
GET /api/status/:userId
Response: { "userId": "...", "packageName": "...", ... }
```

## WebSocket 实时推送

连接：`ws://server:3000/ws?userId=your-id`

收到的消息格式：
```json
{ "type": "status_update", "data": { "userId": "bob", "packageName": "...", "appName": "...", "updatedAt": "..." } }
```

## 部署建议

- 数据默认存在内存中（重启会丢失）
- 生产环境建议加 Redis 或 SQLite 持久化
- 建议用 PM2 或 systemd 管理进程
- 如需 HTTPS，建议前置 Nginx 反向代理
- `PAIRS` 当前在代码里硬编码，可以改为读配置文件或数据库

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| PORT | 3000 | 监听端口 |
