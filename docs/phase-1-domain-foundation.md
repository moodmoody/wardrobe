# Phase 1 Domain Foundation

Phase 1 builds the wardrobe digital twin domain kernel before Flutter UI work starts.

## What Exists

- Twin identity status calculation.
- Twin confidence calculation.
- Wardrobe semantic address formatting.
- Stack reorder behavior for folded clothes.
- Recursive wardrobe storage nodes for different closet styles.
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
- `StorageNodeTreeService`
- `WardrobeDatabase`

The Drift schema should mirror `src/db/schema.sql`.