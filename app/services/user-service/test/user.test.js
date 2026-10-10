import test from 'node:test';
import assert from 'node:assert/strict';
import { getAllUsers, getUserById, createUser, initDb } from '../src/db.js';

test('User Service DB Operations (In-Memory Fallback)', async (t) => {
  await initDb();

  await t.test('seeds initial users', async () => {
    const users = await getAllUsers();
    assert.ok(users.length >= 2, 'Should have at least 2 seeded users');
  });

  await t.test('can create a new user', async () => {
    const newUser = await createUser({
      id: 'usr-test-1',
      name: 'Test Engineer',
      email: 'test@devops.internal',
      role: 'QA Engineer'
    });
    assert.equal(newUser.id, 'usr-test-1');
    assert.equal(newUser.name, 'Test Engineer');

    const fetched = await getUserById('usr-test-1');
    assert.ok(fetched);
    assert.equal(fetched.email, 'test@devops.internal');
  });
});
