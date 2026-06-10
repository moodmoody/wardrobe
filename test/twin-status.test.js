import test from 'node:test';
import assert from 'node:assert/strict';
import { calculateTwinState } from '../src/domain/twin-status.js';

test('marks an item as unbound when it has no identity evidence', () => {
  const result = calculateTwinState({ evidence: [], daysSinceVerified: null, hasSimilarItems: false });

  assert.equal(result.status, 'unbound');
  assert.equal(result.confidence, 0);
});

test('marks an item as mapped when it has photos and recent manual confirmation', () => {
  const result = calculateTwinState({
    evidence: ['main_photo', 'detail_photo', 'detail_photo', 'manual_confirm'],
    daysSinceVerified: 12,
    hasSimilarItems: false,
  });

  assert.equal(result.status, 'mapped');
  assert.equal(result.confidence, 70);
});

test('marks an item as anchored when it has a physical anchor', () => {
  const result = calculateTwinState({
    evidence: ['main_photo', 'manual_confirm', 'nfc_scan'],
    daysSinceVerified: 3,
    hasSimilarItems: false,
  });

  assert.equal(result.status, 'anchored');
  assert.equal(result.confidence, 90);
});

test('downgrades stale similar items to review', () => {
  const result = calculateTwinState({
    evidence: ['main_photo', 'detail_photo', 'manual_confirm'],
    daysSinceVerified: 121,
    hasSimilarItems: true,
  });

  assert.equal(result.status, 'review');
  assert.equal(result.confidence, 35);
});

test('marks missing location evidence as missing even when identity is strong', () => {
  const result = calculateTwinState({
    evidence: ['main_photo', 'manual_confirm', 'qr_scan'],
    daysSinceVerified: 10,
    hasSimilarItems: false,
    locationState: 'missing',
  });

  assert.equal(result.status, 'missing');
  assert.equal(result.confidence, 40);
});