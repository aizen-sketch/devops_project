import test from 'node:test';
import assert from 'node:assert/strict';
import { getAllTasks, createTask, updateTask, deleteTask, initDb } from '../src/db.js';

test('Task Service DB Operations (In-Memory Fallback)', async (t) => {
  await initDb();

  await t.test('can retrieve initial tasks', async () => {
    const tasks = await getAllTasks();
    assert.ok(tasks.length >= 2, 'Should have initial tasks');
  });

  await t.test('can create a task', async () => {
    const task = await createTask({
      id: 'tsk-test-1',
      title: 'Automate CI with GitHub Actions',
      description: 'Setup build and Trivy scan',
      status: 'TODO',
      priority: 'HIGH',
      userId: 'usr-1'
    });
    assert.equal(task.id, 'tsk-test-1');
    assert.equal(task.status, 'TODO');
  });

  await t.test('can update a task to DONE', async () => {
    const updated = await updateTask('tsk-test-1', { status: 'DONE' });
    assert.equal(updated.status, 'DONE');
  });

  await t.test('can delete a task', async () => {
    const deleted = await deleteTask('tsk-test-1');
    assert.equal(deleted, true);
  });
});
