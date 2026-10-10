import express from 'express';
import { router, metricsMiddleware } from './routes.js';

const app = express();
const PORT = parseInt(process.env.PORT || '3003', 10);

app.use(express.json());

// Structured JSON request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      service: 'notification-service',
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

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`[Notification Service] Listening on port ${PORT}`);
});

const shutdown = (signal) => {
  console.log(`[Notification Service] Received ${signal}. Gracefully shutting down...`);
  server.close(() => {
    console.log('[Notification Service] HTTP server closed. Exiting process.');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
