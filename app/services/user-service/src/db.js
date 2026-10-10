import pg from 'pg';

const { Pool } = pg;

const DB_HOST = process.env.DB_HOST;
const DB_PORT = parseInt(process.env.DB_PORT || '5432', 10);
const DB_NAME = process.env.DB_NAME || 'taskapp_user';
const DB_USER = process.env.DB_USER || 'postgres';
const DB_PASSWORD = process.env.DB_PASSWORD || 'postgres';

let pool = null;
let useMemoryStore = false;
const inMemoryUsers = new Map();

export async function initDb() {
  if (!DB_HOST) {
    console.log('[User Service] No DB_HOST provided. Using in-memory storage.');
    useMemoryStore = true;
    seedDefaultUsers();
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
    console.log(`[User Service] Connected to PostgreSQL at ${DB_HOST}:${DB_PORT}/${DB_NAME}`);

    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(64) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(150) UNIQUE NOT NULL,
        role VARCHAR(50) DEFAULT 'developer',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);
    client.release();
    console.log('[User Service] Database tables initialized.');
  } catch (err) {
    console.warn(`[User Service] PostgreSQL connection failed (${err.message}). Falling back to in-memory storage.`);
    useMemoryStore = true;
    seedDefaultUsers();
  }
}

function seedDefaultUsers() {
  if (inMemoryUsers.size === 0) {
    inMemoryUsers.set('usr-1', {
      id: 'usr-1',
      name: 'Alice DevOps',
      email: 'alice@company.internal',
      role: 'Platform Engineer',
      created_at: new Date().toISOString()
    });
    inMemoryUsers.set('usr-2', {
      id: 'usr-2',
      name: 'Bob SRE',
      email: 'bob@company.internal',
      role: 'Site Reliability Engineer',
      created_at: new Date().toISOString()
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

export async function getAllUsers() {
  if (useMemoryStore) {
    return Array.from(inMemoryUsers.values());
  }
  const { rows } = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
  return rows;
}

export async function getUserById(id) {
  if (useMemoryStore) {
    return inMemoryUsers.get(id) || null;
  }
  const { rows } = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
  return rows[0] || null;
}

export async function getUserByEmail(email) {
  if (useMemoryStore) {
    return Array.from(inMemoryUsers.values()).find(u => u.email === email) || null;
  }
  const { rows } = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
  return rows[0] || null;
}

export async function createUser({ id, name, email, role }) {
  if (useMemoryStore) {
    const user = {
      id,
      name,
      email,
      role: role || 'developer',
      created_at: new Date().toISOString()
    };
    inMemoryUsers.set(id, user);
    return user;
  }
  const { rows } = await pool.query(
    'INSERT INTO users (id, name, email, role) VALUES ($1, $2, $3, $4) RETURNING *',
    [id, name, email, role || 'developer']
  );
  return rows[0];
}
