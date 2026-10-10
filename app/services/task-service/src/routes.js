import { Router } from 'express';
import { v4 as uuidv4 } from 'uuid';
import client from 'prom-client';
import {
  getAllTasks,
  getTaskById,
  createTask,
  updateTask,
  deleteTask,
  isDbReady
} from './db.js';

export const router = Router();

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:3001';
const NOTIFICATION_SERVICE_URL = process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3003';

// Prometheus Metrics Registry
const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: 'task_service_' });

const httpRequestsTotal = new client.Counter({
  name: 'task_service_http_requests_total',
  help: 'Total HTTP requests handled by task-service',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const tasksCreatedTotal = new client.Counter({
  name: 'task_service_tasks_created_total',
  help: 'Total tasks created in the system',
  registers: [register],
});

const tasksCompletedTotal = new client.Counter({
  name: 'task_service_tasks_completed_total',
  help: 'Total tasks marked as DONE',
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

// Helper: dispatch notification (fire-and-forget or async log)
async function sendNotification(eventType, task, message) {
  try {
    const payload = {
      eventType,
      taskId: task.id,
      taskTitle: task.title,
      userId: task.user_id,
      message,
      timestamp: new Date().toISOString()
    };
    
    // Non-blocking fetch
    fetch(`${NOTIFICATION_SERVICE_URL}/api/notifications`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    }).catch(err => {
      console.warn(`[Task Service] Async notification dispatch failed: ${err.message}`);
    });
  } catch (err) {
    console.warn(`[Task Service] Failed to send notification: ${err.message}`);
  }
}

// Root Info Endpoint
router.get('/', (req, res) => {
  res.status(200).json({
    service: 'task-service',
    status: 'healthy',
    version: '1.0.0',
    endpoints: {
      health: '/healthz',
      readiness: '/readyz',
      metrics: '/metrics',
      tasks: '/api/tasks'
    }
  });
});

// 1. Kubernetes Probes
router.get('/healthz', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'task-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

router.get('/readyz', async (req, res) => {
  const ready = await isDbReady();
  if (ready) {
    res.status(200).json({
      status: 'ready',
      service: 'task-service',
      db: 'connected'
    });
  } else {
    res.status(503).json({
      status: 'not_ready',
      service: 'task-service',
      db: 'disconnected'
    });
  }
});

// 2. Metrics Endpoint
router.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

// 3. Task Endpoints (supports both /api/tasks and /tasks)
router.get(['/api/tasks', '/tasks'], async (req, res) => {
  try {
    const { userId, status } = req.query;
    const tasks = await getAllTasks({ userId, status });
    res.json({ success: true, count: tasks.length, data: tasks });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.get(['/api/tasks/:id', '/tasks/:id'], async (req, res) => {
  try {
    const task = await getTaskById(req.params.id);
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }
    res.json({ success: true, data: task });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post(['/api/tasks', '/tasks'], async (req, res) => {
  try {
    const { title, description, status, priority, userId } = req.body;
    if (!title || !userId) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed: "title" and "userId" are required'
      });
    }

    // Verify user exists in User Service (inter-service check)
    let userName = 'User';
    try {
      const userRes = await fetch(`${USER_SERVICE_URL}/api/users/${userId}`, { signal: AbortSignal.timeout(3000) });
      if (userRes.ok) {
        const userData = await userRes.json();
        userName = userData.data?.name || 'User';
      }
    } catch (err) {
      console.warn(`[Task Service] User validation call to ${USER_SERVICE_URL} skipped or timed out: ${err.message}`);
    }

    const id = `tsk-${uuidv4().substring(0, 8)}`;
    const task = await createTask({ id, title, description, status, priority, userId });
    tasksCreatedTotal.inc();

    // Trigger notification
    sendNotification('TASK_CREATED', task, `New task "${task.title}" assigned to ${userName}`);

    res.status(201).json({ success: true, data: task });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.put(['/api/tasks/:id', '/tasks/:id'], async (req, res) => {
  try {
    const { title, description, status, priority } = req.body;
    const updated = await updateTask(req.params.id, { title, description, status, priority });
    if (!updated) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }

    if (status === 'DONE') {
      tasksCompletedTotal.inc();
      sendNotification('TASK_COMPLETED', updated, `Task "${updated.title}" was marked as DONE`);
    } else if (status) {
      sendNotification('TASK_UPDATED', updated, `Task "${updated.title}" status changed to ${status}`);
    }

    res.json({ success: true, data: updated });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.delete(['/api/tasks/:id', '/tasks/:id'], async (req, res) => {
  try {
    const deleted = await deleteTask(req.params.id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }
    res.json({ success: true, message: `Task ${req.params.id} deleted` });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
