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

CREATE TABLE item_location_events (
  id TEXT PRIMARY KEY,
  clothing_item_id TEXT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  storage_node_id TEXT REFERENCES storage_nodes(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  notes TEXT
);

CREATE INDEX idx_clothing_items_twin_status ON clothing_items(twin_status);
CREATE INDEX idx_item_evidence_clothing_item ON item_identity_evidence(clothing_item_id);
CREATE INDEX idx_item_placements_node ON item_placements(storage_node_id, order_index);
CREATE INDEX idx_location_events_item_time ON item_location_events(clothing_item_id, created_at);