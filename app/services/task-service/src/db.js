import pg from 'pg';

const { Pool } = pg;

const DB_HOST = process.env.DB_HOST;
const DB_PORT = parseInt(process.env.DB_PORT || '5432', 10);
const DB_NAME = process.env.DB_NAME || 'taskapp_task';
const DB_USER = process.env.DB_USER || 'postgres';
const DB_PASSWORD = process.env.DB_PASSWORD || 'postgres';

let pool = null;
let useMemoryStore = false;
const inMemoryTasks = new Map();

export async function initDb() {
  if (!DB_HOST) {
    console.log('[Task Service] No DB_HOST provided. Using in-memory storage.');
    useMemoryStore = true;
    seedDefaultTasks();
    return;
  }

  try {
    pool = new Pool({
      host: DB_HOST,
      port: DB_PORT,
      database: DB_NAME,
      user: DB_USER,
      password: DB_PASSWORD,
      connectionTimeoutMillis: 5000,
    });

    const client = await pool.connect();
    console.log(`[Task Service] Connected to PostgreSQL at ${DB_HOST}:${DB_PORT}/${DB_NAME}`);

    await client.query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id VARCHAR(64) PRIMARY KEY,
        title VARCHAR(200) NOT NULL,
        description TEXT,
        status VARCHAR(30) DEFAULT 'TODO',
        priority VARCHAR(20) DEFAULT 'MEDIUM',
        user_id VARCHAR(64) NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);
    client.release();
    console.log('[Task Service] Database tables initialized.');
  } catch (err) {
    console.warn(`[Task Service] PostgreSQL connection failed (${err.message}). Falling back to in-memory storage.`);
    useMemoryStore = true;
    seedDefaultTasks();
  }
}

function seedDefaultTasks() {
  if (inMemoryTasks.size === 0) {
    inMemoryTasks.set('tsk-1', {
      id: 'tsk-1',
      title: 'Setup EKS Cluster via Terraform',
      description: 'Provision multi-AZ VPC, managed node groups, and KMS secrets encryption',
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      user_id: 'usr-1',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });
    inMemoryTasks.set('tsk-2', {
      id: 'tsk-2',
      title: 'Configure Argo CD GitOps Application',
      description: 'Bootstrap root App-of-Apps repository and deploy Helm charts',
      status: 'TODO',
      priority: 'HIGH',
      user_id: 'usr-2',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });
  }
}

export async function isDbReady() {
  if (useMemoryStore) return true;
  if (!pool) return false;
  try {
    const res = await pool.query('SELECT 1');
    return res.rowCount === 1;
  } catch {
    return false;
  }
}

export async function getAllTasks(filters = {}) {
  if (useMemoryStore) {
    let tasks = Array.from(inMemoryTasks.values());
    if (filters.userId) {
      tasks = tasks.filter(t => t.user_id === filters.userId);
    }
    if (filters.status) {
      tasks = tasks.filter(t => t.status.toLowerCase() === filters.status.toLowerCase());
    }
    return tasks;
  }

  let query = 'SELECT * FROM tasks WHERE 1=1';
  const params = [];
  if (filters.userId) {
    params.push(filters.userId);
    query += ` AND user_id = $${params.length}`;
  }
  if (filters.status) {
    params.push(filters.status);
    query += ` AND status = $${params.length}`;
  }
  query += ' ORDER BY created_at DESC';

  const { rows } = await pool.query(query, params);
  return rows;
}

export async function getTaskById(id) {
  if (useMemoryStore) {
    return inMemoryTasks.get(id) || null;
  }
  const { rows } = await pool.query('SELECT * FROM tasks WHERE id = $1', [id]);
  return rows[0] || null;
}

export async function createTask({ id, title, description, status, priority, userId }) {
  const now = new Date().toISOString();
  if (useMemoryStore) {
    const task = {
      id,
      title,
      description: description || '',
      status: status || 'TODO',
      priority: priority || 'MEDIUM',
      user_id: userId,
      created_at: now,
      updated_at: now
    };
    inMemoryTasks.set(id, task);
    return task;
  }

  const { rows } = await pool.query(
    `INSERT INTO tasks (id, title, description, status, priority, user_id, created_at, updated_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
    [id, title, description || '', status || 'TODO', priority || 'MEDIUM', userId, now, now]
  );
  return rows[0];
}

export async function updateTask(id, fields) {
  const now = new Date().toISOString();
  if (useMemoryStore) {
    const existing = inMemoryTasks.get(id);
    if (!existing) return null;
    const updated = {
      ...existing,
      ...fields,
      updated_at: now
    };
    inMemoryTasks.set(id, updated);
    return updated;
  }

  const current = await getTaskById(id);
  if (!current) return null;

  const newTitle = fields.title !== undefined ? fields.title : current.title;
  const newDesc = fields.description !== undefined ? fields.description : current.description;
  const newStatus = fields.status !== undefined ? fields.status : current.status;
  const newPriority = fields.priority !== undefined ? fields.priority : current.priority;

  const { rows } = await pool.query(
    `UPDATE tasks SET title = $1, description = $2, status = $3, priority = $4, updated_at = $5
     WHERE id = $6 RETURNING *`,
    [newTitle, newDesc, newStatus, newPriority, now, id]
  );
  return rows[0];
}

export async function deleteTask(id) {
  if (useMemoryStore) {
    const deleted = inMemoryTasks.delete(id);
    return deleted;
  }
  const { rowCount } = await pool.query('DELETE FROM tasks WHERE id = $1', [id]);
  return rowCount > 0;
}
