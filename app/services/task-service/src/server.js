import express from 'express';
import { router, metricsMiddleware } from './routes.js';
import { initDb } from './db.js';

const app = express();
const PORT = parseInt(process.env.PORT || '3002', 10);

app.use(express.json());

// Structured JSON request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      service: 'task-service',
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

// Graceful startup & shutdown
async function startServer() {
  await initDb();
  
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`[Task Service] Listening on port ${PORT}`);
  });

  const shutdown = (signal) => {
    console.log(`[Task Service] Received ${signal}. Gracefully shutting down...`);
    server.close(() => {
      console.log('[Task Service] HTTP server closed. Exiting process.');
      process.exit(0);
    });
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

startServer().catch((err) => {
  console.error('[Task Service] Fatal startup error:', err);
  process.exit(1);
});
