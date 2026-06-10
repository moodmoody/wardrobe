import test from 'node:test';
import assert from 'node:assert/strict';
import { moveItemToTop, moveItemToPosition } from '../src/domain/storage-stack.js';

test('moves a worn item back to the top of a stack', () => {
  const stack = ['grey-hoodie', 'beige-knit', 'white-shirt', 'blue-shirt'];

  const result = moveItemToTop(stack, 'white-shirt');

  assert.deepEqual(result, ['white-shirt', 'grey-hoodie', 'beige-knit', 'blue-shirt']);
});

test('keeps stack unchanged when moving an unknown item to top', () => {
  const stack = ['grey-hoodie', 'beige-knit'];

  const result = moveItemToTop(stack, 'missing-item');

  assert.deepEqual(result, ['grey-hoodie', 'beige-knit']);
});

test('moves an item to a one-based position inside the stack', () => {
  const stack = ['grey-hoodie', 'beige-knit', 'white-shirt', 'blue-shirt'];

  const result = moveItemToPosition(stack, 'blue-shirt', 2);

  assert.deepEqual(result, ['grey-hoodie', 'blue-shirt', 'beige-knit', 'white-shirt']);
});