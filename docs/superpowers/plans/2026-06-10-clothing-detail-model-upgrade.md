# Clothing Detail Model Upgrade Implementation Plan

> For agentic workers: implement inline with TDD because this workspace is not a Git repository.

**Goal:** Upgrade a stored clothing item from a simple name/location record into a digital-twin clothing record with identity, attributes, location order, mapping status, and confirmation time.

**Architecture:** Extend `StoredWardrobeItem` serialization first, then wire the add-clothing sheet to collect the new fields, and finally render those fields on stored/search item cards. Keep persistence as the existing `WardrobeSession` JSON map.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

## Tasks

- [ ] Add failing domain test for the new item detail fields.
- [ ] Add failing widget test for entering detail fields in the add flow and seeing them rendered.
- [ ] Extend `StoredWardrobeItem` with `category`, `color`, `material`, `brand`, `size`, `locationIndex`, `twinStatus`, and `lastConfirmedAt`.
- [ ] Add text controllers and fields to the add-clothing sheet.
- [ ] Save new field values when creating a clothing record.
- [ ] Render attributes, location sequence, twin status, and confirmation time in stored/search cards.
- [ ] Run `dart format`, targeted tests, full Flutter tests, analyze, and web build.
