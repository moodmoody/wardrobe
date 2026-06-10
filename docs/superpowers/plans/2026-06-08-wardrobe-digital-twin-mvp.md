# Wardrobe Digital Twin MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Phase 1 of the wardrobe digital twin as a platform-neutral domain foundation: item identity, wardrobe space modeling, stack ordering, twin confidence, and SQLite schema tests.

**Architecture:** Start with a small Node.js domain kernel because this machine currently does not have Flutter or Dart installed. The domain model is intentionally framework-neutral so it can later be ported into Flutter/Drift with the same entities, rules, and test cases.

**Tech Stack:** Node.js built-in test runner (`node --test`), plain JavaScript ES modules, SQLite-compatible schema SQL, Markdown docs.

---

## Current Context

The workspace currently contains design artifacts only:

- `wardrobe-app-design.pptx`
- `wardrobe-digital-twin-design.md`
- `wardrobe-digital-twin-optimized.pptx`

Flutter and Dart are not available on PATH in the current environment:

```powershell
flutter --version
# Expected today: command not found

dart --version
# Expected today: command not found
```

Because of that, this plan starts with a testable domain foundation. Flutter scaffolding becomes Phase 2 after installing Flutter.

---

## File Structure

Create these files:

- `package.json`：declares ESM and test command using Node built-in tests.
- `src/domain/twin-status.js`：calculates `twin_status` and `twin_confidence` from evidence and location signals.
- `src/domain/location-address.js`：formats and parses wardrobe semantic addresses like `W01-Z01-C01-G02-I03`.
- `src/domain/storage-stack.js`：updates stack order when an item is placed back on top or moved inside a stack.
- `src/db/schema.sql`：SQLite-compatible schema for item identity, wardrobe spaces, storage groups, anchors, and events.
- `test/twin-status.test.js`：tests twin status and confidence rules.
- `test/location-address.test.js`：tests address formatting and display labels.
- `test/storage-stack.test.js`：tests stack reorder behavior.
- `docs/phase-1-domain-foundation.md`：short handoff document describing what Phase 1 provides and how Flutter should consume it later.

---

### Task 1: Project Test Harness

**Files:**

- Create: `package.json`

- [ ] **Step 1: Create package manifest**

Write this file:

```json
{
  "name": "wardrobe-digital-twin",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "node --test"
  }
}
```

- [ ] **Step 2: Verify test command before tests exist**

Run:

```powershell
node --test
```

Expected:

```text
TAP version 13
1..0
# tests 0
# pass 0
# fail 0
```

- [ ] **Step 3: Commit if this workspace becomes a git repo**

Run only if `.git` exists:

```powershell
git add package.json
git commit -m "chore: add node test harness"
```

---

### Task 2: Twin Status and Confidence Rules

**Files:**

- Create: `src/domain/twin-status.js`
- Create: `test/twin-status.test.js`

- [ ] **Step 1: Write failing tests**

Create `test/twin-status.test.js`:

```javascript
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
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
node --test test/twin-status.test.js
```

Expected: FAIL because `src/domain/twin-status.js` does not exist.

- [ ] **Step 3: Implement minimal twin status calculation**

Create `src/domain/twin-status.js`:

```javascript
const PHYSICAL_ANCHORS = new Set(['nfc_scan', 'qr_scan', 'rfid_scan']);

export function calculateTwinState({ evidence, daysSinceVerified, hasSimilarItems, locationState = 'known' }) {
  const evidenceList = Array.isArray(evidence) ? evidence : [];
  let confidence = 0;

  if (evidenceList.includes('main_photo')) confidence += 20;

  const detailPhotoCount = evidenceList.filter((item) => item === 'detail_photo').length;
  if (detailPhotoCount >= 2) confidence += 20;
  else if (detailPhotoCount === 1) confidence += 10;

  if (evidenceList.includes('manual_confirm')) confidence += 20;

  const hasAnchor = evidenceList.some((item) => PHYSICAL_ANCHORS.has(item));
  if (hasAnchor) confidence += 40;

  if (typeof daysSinceVerified === 'number' && daysSinceVerified > 90) confidence -= 20;
  if (hasSimilarItems) confidence -= 15;
  if (locationState === 'missing') confidence -= 50;

  confidence = Math.max(0, Math.min(100, confidence));

  if (locationState === 'missing') return { status: 'missing', confidence };
  if (confidence === 0) return { status: 'unbound', confidence };
  if (hasAnchor && confidence >= 70) return { status: 'anchored', confidence };
  if (confidence < 50 || (typeof daysSinceVerified === 'number' && daysSinceVerified > 90)) {
    return { status: 'review', confidence };
  }

  return { status: 'mapped', confidence };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```powershell
node --test test/twin-status.test.js
```

Expected: PASS.

- [ ] **Step 5: Commit if this workspace becomes a git repo**

```powershell
git add src/domain/twin-status.js test/twin-status.test.js
git commit -m "feat: add twin status rules"
```

---

### Task 3: Wardrobe Semantic Address Model

**Files:**

- Create: `src/domain/location-address.js`
- Create: `test/location-address.test.js`

- [ ] **Step 1: Write failing tests**

Create `test/location-address.test.js`:

```javascript
import test from 'node:test';
import assert from 'node:assert/strict';
import { formatLocationCode, formatLocationLabel } from '../src/domain/location-address.js';

test('formats a hierarchical wardrobe location code', () => {
  const code = formatLocationCode({ wardrobe: 1, zone: 2, compartment: 1, group: 3, item: 4 });

  assert.equal(code, 'W01-Z02-C01-G03-I04');
});

test('formats a user-facing stacked clothing location label', () => {
  const label = formatLocationLabel({
    wardrobeName: '主衣柜',
    zoneName: '上层',
    compartmentName: '左侧层板',
    groupName: '第 2 叠',
    orderDirection: 'top_to_bottom',
    orderIndex: 3,
  });

  assert.equal(label, '主衣柜 / 上层 / 左侧层板 / 第 2 叠 / 从上往下第 3 件');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
node --test test/location-address.test.js
```

Expected: FAIL because `src/domain/location-address.js` does not exist.

- [ ] **Step 3: Implement address formatting**

Create `src/domain/location-address.js`:

```javascript
function twoDigit(value) {
  return String(value).padStart(2, '0');
}

export function formatLocationCode({ wardrobe, zone, compartment, group, item }) {
  return `W${twoDigit(wardrobe)}-Z${twoDigit(zone)}-C${twoDigit(compartment)}-G${twoDigit(group)}-I${twoDigit(item)}`;
}

export function formatLocationLabel({
  wardrobeName,
  zoneName,
  compartmentName,
  groupName,
  orderDirection,
  orderIndex,
}) {
  const orderLabel = orderDirection === 'top_to_bottom'
    ? `从上往下第 ${orderIndex} 件`
    : `第 ${orderIndex} 件`;

  return [wardrobeName, zoneName, compartmentName, groupName, orderLabel].join(' / ');
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```powershell
node --test test/location-address.test.js
```

Expected: PASS.

- [ ] **Step 5: Commit if this workspace becomes a git repo**

```powershell
git add src/domain/location-address.js test/location-address.test.js
git commit -m "feat: add wardrobe location addresses"
```

---

### Task 4: Stack Reorder Behavior

**Files:**

- Create: `src/domain/storage-stack.js`
- Create: `test/storage-stack.test.js`

- [ ] **Step 1: Write failing tests**

Create `test/storage-stack.test.js`:

```javascript
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
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
node --test test/storage-stack.test.js
```

Expected: FAIL because `src/domain/storage-stack.js` does not exist.

- [ ] **Step 3: Implement stack reorder functions**

Create `src/domain/storage-stack.js`:

```javascript
export function moveItemToTop(stack, itemId) {
  return moveItemToPosition(stack, itemId, 1);
}

export function moveItemToPosition(stack, itemId, oneBasedPosition) {
  const currentIndex = stack.indexOf(itemId);
  if (currentIndex === -1) return [...stack];

  const nextStack = stack.filter((id) => id !== itemId);
  const targetIndex = Math.max(0, Math.min(nextStack.length, oneBasedPosition - 1));
  nextStack.splice(targetIndex, 0, itemId);
  return nextStack;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```powershell
node --test test/storage-stack.test.js
```

Expected: PASS.

- [ ] **Step 5: Commit if this workspace becomes a git repo**

```powershell
git add src/domain/storage-stack.js test/storage-stack.test.js
git commit -m "feat: add stack reorder behavior"
```

---

### Task 5: SQLite Schema Draft

**Files:**

- Create: `src/db/schema.sql`

- [ ] **Step 1: Create schema file**

Create `src/db/schema.sql`:

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE clothing_items (
  id TEXT PRIMARY KEY,
  physical_instance_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  brand TEXT,
  category TEXT NOT NULL,
  colors TEXT NOT NULL DEFAULT '',
  seasons TEXT NOT NULL DEFAULT '',
  occasions TEXT NOT NULL DEFAULT '',
  tags TEXT NOT NULL DEFAULT '',
  purchase_price REAL,
  image_path TEXT,
  thumbnail_path TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  twin_status TEXT NOT NULL DEFAULT 'unbound',
  twin_confidence INTEGER NOT NULL DEFAULT 0,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE item_identity_evidence (
  id TEXT PRIMARY KEY,
  clothing_item_id TEXT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  evidence_type TEXT NOT NULL,
  value TEXT NOT NULL,
  confidence INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE TABLE physical_anchors (
  id TEXT PRIMARY KEY,
  clothing_item_id TEXT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  anchor_type TEXT NOT NULL,
  anchor_uid TEXT NOT NULL UNIQUE,
  active INTEGER NOT NULL DEFAULT 1,
  bound_at INTEGER NOT NULL,
  unbound_at INTEGER
);

CREATE TABLE wardrobes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  room TEXT,
  description TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE wardrobe_zones (
  id TEXT PRIMARY KEY,
  wardrobe_id TEXT NOT NULL REFERENCES wardrobes(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  level TEXT,
  side TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE compartments (
  id TEXT PRIMARY KEY,
  zone_id TEXT NOT NULL REFERENCES wardrobe_zones(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  row_index INTEGER NOT NULL DEFAULT 0,
  column_index INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE storage_groups (
  id TEXT PRIMARY KEY,
  compartment_id TEXT NOT NULL REFERENCES compartments(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  storage_type TEXT NOT NULL,
  position_index INTEGER NOT NULL DEFAULT 0,
  direction TEXT NOT NULL DEFAULT 'top_to_bottom'
);

CREATE TABLE item_storage_assignments (
  id TEXT PRIMARY KEY,
  clothing_item_id TEXT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  storage_group_id TEXT NOT NULL REFERENCES storage_groups(id) ON DELETE CASCADE,
  order_index INTEGER NOT NULL DEFAULT 1,
  order_direction TEXT NOT NULL DEFAULT 'top_to_bottom',
  visibility TEXT NOT NULL DEFAULT 'visible',
  accessibility TEXT NOT NULL DEFAULT 'normal',
  location_confidence TEXT NOT NULL DEFAULT 'medium',
  last_verified_at INTEGER,
  UNIQUE(clothing_item_id, storage_group_id)
);

CREATE TABLE item_location_events (
  id TEXT PRIMARY KEY,
  clothing_item_id TEXT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  storage_group_id TEXT REFERENCES storage_groups(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  notes TEXT
);

CREATE INDEX idx_clothing_items_twin_status ON clothing_items(twin_status);
CREATE INDEX idx_item_evidence_clothing_item ON item_identity_evidence(clothing_item_id);
CREATE INDEX idx_storage_assignments_group ON item_storage_assignments(storage_group_id, order_index);
CREATE INDEX idx_location_events_item_time ON item_location_events(clothing_item_id, created_at);
```

- [ ] **Step 2: Verify the SQL file is readable**

Run:

```powershell
Get-Content src/db/schema.sql -TotalCount 20
```

Expected: shows `PRAGMA foreign_keys = ON;` and the `clothing_items` table.

- [ ] **Step 3: Optional SQLite validation**

Run only if `sqlite3` is available:

```powershell
sqlite3 :memory: ".read src/db/schema.sql" ".tables"
```

Expected includes:

```text
clothing_items item_identity_evidence physical_anchors wardrobes wardrobe_zones compartments storage_groups item_storage_assignments item_location_events
```

- [ ] **Step 4: Commit if this workspace becomes a git repo**

```powershell
git add src/db/schema.sql
git commit -m "feat: draft wardrobe twin schema"
```

---

### Task 6: Phase 1 Handoff Document

**Files:**

- Create: `docs/phase-1-domain-foundation.md`

- [ ] **Step 1: Write handoff doc**

Create `docs/phase-1-domain-foundation.md`:

```markdown
# Phase 1 Domain Foundation

Phase 1 builds the wardrobe digital twin domain kernel before Flutter UI work starts.

## What Exists

- Twin identity status calculation.
- Twin confidence calculation.
- Wardrobe semantic address formatting.
- Stack reorder behavior for folded clothes.
- SQLite-compatible schema draft.

## Why This Comes Before UI

The product depends on two mappings:

1. Physical clothing item -> digital item instance.
2. Physical wardrobe space -> digital wardrobe location.

If these rules are unclear, the UI becomes a photo gallery instead of a digital twin.

## Flutter Phase 2 Integration

The Flutter app should port these rules into Dart services:

- `IdentityService`
- `LocationAddressService`
- `StorageStackService`
- `WardrobeDatabase`

The Drift schema should mirror `src/db/schema.sql`.
```

- [ ] **Step 2: Run all tests**

Run:

```powershell
npm test
```

Expected: all Node tests pass.

- [ ] **Step 3: Commit if this workspace becomes a git repo**

```powershell
git add docs/phase-1-domain-foundation.md
git commit -m "docs: add phase 1 handoff"
```

---

## Self-Review

Spec coverage:

- One-to-one clothing identity mapping is covered by Task 2 and Task 5.
- Real wardrobe space modeling is covered by Task 3 and Task 5.
- Stacked clothes such as upper-shelf piles are covered by Task 3 and Task 4.
- MVP sequencing is covered by Task 6.

Placeholder scan:

- No `TBD`, `TODO`, or unspecified implementation steps are intentionally present.
- Each code task includes concrete test code, implementation code, and verification commands.

Type consistency:

- `twin_status`, `twin_confidence`, `physical_instance_id`, `storage_group_id`, `order_index`, and `location_confidence` are named consistently across tests, schema, and docs.

---

## Plan Adjustment: Support Diverse Wardrobe Styles

The design evolved after the original plan. Replace the fixed wardrobe hierarchy in Task 5 with a recursive storage model.

Use `storage_nodes` and `item_placements` instead of hard-coding `wardrobes`, `wardrobe_zones`, `compartments`, `storage_groups`, and `item_storage_assignments` as separate structural layers.

Updated schema direction:

```sql
CREATE TABLE storage_nodes (
  id TEXT PRIMARY KEY,
  parent_id TEXT REFERENCES storage_nodes(id) ON DELETE CASCADE,
  node_type TEXT NOT NULL,
  name TEXT NOT NULL,
  template_type TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  grid_x INTEGER,
  grid_y INTEGER,
  grid_w INTEGER,
  grid_h INTEGER,
  order_axis TEXT,
  access_pattern TEXT NOT NULL DEFAULT 'open',
  visibility TEXT NOT NULL DEFAULT 'visible',
  mobility TEXT NOT NULL DEFAULT 'fixed',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE item_placements (
  id TEXT PRIMARY KEY,
  clothing_item_id TEXT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  storage_node_id TEXT NOT NULL REFERENCES storage_nodes(id) ON DELETE CASCADE,
  order_index INTEGER NOT NULL DEFAULT 1,
  order_axis TEXT NOT NULL DEFAULT 'top_to_bottom',
  placement_confidence TEXT NOT NULL DEFAULT 'medium',
  last_verified_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(clothing_item_id, storage_node_id)
);
```

Add tests in Task 3 for labels such as:

```text
开放挂架 / 上方挂杆 / 从左到右第 4 件
抽屉柜 / 第 2 层抽屉 / 左侧分区 / 从前往后第 5 件
主衣柜 / 上层收纳区 / 收纳箱 B03 / 第 1 叠 / 从上往下第 2 件
```
