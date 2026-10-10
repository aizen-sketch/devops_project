import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:3001';
const TASK_SERVICE_URL = process.env.TASK_SERVICE_URL || 'http://localhost:3002';
const NOTIFICATION_SERVICE_URL = process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3003';

// Liveness probe
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'healthy', service: 'frontend', uptime: process.uptime() });
});

// Health overview of downstream microservices
app.get('/api/health-overview', async (req, res) => {
  const checkService = async (name, url) => {
    try {
      const resp = await fetch(`${url}/healthz`, { signal: AbortSignal.timeout(2000) });
      const data = await resp.json();
      return { name, status: resp.ok ? 'UP' : 'DOWN', data };
    } catch (err) {
      return { name, status: 'DOWN', error: err.message };
    }
  };

  const [userService, taskService, notifService] = await Promise.all([
    checkService('User Service', USER_SERVICE_URL),
    checkService('Task Service', TASK_SERVICE_URL),
    checkService('Notification Service', NOTIFICATION_SERVICE_URL)
  ]);

  res.json({
    gateway: { status: 'UP' },
    services: [userService, taskService, notifService]
  });
});

// Microservice API Proxies
app.use(
  '/api/users',
  createProxyMiddleware({
    target: USER_SERVICE_URL,
    changeOrigin: true,
    pathRewrite: (path, req) => req.originalUrl
  })
);

app.use(
  '/api/tasks',
  createProxyMiddleware({
    target: TASK_SERVICE_URL,
    changeOrigin: true,
    pathRewrite: (path, req) => req.originalUrl
  })
);

app.use(
  '/api/notifications',
  createProxyMiddleware({
    target: NOTIFICATION_SERVICE_URL,
    changeOrigin: true,
    pathRewrite: (path, req) => req.originalUrl
  })
);

// Serve static frontend assets
app.use(express.static(path.join(__dirname, 'public')));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`[Frontend Gateway] Listening on port ${PORT}`);
  console.log(`[Frontend Gateway] Routing /api/users -> ${USER_SERVICE_URL}`);
  console.log(`[Frontend Gateway] Routing /api/tasks -> ${TASK_SERVICE_URL}`);
  console.log(`[Frontend Gateway] Routing /api/notifications -> ${NOTIFICATION_SERVICE_URL}`);
});

process.on('SIGTERM', () => {
  console.log('[Frontend Gateway] SIGTERM received. Shutting down gracefully.');
  server.close(() => process.exit(0));
});
