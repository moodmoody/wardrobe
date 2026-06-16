import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wardrobe_twin/data/wardrobe_asset_loader.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store_factory.dart';
import 'package:wardrobe_twin/domain/storage_node.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';

void main() {
  runApp(const WardrobeTwinApp());
}

enum _AuditStatus { verified, needsSorting, unknown }

enum _AddClothingMode { createNew, existing }

class _PhotoEvidenceCard extends StatelessWidget {
  const _PhotoEvidenceCard({super.key, required this.captured});

  final bool captured;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: captured ? const Color(0xFF203A34) : const Color(0xFF2E2925),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: captured ? const Color(0xFF7AD3C2) : const Color(0xFF6B5C4F),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              captured
                  ? Icons.check_circle_outline
                  : Icons.photo_camera_outlined,
              color: captured
                  ? const Color(0xFF7AD3C2)
                  : const Color(0xFFD7C3A5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    captured ? '主图已记录' : '主图未记录',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    captured ? '已生成这件衣服的现实视觉证据。' : '拍一张主图，用来把数字衣服对应回现实衣服。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFD7C3A5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoredPhotoEvidenceBadge extends StatelessWidget {
  const _StoredPhotoEvidenceBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.photo_library_outlined,
          size: 16,
          color: Color(0xFF7AD3C2),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '主图证据：已记录',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFD7C3A5),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPreviewCard extends StatelessWidget {
  const _LocationPreviewCard({required this.node, required this.locationIndex});

  final StorageNode node;
  final int locationIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('item-location-preview'),
      decoration: BoxDecoration(
        color: const Color(0xFF203A34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6AD8C5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.my_location_outlined,
              color: Color(0xFF7AD3C2),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '自动定位码：${_locationCodeForNode(node.id, locationIndex)}\n现实找法：${_locationGuidanceForNode(node.id, node.name, locationIndex)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFD7FFF6),
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClothingDetailTextField extends StatelessWidget {
  const _ClothingDetailTextField({
    required this.fieldKey,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.keyboardType,
    this.autofocus = false,
    this.onChanged,
  });

  final ValueKey<String> fieldKey;
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType? keyboardType;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFFE7DAC7)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8C8178)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6AD8C5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7AD3C2), width: 2),
        ),
      ),
    );
  }
}

class WardrobeTwinApp extends StatelessWidget {
  const WardrobeTwinApp({super.key, this.sessionStore});

  final WardrobeSessionStore? sessionStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '衣橱数字孪生',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F5F58),
          surface: const Color(0xFFF5EAD8),
        ),
        scaffoldBackgroundColor: const Color(0xFFEEE0C8),
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Georgia',
          bodyColor: const Color(0xFF241D17),
          displayColor: const Color(0xFF241D17),
        ),
      ),
      home: WardrobeHomePage(sessionStore: sessionStore),
    );
  }
}

class WardrobeHomePage extends StatefulWidget {
  const WardrobeHomePage({super.key, this.sessionStore});

  final WardrobeSessionStore? sessionStore;

  @override
  State<WardrobeHomePage> createState() => _WardrobeHomePageState();
}

class _WardrobeHomePageState extends State<WardrobeHomePage> {
  late final Future<WardrobeStorageModel> _modelFuture;

  @override
  void initState() {
    super.initState();
    _modelFuture = loadWardrobeStorageModel(rootBundle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WardrobeStorageModel>(
        future: _modelFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadState(message: '衣橱样板加载失败：${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const _LoadState(message: '正在加载 W01 数字衣橱...');
          }

          return _WardrobeOverview(
            model: snapshot.requireData,
            sessionStore: widget.sessionStore,
          );
        },
      ),
    );
  }
}

class _WardrobeOverview extends StatefulWidget {
  const _WardrobeOverview({required this.model, this.sessionStore});

  final WardrobeStorageModel model;
  final WardrobeSessionStore? sessionStore;

  @override
  State<_WardrobeOverview> createState() => _WardrobeOverviewState();
}

class _WardrobeOverviewState extends State<_WardrobeOverview> {
  late final WardrobeSessionStore _sessionStore;
  String _selectedNodeId = 'W01-L-S02';
  final Map<String, _AuditStatus> _auditStatuses = {};
  final Map<String, List<StoredWardrobeItem>> _itemsByNode = {};

  @override
  void initState() {
    super.initState();
    _sessionStore = widget.sessionStore ?? createWardrobeSessionStore();
    unawaited(_restoreSession());
  }

  List<StorageNode> get _spatialNodes => widget.model.nodes
      .where(
        (node) =>
            node.parentId != null &&
            node.nodeType != 'bay' &&
            node.nodeType != 'stack' &&
            node.grid != null,
      )
      .toList(growable: false);

  StorageNode get _selectedNode => widget.model.nodeById(_selectedNodeId);

  @override
  Widget build(BuildContext context) {
    final unauditedCount = widget.model.nodes
        .where(
          (node) =>
              node.visibility == 'hidden' ||
              node.visibility == 'partially_hidden' ||
              node.needsSorting,
        )
        .length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBD8B9), Color(0xFFF7F0E4), Color(0xFFD7C3A5)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _TwinCommandDeck(
                model: widget.model,
                spatialNodes: _spatialNodes,
                selectedNode: _selectedNode,
                selectedAuditStatus: _auditStatusFor(_selectedNode),
                unauditedCount: unauditedCount,
                missingItemsCount: _missingStoredItems.length,
                onSelected: _selectNode,
                onShowDetails: () => _showNodeDetail(_selectedNode),
                onFindClothes: _showFindClothesSheet,
                onShowExceptions: _showExceptionClothesSheet,
              ),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(child: content),
            );
          },
        ),
      ),
    );
  }

  void _selectNode(StorageNode node) {
    setState(() => _selectedNodeId = node.id);
  }

  List<StoredWardrobeItem> get _allStoredItems {
    return [for (final items in _itemsByNode.values) ...items];
  }

  List<StoredWardrobeItem> get _missingStoredItems {
    return _allStoredItems
        .where((item) => item.presenceStatus == 'missing')
        .toList(growable: false);
  }

  _AuditStatus _auditStatusFor(StorageNode node) {
    return _auditStatuses[node.id] ?? _defaultAuditStatusFor(node);
  }

  void _setAuditStatus(StorageNode node, _AuditStatus status) {
    setState(() => _auditStatuses[node.id] = status);
    unawaited(_saveSession());
  }

  void _showNodeDetail(StorageNode node) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.82,
              minChildSize: 0.45,
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xFF181411),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    child: _WardrobeNodeDetail(
                      model: widget.model,
                      node: node,
                      childCount: widget.model.childrenOf(node.id).length,
                      storedItems: _itemsByNode[node.id] ?? const [],
                      auditStatus: _auditStatusFor(node),
                      onAuditStatusChanged: (status) {
                        _setAuditStatus(node, status);
                        setSheetState(() {});
                      },
                      onAddItem: () =>
                          _showAddItemSheet(node, () => setSheetState(() {})),
                      onItemPresenceChanged: (index, status) {
                        _setItemPresenceStatus(node, index, status);
                        setSheetState(() {});
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _addItemToNode(
    StorageNode node,
    String name,
    String category,
    String color,
    String material,
    String brand,
    String size,
    int locationIndex,
    String visualSignature,
    String primaryPhotoRef,
  ) {
    final hasPhotoEvidence = primaryPhotoRef.isNotEmpty;
    final item = StoredWardrobeItem(
      itemId: _newItemId(node),
      name: name,
      nodeId: node.id,
      nodeName: node.name,
      category: category,
      color: color,
      material: material,
      brand: brand,
      size: size,
      locationIndex: locationIndex,
      twinStatus: hasPhotoEvidence ? 'mapped' : 'pending',
      lastConfirmedAt: hasPhotoEvidence ? DateTime.now().toIso8601String() : '',
      visualSignature: visualSignature,
      primaryPhotoRef: primaryPhotoRef,
    );
    setState(() {
      final items = List<StoredWardrobeItem>.from(
        _itemsByNode[node.id] ?? const [],
      );
      items.add(item);
      _itemsByNode[node.id] = items;
    });
    unawaited(_saveSession());
  }

  String _newItemId(StorageNode node) {
    return '${node.id}-${DateTime.now().microsecondsSinceEpoch}';
  }

  String _newMockPhotoRef(StorageNode node) {
    return 'mock://photo/${node.id}/${DateTime.now().microsecondsSinceEpoch}';
  }

  void _moveExistingItemToNode(
    StoredWardrobeItem item,
    StorageNode targetNode,
  ) {
    setState(() {
      final sourceItems = List<StoredWardrobeItem>.from(
        _itemsByNode[item.nodeId] ?? const [],
      );
      sourceItems.removeWhere(
        (candidate) => _sameClothingIdentity(candidate, item),
      );
      _itemsByNode[item.nodeId] = sourceItems;

      final targetItems = List<StoredWardrobeItem>.from(
        _itemsByNode[targetNode.id] ?? const [],
      );
      targetItems.add(
        item.copyWith(
          nodeId: targetNode.id,
          nodeName: targetNode.name,
          locationIndex: targetItems.length + 1,
          twinStatus: 'pending',
          lastConfirmedAt: '',
          presenceStatus: 'unknown',
        ),
      );
      _itemsByNode[targetNode.id] = targetItems;
      _auditStatuses[targetNode.id] = _AuditStatus.unknown;
    });
    unawaited(_saveSession());
  }

  bool _sameClothingIdentity(StoredWardrobeItem a, StoredWardrobeItem b) {
    if (a.itemId.isNotEmpty && b.itemId.isNotEmpty) {
      return a.itemId == b.itemId;
    }
    return a.name == b.name && a.nodeId == b.nodeId && a.nodeName == b.nodeName;
  }

  void _setItemPresenceStatus(StorageNode node, int index, String status) {
    setState(() {
      final items = List<StoredWardrobeItem>.from(
        _itemsByNode[node.id] ?? const [],
      );
      if (index < 0 || index >= items.length) {
        return;
      }
      items[index] = items[index].copyWith(
        presenceStatus: status,
        twinStatus: status == 'present' ? 'mapped' : 'exception',
        lastConfirmedAt: DateTime.now().toIso8601String(),
      );
      _itemsByNode[node.id] = items;
      if (items.isNotEmpty &&
          items.every((item) => item.presenceStatus != 'unknown')) {
        _auditStatuses[node.id] = _AuditStatus.verified;
      }
    });
    unawaited(_saveSession());
  }

  Future<void> _restoreSession() async {
    final session = await _sessionStore.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _itemsByNode
        ..clear()
        ..addAll(
          session.itemsByNode.map(
            (nodeId, items) =>
                MapEntry(nodeId, List<StoredWardrobeItem>.of(items)),
          ),
        );
      _auditStatuses
        ..clear()
        ..addAll(
          session.auditStatuses.map(
            (nodeId, status) =>
                MapEntry(nodeId, _auditStatusFromStorage(status)),
          ),
        );
    });
  }

  Future<void> _saveSession() {
    final session = WardrobeSession(
      itemsByNode: _itemsByNode.map(
        (nodeId, items) => MapEntry(nodeId, List<StoredWardrobeItem>.of(items)),
      ),
      auditStatuses: _auditStatuses.map(
        (nodeId, status) => MapEntry(nodeId, _auditStatusStorageValue(status)),
      ),
    );
    return _sessionStore.save(session);
  }

  void _showFindClothesSheet() {
    final controller = TextEditingController();
    var query = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181411),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final results = query.trim().isEmpty
                ? const <StoredWardrobeItem>[]
                : _allStoredItems
                      .where(
                        (item) => _itemSearchText(
                          item,
                        ).contains(query.trim().toLowerCase()),
                      )
                      .toList(growable: false);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '找衣服在哪',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '输入衣服名，直接定位到现实衣橱位置。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFD7FFF6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('clothing-search-input'),
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) => setSheetState(() => query = value),
                    decoration: InputDecoration(
                      labelText: '衣服名称',
                      labelStyle: const TextStyle(color: Color(0xFFE7DAC7)),
                      hintText: '例如：外套',
                      hintStyle: const TextStyle(color: Color(0xFF8C8178)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF6AD8C5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF7AD3C2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (query.trim().isEmpty)
                    Text(
                      '先输入关键词，比如“外套”。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFD7C3A5),
                      ),
                    )
                  else if (results.isEmpty)
                    Text(
                      '没有找到匹配的衣服。可以换个关键词，或先到对应位置录入。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFD7C3A5),
                      ),
                    )
                  else
                    for (final item in results)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SearchResultTile(
                          item: item,
                          onTap: () => _openFoundClothing(item, context),
                        ),
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExceptionClothesSheet() {
    final missingItems = _missingStoredItems;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181411),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          key: const ValueKey('exception-clothes-sheet'),
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(context).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '异常衣服',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这些衣服已标记为“不在”，需要重新查找或修正映射。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD7FFF6),
                ),
              ),
              const SizedBox(height: 16),
              if (missingItems.isEmpty)
                Text(
                  '当前没有异常衣服。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFD7C3A5),
                  ),
                )
              else
                for (final item in missingItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SearchResultTile(
                      item: item,
                      onTap: () => _openFoundClothing(item, context),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  void _openFoundClothing(StoredWardrobeItem item, BuildContext sheetContext) {
    final itemIndex = _storedItemIndex(item);
    setState(() => _selectedNodeId = item.nodeId);
    Navigator.of(sheetContext).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showClothingDetailSheet(
        context,
        item,
        itemIndex,
        onConfirmPresent: item.presenceStatus == 'missing'
            ? () => _confirmStoredItemPresent(item)
            : null,
      );
    });
  }

  void _confirmStoredItemPresent(StoredWardrobeItem item) {
    final node = widget.model.nodeById(item.nodeId);
    final itemIndex = _storedItemIndex(item);
    _setItemPresenceStatus(node, itemIndex, 'present');
  }

  int _storedItemIndex(StoredWardrobeItem item) {
    final items = _itemsByNode[item.nodeId] ?? const <StoredWardrobeItem>[];
    final index = items.indexWhere((candidate) {
      return _sameClothingIdentity(candidate, item);
    });
    return index < 0 ? 0 : index;
  }

  void _showAddItemSheet(StorageNode node, VoidCallback refreshDetailSheet) {
    final controller = TextEditingController();
    final categoryController = TextEditingController();
    final colorController = TextEditingController();
    final materialController = TextEditingController();
    final brandController = TextEditingController();
    final sizeController = TextEditingController();
    final locationIndexController = TextEditingController();
    final visualController = TextEditingController();
    final photoRefController = TextEditingController();
    final suggestedLocationIndex =
        (_itemsByNode[node.id] ?? const []).length + 1;
    locationIndexController.text = suggestedLocationIndex.toString();
    var mode = _AddClothingMode.createNew;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181411),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final existingItems = _allStoredItems
                .where((item) => item.nodeId != node.id)
                .toList(growable: false);
            final previewLocationIndex =
                int.tryParse(locationIndexController.text.trim()) ??
                suggestedLocationIndex;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '放入一件衣服',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前位置：${node.name}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFD7FFF6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<_AddClothingMode>(
                    showSelectedIcon: false,
                    selected: {mode},
                    onSelectionChanged: (selection) =>
                        setSheetState(() => mode = selection.first),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        return states.contains(WidgetState.selected)
                            ? const Color(0xFF12201C)
                            : const Color(0xFFE7DAC7);
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        return states.contains(WidgetState.selected)
                            ? const Color(0xFF7AD3C2)
                            : const Color(0xFF2E2925);
                      }),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Color(0xFF6AD8C5)),
                      ),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: _AddClothingMode.createNew,
                        label: Text('新衣服建档'),
                      ),
                      ButtonSegment(
                        value: _AddClothingMode.existing,
                        label: Text(
                          '选择已有衣服',
                          key: ValueKey('add-mode-existing'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (mode == _AddClothingMode.createNew) ...[
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-name-input'),
                      controller: controller,
                      labelText: '衣服名称',
                      hintText: '例如：黑色外套',
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-category-input'),
                      controller: categoryController,
                      labelText: '类型',
                      hintText: '例如：外套 / 衬衫 / 裤子',
                    ),
                    const SizedBox(height: 12),
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-color-input'),
                      controller: colorController,
                      labelText: '主色',
                      hintText: '例如：黑色',
                    ),
                    const SizedBox(height: 12),
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-material-input'),
                      controller: materialController,
                      labelText: '材质/特征',
                      hintText: '例如：羊毛 / 牛仔 / 条纹',
                    ),
                    const SizedBox(height: 12),
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-brand-input'),
                      controller: brandController,
                      labelText: '品牌',
                      hintText: '可选，例如：Uniqlo',
                    ),
                    const SizedBox(height: 12),
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-size-input'),
                      controller: sizeController,
                      labelText: '尺码',
                      hintText: '可选，例如：M',
                    ),
                    const SizedBox(height: 12),
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-location-index-input'),
                      controller: locationIndexController,
                      labelText: '空间内序号',
                      hintText: '例如：挂衣杆第 3 件就填 3',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: 8),
                    _LocationPreviewCard(
                      node: node,
                      locationIndex: previewLocationIndex,
                    ),
                    const SizedBox(height: 12),
                    _ClothingDetailTextField(
                      fieldKey: const ValueKey('item-visual-input'),
                      controller: visualController,
                      labelText: '视觉身份',
                      hintText: '例如：正面黑色拉链外套照片',
                    ),
                    const SizedBox(height: 12),
                    _PhotoEvidenceCard(
                      key: ValueKey(
                        photoRefController.text.trim().isEmpty
                            ? 'photo-evidence-empty'
                            : 'photo-evidence-captured',
                      ),
                      captured: photoRefController.text.trim().isNotEmpty,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const ValueKey('mock-capture-photo-button'),
                        onPressed: () {
                          photoRefController.text = _newMockPhotoRef(node);
                          setSheetState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7AD3C2),
                          side: const BorderSide(color: Color(0xFF6AD8C5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('模拟拍照生成主图'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey('save-item-button'),
                        onPressed: () {
                          final name = controller.text.trim();
                          final category = categoryController.text.trim();
                          final color = colorController.text.trim();
                          final material = materialController.text.trim();
                          final brand = brandController.text.trim();
                          final size = sizeController.text.trim();
                          final locationIndex =
                              int.tryParse(
                                locationIndexController.text.trim(),
                              ) ??
                              ((_itemsByNode[node.id] ?? const []).length + 1);
                          final visualSignature = visualController.text.trim();
                          final primaryPhotoRef = photoRefController.text
                              .trim();
                          if (name.isEmpty) {
                            return;
                          }
                          _addItemToNode(
                            node,
                            name,
                            category,
                            color,
                            material,
                            brand,
                            size,
                            locationIndex,
                            visualSignature,
                            primaryPhotoRef,
                          );
                          refreshDetailSheet();
                          Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF7AD3C2),
                          foregroundColor: const Color(0xFF12201C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('保存到当前位置'),
                      ),
                    ),
                  ] else if (existingItems.isEmpty)
                    Text(
                      '还没有可选择的已建档衣服。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFD7C3A5),
                      ),
                    )
                  else
                    for (final item in existingItems)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SearchResultTile(
                          item: item,
                          onTap: () {
                            _moveExistingItemToNode(item, node);
                            refreshDetailSheet();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TwinCommandDeck extends StatelessWidget {
  const _TwinCommandDeck({
    required this.model,
    required this.spatialNodes,
    required this.selectedNode,
    required this.selectedAuditStatus,
    required this.unauditedCount,
    required this.missingItemsCount,
    required this.onSelected,
    required this.onShowDetails,
    required this.onFindClothes,
    required this.onShowExceptions,
  });

  final WardrobeStorageModel model;
  final List<StorageNode> spatialNodes;
  final StorageNode selectedNode;
  final _AuditStatus selectedAuditStatus;
  final int unauditedCount;
  final int missingItemsCount;
  final ValueChanged<StorageNode> onSelected;
  final VoidCallback onShowDetails;
  final VoidCallback onFindClothes;
  final VoidCallback onShowExceptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroPanel(
          model: model,
          unauditedCount: unauditedCount,
          missingItemsCount: missingItemsCount,
          onFindClothes: onFindClothes,
          onShowExceptions: onShowExceptions,
        ),
        const SizedBox(height: 12),
        _SpatialMapCard(
          model: model,
          nodes: spatialNodes,
          selectedNode: selectedNode,
          onSelected: onSelected,
        ),
        const SizedBox(height: 14),
        _SelectedNodeBar(
          node: selectedNode,
          status: selectedAuditStatus,
          onShowDetails: onShowDetails,
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.model,
    required this.unauditedCount,
    required this.missingItemsCount,
    required this.onFindClothes,
    required this.onShowExceptions,
  });

  final WardrobeStorageModel model;
  final int unauditedCount;
  final int missingItemsCount;
  final VoidCallback onFindClothes;
  final VoidCallback onShowExceptions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF201913),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _ScanAtmospherePainter()),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _SignalDot(),
                    const SizedBox(width: 10),
                    Text(
                      '真实衣橱模拟舱',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFEBD8B9),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'W01 数字衣橱',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '把现实衣橱拆成可盘点的空间节点，再把每件衣服绑定到当前位置。',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFE7DAC7),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatusPill(text: '${model.nodes.length} 个衣橱位置'),
                    const _StatusPill(text: '3 个建议先盘点'),
                    _StatusPill(text: '$unauditedCount 个待确认区域'),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('find-clothes-button'),
                    onPressed: onFindClothes,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7AD3C2),
                      foregroundColor: const Color(0xFF12201C),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('找衣服'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const ValueKey('exception-clothes-button'),
                    onPressed: onShowExceptions,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFC45C),
                      side: const BorderSide(color: Color(0xFFFFC45C)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: Text('异常衣服（$missingItemsCount）'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedNodeBar extends StatelessWidget {
  const _SelectedNodeBar({
    required this.node,
    required this.status,
    required this.onShowDetails,
  });

  final StorageNode node;
  final _AuditStatus status;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7C3A5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前选中：${node.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF14201D),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '状态：${_auditStatusLabel(status)} / 类型：${_nodeTypeLabel(node.nodeType)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4E5A50)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('show-node-detail-button'),
                onPressed: onShowDetails,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF254E49),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('查看详情 / 盘点'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpatialMapCard extends StatelessWidget {
  const _SpatialMapCard({
    required this.model,
    required this.nodes,
    required this.selectedNode,
    required this.onSelected,
  });

  final WardrobeStorageModel model;
  final List<StorageNode> nodes;
  final StorageNode selectedNode;
  final ValueChanged<StorageNode> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF7B5737),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF4D3522), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 26,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'W01 数字衣橱',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFFFF7EA),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const _BlueprintTag(text: '12 x 16 网格'),
              ],
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 12 / 16,
              child: Stack(
                key: const ValueKey('wardrobe-spatial-map'),
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/w01-digital-twin-bg.jpg',
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.medium,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0x7A241812)),
                          ),
                          CustomPaint(painter: _WardrobeGridPainter()),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFE8C2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 8,
                    top: 8,
                    child: _BlueprintTag(text: 'L 左侧层板叠放区'),
                  ),
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: _BlueprintTag(text: 'R 右侧挂衣抽屉区'),
                  ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            for (final node in nodes)
                              _PositionedStorageNode(
                                node: node,
                                selected: node.id == selectedNode.id,
                                mapSize: constraints.biggest,
                                onTap: () => onSelected(node),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionedStorageNode extends StatelessWidget {
  const _PositionedStorageNode({
    required this.node,
    required this.selected,
    required this.mapSize,
    required this.onTap,
  });

  final StorageNode node;
  final bool selected;
  final Size mapSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final grid = node.grid!;
    final cellWidth = mapSize.width / 12;
    final cellHeight = mapSize.height / 16;
    final left = grid.x * cellWidth + 8;
    final top = grid.y * cellHeight + 8;
    final width = grid.w * cellWidth - 16;
    final height = grid.h * cellHeight - 16;

    return Positioned(
      left: left,
      top: top,
      width: width.clamp(42, mapSize.width),
      height: height.clamp(32, mapSize.height),
      child: Material(
        key: ValueKey('spatial-${node.id}'),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _nodeFill(node),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFF7AF0D4)
                    : const Color(0x99FFE1B0),
                width: selected ? 3 : 1,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x886BE6D1),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                if (node.nodeType == 'hanging_rod') const _HangerRail(),
                if (node.nodeType == 'drawer') const _DrawerLines(),
                if (node.needsSorting ||
                    node.visibility == 'hidden' ||
                    node.visibility == 'partially_hidden')
                  const Positioned(right: 0, top: 0, child: _AlertMark()),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    node.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Text(
                    node.id.replaceFirst('W01-', ''),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFEFE0C9),
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _nodeFill(StorageNode node) {
    if (node.needsSorting || node.visibility == 'partially_hidden') {
      return const Color(0xFF9A4E35);
    }
    return switch (node.nodeType) {
      'hanging_rod' => const Color(0xFF24534D),
      'drawer' => const Color(0xFF5A3C27),
      'shelf_or_floor_cubby' => const Color(0xFF73402E),
      _ => const Color(0xFF8B6843),
    };
  }
}

class _WardrobeNodeDetail extends StatelessWidget {
  const _WardrobeNodeDetail({
    required this.model,
    required this.node,
    required this.childCount,
    required this.storedItems,
    required this.auditStatus,
    required this.onAuditStatusChanged,
    required this.onAddItem,
    required this.onItemPresenceChanged,
  });

  final WardrobeStorageModel model;
  final StorageNode node;
  final int childCount;
  final List<StoredWardrobeItem> storedItems;
  final _AuditStatus auditStatus;
  final ValueChanged<_AuditStatus> onAuditStatusChanged;
  final VoidCallback onAddItem;
  final void Function(int index, String status) onItemPresenceChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF181411),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF6AD8C5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BlueprintTag(text: '节点详情'),
            const SizedBox(height: 16),
            Text(
              '现实位置',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              node.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF7AD3C2),
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 18),
            _DetailRow(label: '节点 ID', value: node.id),
            _DetailRow(label: '现实路径', value: _nodePath(model, node)),
            _DetailRow(label: '节点类型', value: _nodeTypeLabel(node.nodeType)),
            _DetailRow(label: '访问方式', value: _accessLabel(node.accessPattern)),
            _DetailRow(label: '可见性', value: _visibilityLabel(node.visibility)),
            _DetailRow(label: '顺序规则', value: _axisLabel(node.orderAxis)),
            _DetailRow(label: '子节点', value: '$childCount 个'),
            if (node.grid != null)
              _DetailRow(
                label: '空间坐标',
                value:
                    'x${node.grid!.x} y${node.grid!.y} / ${node.grid!.w}x${node.grid!.h}',
              ),
            const SizedBox(height: 16),
            _InventorySummaryCard(node: node, items: storedItems),
            const SizedBox(height: 16),
            _StoredItemsPanel(
              items: storedItems,
              onAddItem: onAddItem,
              onItemPresenceChanged: onItemPresenceChanged,
            ),
            const SizedBox(height: 16),
            _AuditStatusPanel(
              node: node,
              status: auditStatus,
              onChanged: onAuditStatusChanged,
            ),
            const SizedBox(height: 16),
            _NextActionCard(node: node),
          ],
        ),
      ),
    );
  }
}

class _InventorySummaryCard extends StatelessWidget {
  const _InventorySummaryCard({required this.node, required this.items});

  final StorageNode node;
  final List<StoredWardrobeItem> items;

  @override
  Widget build(BuildContext context) {
    final totalCount = items.length;
    final presentCount = items
        .where((item) => item.presenceStatus == 'present')
        .length;
    final missingCount = items
        .where((item) => item.presenceStatus == 'missing')
        .length;
    final confirmedCount = presentCount + missingCount;
    final unknownCount = totalCount - confirmedCount;

    return DecoratedBox(
      key: ValueKey('inventory-summary-${node.id}'),
      decoration: BoxDecoration(
        color: const Color(0xFF203A34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6AD8C5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '区域盘点',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InventoryMetric(text: '应有 $totalCount 件'),
                _InventoryMetric(text: '已确认 $confirmedCount 件'),
                _InventoryMetric(text: '缺失 $missingCount 件'),
                _InventoryMetric(text: '未确认 $unknownCount 件'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryMetric extends StatelessWidget {
  const _InventoryMetric({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x3322FFE0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x556AD8C5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFFD7FFF6),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AuditStatusPanel extends StatelessWidget {
  const _AuditStatusPanel({
    required this.node,
    required this.status,
    required this.onChanged,
  });

  final StorageNode node;
  final _AuditStatus status;
  final ValueChanged<_AuditStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF231C17),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4F5C53)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '盘点状态',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '当前状态：${_auditStatusLabel(status)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFD7FFF6),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<_AuditStatus>(
              showSelectedIcon: false,
              selected: {status},
              onSelectionChanged: (selection) => onChanged(selection.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? const Color(0xFF12201C)
                      : const Color(0xFFE7DAC7);
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? const Color(0xFF7AD3C2)
                      : const Color(0xFF2E2925);
                }),
                side: WidgetStateProperty.all(
                  const BorderSide(color: Color(0xFF6AD8C5)),
                ),
              ),
              segments: [
                ButtonSegment(
                  value: _AuditStatus.verified,
                  label: Text(
                    '已盘点',
                    key: ValueKey('status-verified-${node.id}'),
                  ),
                ),
                ButtonSegment(
                  value: _AuditStatus.needsSorting,
                  label: Text(
                    '待整理',
                    key: ValueKey('status-sorting-${node.id}'),
                  ),
                ),
                ButtonSegment(
                  value: _AuditStatus.unknown,
                  label: Text(
                    '未确认',
                    key: ValueKey('status-unknown-${node.id}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.item, required this.onTap});

  final StoredWardrobeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF231C17),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '位置：${item.nodeName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD7C3A5),
                ),
              ),
              if (_itemAttributeSummary(item).isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '属性：${_itemAttributeSummary(item)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD7C3A5),
                  ),
                ),
              ],
              if (item.locationIndex > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '空间序号：第 ${item.locationIndex} 件',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD7C3A5),
                  ),
                ),
              ],
              if (item.primaryPhotoRef.isNotEmpty) ...[
                const SizedBox(height: 6),
                const _StoredPhotoEvidenceBadge(),
              ],
              const SizedBox(height: 6),
              Text(
                '盘点确认：${_presenceStatusLabel(item.presenceStatus)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFD7FFF6),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoredItemsPanel extends StatelessWidget {
  const _StoredItemsPanel({
    required this.items,
    required this.onAddItem,
    required this.onItemPresenceChanged,
  });

  final List<StoredWardrobeItem> items;
  final VoidCallback onAddItem;
  final void Function(int index, String status) onItemPresenceChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF231C17),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4F5C53)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '已放入衣服',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  key: const ValueKey('add-item-button'),
                  onPressed: onAddItem,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF7AD3C2),
                  ),
                  child: const Text('放入衣服'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(
                '这个位置还没有录入衣服。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD7C3A5),
                ),
              )
            else
              for (final entry in items.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _StoredItemCard(
                    item: entry.$2,
                    index: entry.$1,
                    onPresenceChanged: onItemPresenceChanged,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _StoredItemCard extends StatelessWidget {
  const _StoredItemCard({
    required this.item,
    required this.index,
    required this.onPresenceChanged,
  });

  final StoredWardrobeItem item;
  final int index;
  final void Function(int index, String status) onPresenceChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('stored-item-card-${item.nodeId}-$index'),
      color: const Color(0xFF2E2925),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showClothingDetailSheet(context, item, index),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '位置：${item.nodeName}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFFD7C3A5)),
              ),
              if (_itemAttributeSummary(item).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '属性：${_itemAttributeSummary(item)}',
                  key: ValueKey(
                    'stored-item-detail-summary-${item.nodeId}-$index',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD7C3A5),
                  ),
                ),
              ],
              if (_itemBrandSizeSummary(item).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '品牌尺码：${_itemBrandSizeSummary(item)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD7C3A5),
                  ),
                ),
              ],
              if (item.locationIndex > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '空间序号：第 ${item.locationIndex} 件',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD7C3A5),
                  ),
                ),
              ],
              if (item.visualSignature.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '视觉身份：${item.visualSignature}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD7C3A5),
                  ),
                ),
              ],
              if (item.primaryPhotoRef.isNotEmpty) ...[
                const SizedBox(height: 4),
                _StoredPhotoEvidenceBadge(
                  key: ValueKey(
                    'stored-item-photo-evidence-${item.nodeId}-$index',
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '盘点确认：${_presenceStatusLabel(item.presenceStatus)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFD7FFF6),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '映射状态：${_twinStatusLabel(item.twinStatus)} / 最近确认：${_lastConfirmedLabel(item.lastConfirmedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFD7FFF6),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    key: ValueKey('presence-present-${item.nodeId}-$index'),
                    onPressed: () => onPresenceChanged(index, 'present'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7AD3C2),
                      side: const BorderSide(color: Color(0xFF6AD8C5)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('还在'),
                  ),
                  OutlinedButton(
                    key: ValueKey('presence-missing-${item.nodeId}-$index'),
                    onPressed: () => onPresenceChanged(index, 'missing'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFC45C),
                      side: const BorderSide(color: Color(0xFFFFC45C)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('不在'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showClothingDetailSheet(
  BuildContext context,
  StoredWardrobeItem item,
  int index, {
  VoidCallback? onConfirmPresent,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF181411),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _ClothingDetailSheet(
        item: item,
        index: index,
        onConfirmPresent: onConfirmPresent,
      );
    },
  );
}

class _ClothingDetailSheet extends StatelessWidget {
  const _ClothingDetailSheet({
    required this.item,
    required this.index,
    this.onConfirmPresent,
  });

  final StoredWardrobeItem item;
  final int index;
  final VoidCallback? onConfirmPresent;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: ValueKey('clothing-detail-sheet-${item.nodeId}-$index'),
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BlueprintTag(text: '衣服详情'),
          const SizedBox(height: 14),
          Text(
            item.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: '当前位置', value: item.nodeName),
          _DetailRow(label: '定位码', value: _itemLocationCode(item)),
          _DetailRow(label: '现实找法', value: _itemLocationGuidance(item)),
          if (_itemAttributeSummary(item).isNotEmpty)
            _DetailRow(label: '衣服属性', value: _itemAttributeSummary(item)),
          if (_itemBrandSizeSummary(item).isNotEmpty)
            _DetailRow(label: '品牌尺码', value: _itemBrandSizeSummary(item)),
          if (item.visualSignature.isNotEmpty)
            _DetailRow(label: '视觉身份', value: item.visualSignature),
          _DetailRow(label: '映射状态', value: _twinStatusLabel(item.twinStatus)),
          _DetailRow(
            label: '最近确认',
            value: _lastConfirmedLabel(item.lastConfirmedAt),
          ),
          const SizedBox(height: 8),
          Text(
            _itemLocationGuidance(item),
            key: ValueKey(
              'clothing-detail-location-guidance-${item.nodeId}-$index',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFD7FFF6),
              fontWeight: FontWeight.w800,
            ),
          ),
          if (onConfirmPresent != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: ValueKey(
                  'confirm-present-from-detail-${item.nodeId}-$index',
                ),
                onPressed: () {
                  onConfirmPresent!();
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7AD3C2),
                  foregroundColor: const Color(0xFF12201C),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('重新确认还在'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({required this.node});

  final StorageNode node;

  @override
  Widget build(BuildContext context) {
    final action = node.needsSorting
        ? '先整理并拍近照，再拆成更小的叠放组。'
        : node.nodeType == 'drawer'
        ? '打开抽屉拍照后，再建抽屉内部空间节点。'
        : node.nodeType == 'hanging_rod'
        ? '按从左到右录入挂衣序列，先粗分衣物组。'
        : '拍一张近照，确认这一格里的取放顺序。';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF253B36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6AD8C5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '下一步动作',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFFE8FFF9),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFD7FFF6),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadState extends StatelessWidget {
  const _LoadState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message, textAlign: TextAlign.center));
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFA79483),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueprintTag extends StatelessWidget {
  const _BlueprintTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x2222FFE0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x886AD8C5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFFE8FFF9),
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
      ),
    );
  }
}

class _SignalDot extends StatelessWidget {
  const _SignalDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFF7AD3C2),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Color(0xAA7AD3C2), blurRadius: 14, spreadRadius: 2),
        ],
      ),
    );
  }
}

class _AlertMark extends StatelessWidget {
  const _AlertMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC45C),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

class _HangerRail extends StatelessWidget {
  const _HangerRail();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFE9D3AC),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (index) => Container(
                  width: 8,
                  height: 34 + (index.isEven ? 16 : 0),
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? const Color(0xFF111614)
                        : const Color(0xFF3A2B25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerLines extends StatelessWidget {
  const _DrawerLines();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD7B98B),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _WardrobeGridPainter extends CustomPainter {
  const _WardrobeGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x22FFE8C2)
      ..strokeWidth = 1;
    final dividerPaint = Paint()
      ..color = const Color(0xCCFFE1B0)
      ..strokeWidth = 3;

    for (var i = 1; i < 12; i++) {
      final x = size.width * i / 12;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var i = 1; i < 16; i++) {
      final y = size.height * i / 16;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      dividerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanAtmospherePainter extends CustomPainter {
  const _ScanAtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scanPaint = Paint()
      ..color = const Color(0x227AD3C2)
      ..strokeWidth = 1;
    for (var y = 18.0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanPaint);
    }

    final glowPaint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x5558CDB9), Color(0x00201913)],
          ).createShader(
            Rect.fromLTWH(
              size.width * .55,
              -size.height * .35,
              size.width * .7,
              size.height * .9,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .1),
      size.width * .35,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _nodePath(WardrobeStorageModel model, StorageNode node) {
  final names = <String>[node.name];
  var parentId = node.parentId;
  while (parentId != null) {
    final parent = model.nodeById(parentId);
    names.insert(0, parent.name);
    parentId = parent.parentId;
  }
  return names.join(' / ');
}

String _nodeTypeLabel(String type) {
  return switch (type) {
    'wardrobe' => '衣橱',
    'shelf' => '层板',
    'stack' => '叠放组',
    'hanging_rod' => '挂衣杆',
    'drawer' => '抽屉',
    'shelf_or_floor_cubby' => '层板或地格',
    _ => '未知类型（$type）',
  };
}

String _accessLabel(String accessPattern) {
  return switch (accessPattern) {
    'shelf' => '层板取放',
    'shelf_low' => '低位层板取放',
    'shelf_reach_high' => '高位层板取放',
    'stack_access' => '叠放翻找取放',
    'hanging' => '挂衣取放',
    'drawer_pull' => '抽屉抽拉',
    'low_reach' => '低位取放',
    'open_when_door_open' => '开门后可见',
    'sliding_or_hinged_door' => '推拉或铰链门',
    _ => '未知取放方式（$accessPattern）',
  };
}

String _visibilityLabel(String visibility) {
  return switch (visibility) {
    'visible' => '可见',
    'partially_visible' => '部分可见',
    'partially_hidden' => '部分隐藏',
    'hidden' => '隐藏',
    'mixed' => '混合',
    _ => '未知可见性（$visibility）',
  };
}

String _axisLabel(String? axis) {
  return switch (axis) {
    'left_to_right' => '从左到右',
    'top_to_bottom' => '从上到下',
    'front_to_back' => '从前到后',
    'mixed' => '混合顺序',
    null => '无',
    _ => '未知顺序（$axis）',
  };
}

_AuditStatus _defaultAuditStatusFor(StorageNode node) {
  if (node.needsSorting) {
    return _AuditStatus.needsSorting;
  }

  return _AuditStatus.unknown;
}

String _auditStatusLabel(_AuditStatus status) {
  return switch (status) {
    _AuditStatus.verified => '已盘点',
    _AuditStatus.needsSorting => '待整理',
    _AuditStatus.unknown => '未确认',
  };
}

_AuditStatus _auditStatusFromStorage(String status) {
  return switch (status) {
    'verified' => _AuditStatus.verified,
    'needsSorting' => _AuditStatus.needsSorting,
    _ => _AuditStatus.unknown,
  };
}

String _auditStatusStorageValue(_AuditStatus status) {
  return switch (status) {
    _AuditStatus.verified => 'verified',
    _AuditStatus.needsSorting => 'needsSorting',
    _AuditStatus.unknown => 'unknown',
  };
}

String _presenceStatusLabel(String status) {
  return switch (status) {
    'present' => '还在',
    'missing' => '不在',
    _ => '未确认',
  };
}

String _itemSearchText(StoredWardrobeItem item) {
  return [
    item.name,
    item.category,
    item.color,
    item.material,
    item.brand,
    item.size,
    item.visualSignature,
    item.nodeName,
  ].where((value) => value.trim().isNotEmpty).join(' ').toLowerCase();
}

String _itemAttributeSummary(StoredWardrobeItem item) {
  return [
    item.category,
    item.color,
    item.material,
  ].where((value) => value.trim().isNotEmpty).join(' / ');
}

String _itemBrandSizeSummary(StoredWardrobeItem item) {
  return [
    item.brand,
    item.size,
  ].where((value) => value.trim().isNotEmpty).join(' / ');
}

String _itemLocationCode(StoredWardrobeItem item) {
  return _locationCodeForNode(item.nodeId, item.locationIndex);
}

String _itemLocationGuidance(StoredWardrobeItem item) {
  return _locationGuidanceForNode(
    item.nodeId,
    item.nodeName,
    item.locationIndex,
  );
}

String _locationCodeForNode(String nodeId, int locationIndex) {
  final nodeCode = nodeId.replaceFirst('W01-', '');
  if (locationIndex <= 0) {
    return nodeCode;
  }
  return '$nodeCode-$locationIndex';
}

String _locationGuidanceForNode(
  String nodeId,
  String nodeName,
  int locationIndex,
) {
  final index = locationIndex;
  if (index <= 0) {
    return '先确认这件衣服所在的具体顺序。';
  }
  if (nodeId.contains('-H')) {
    return '在$nodeName，按从左到右找第 $index 件。';
  }
  if (nodeId.contains('-D')) {
    return '打开$nodeName，按从前到后找第 $index 件。';
  }
  if (nodeId.contains('-S')) {
    return '在$nodeName，按从上到下找第 $index 件。';
  }
  return '在$nodeName，找第 $index 件。';
}

String _twinStatusLabel(String status) {
  return switch (status) {
    'mapped' => '已映射',
    'exception' => '异常',
    'pending' => '待确认',
    _ => '待确认',
  };
}

String _lastConfirmedLabel(String value) {
  if (value.trim().isEmpty) {
    return '尚未确认';
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '${parsed.year}-$month-$day $hour:$minute';
}
