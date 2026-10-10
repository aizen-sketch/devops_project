import { Router } from 'express';
import { v4 as uuidv4 } from 'uuid';
import client from 'prom-client';

export const router = Router();

// In-memory circular log of recent notifications
const recentNotifications = [];
const MAX_NOTIFICATIONS = 50;

// Prometheus Metrics Registry
const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: 'notification_service_' });

const httpRequestsTotal = new client.Counter({
  name: 'notification_service_http_requests_total',
  help: 'Total HTTP requests handled by notification-service',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const notificationsDispatchedTotal = new client.Counter({
  name: 'notification_service_dispatched_total',
  help: 'Total notifications processed and dispatched',
  labelNames: ['event_type', 'channel'],
  registers: [register],
});

export function metricsMiddleware(req, res, next) {
  res.on('finish', () => {
    const route = req.route ? req.route.path : req.path;
    httpRequestsTotal.inc({
      method: req.method,
      route,
      status_code: res.statusCode
    });
  });
  next();
}

// Root Info Endpoint
router.get('/', (req, res) => {
  res.status(200).json({
    service: 'notification-service',
    status: 'healthy',
    version: '1.0.0',
    endpoints: {
      health: '/healthz',
      readiness: '/readyz',
      metrics: '/metrics',
      notifications: '/api/notifications'
    }
  });
});

// 1. Kubernetes Probes
router.get('/healthz', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'notification-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

router.get('/readyz', (req, res) => {
  res.status(200).json({
    status: 'ready',
    service: 'notification-service'
  });
});

// 2. Metrics Endpoint
router.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

// 3. Notification Endpoints (supports both /api/notifications and /notifications)
router.get(['/api/notifications', '/notifications'], (req, res) => {
  res.json({
    success: true,
    count: recentNotifications.length,
    data: recentNotifications
  });
});

router.post(['/api/notifications', '/notifications'], (req, res) => {
  const { eventType, taskId, taskTitle, userId, message } = req.body;

  if (!eventType || !message) {
    return res.status(400).json({
      success: false,
      error: 'Validation failed: "eventType" and "message" are required'
    });
  }

  const notification = {
    id: `notif-${uuidv4().substring(0, 8)}`,
    eventType,
    taskId: taskId || null,
    taskTitle: taskTitle || null,
    userId: userId || null,
    message,
    channel: process.env.NOTIFICATION_CHANNEL || 'EMAIL_SIMULATOR',
    dispatchedAt: new Date().toISOString()
  };

  // Keep recent notifications in circular buffer
  recentNotifications.unshift(notification);
  if (recentNotifications.length > MAX_NOTIFICATIONS) {
    recentNotifications.pop();
  }

  // Increment Prometheus counter
  notificationsDispatchedTotal.inc({
    event_type: eventType,
    channel: notification.channel
  });

  // Simulated Alert / Email Dispatch Output
  console.log(`[Notification Service] [DISPATCH] [${notification.channel}] Event=${eventType} Task=${taskTitle || taskId} Msg="${message}"`);

  res.status(201).json({
    success: true,
    data: notification
  });
});
