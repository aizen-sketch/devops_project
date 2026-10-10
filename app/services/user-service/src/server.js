import express from 'express';
import { router, metricsMiddleware } from './routes.js';
import { initDb } from './db.js';

const app = express();
const PORT = parseInt(process.env.PORT || '3001', 10);

app.use(express.json());

// Structured JSON request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      service: 'user-service',
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      durationMs: duration
    }));
  });
  next();
});

app.use(metricsMiddleware);
app.use(router);

// Graceful startup
async function startServer() {
  await initDb();
  
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`[User Service] Listening on port ${PORT}`);
  });

  // Graceful shutdown for Kubernetes SIGTERM / SIGINT
  const shutdown = (signal) => {
    console.log(`[User Service] Received ${signal}. Gracefully shutting down...`);
    server.close(() => {
      console.log('[User Service] HTTP server closed. Exiting process.');
      process.exit(0);
    });
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

startServer().catch((err) => {
  console.error('[User Service] Fatal startup error:', err);
  process.exit(1);
});
