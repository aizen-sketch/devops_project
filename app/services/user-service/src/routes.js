import { Router } from 'express';
import { v4 as uuidv4 } from 'uuid';
import client from 'prom-client';
import {
  getAllUsers,
  getUserById,
  getUserByEmail,
  createUser,
  isDbReady
} from './db.js';

export const router = Router();

// Prometheus Metrics Registry
const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: 'user_service_' });

const httpRequestsTotal = new client.Counter({
  name: 'user_service_http_requests_total',
  help: 'Total number of HTTP requests handled by user-service',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

// Middleware to track metrics
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
    service: 'user-service',
    status: 'healthy',
    version: '1.0.0',
    endpoints: {
      health: '/healthz',
      readiness: '/readyz',
      metrics: '/metrics',
      users: '/api/users'
    }
  });
});

// 1. Kubernetes Probes
router.get('/healthz', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'user-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

router.get('/readyz', async (req, res) => {
  const ready = await isDbReady();
  if (ready) {
    res.status(200).json({
      status: 'ready',
      service: 'user-service',
      db: 'connected'
    });
  } else {
    res.status(503).json({
      status: 'not_ready',
      service: 'user-service',
      db: 'disconnected'
    });
  }
});

// 2. Prometheus Endpoint
router.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

// 3. User APIs (supports both /api/users and /users)
router.get(['/api/users', '/users'], async (req, res) => {
  try {
    const users = await getAllUsers();
    res.json({ success: true, count: users.length, data: users });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.get(['/api/users/:id', '/users/:id'], async (req, res) => {
  try {
    const user = await getUserById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post(['/api/users', '/users'], async (req, res) => {
  try {
    const { name, email, role } = req.body;
    if (!name || !email) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed: "name" and "email" are required fields'
      });
    }

    const existing = await getUserByEmail(email);
    if (existing) {
      return res.status(409).json({
        success: false,
        error: `User with email ${email} already exists`
      });
    }

    const id = `usr-${uuidv4().substring(0, 8)}`;
    const user = await createUser({ id, name, email, role });
    res.status(201).json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
