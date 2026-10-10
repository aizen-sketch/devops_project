import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

test('Frontend UI Static Files Verification', async (t) => {
  await t.test('index.html exists and contains dashboard markup', () => {
    const indexPath = path.join(__dirname, '../public/index.html');
    assert.ok(fs.existsSync(indexPath), 'public/index.html must exist');
    const content = fs.readFileSync(indexPath, 'utf-8');
    assert.ok(content.includes('CloudOps Tasks'), 'Dashboard title must be present');
    assert.ok(content.includes('Task Management Board'), 'Kanban board markup must be present');
  });
});
