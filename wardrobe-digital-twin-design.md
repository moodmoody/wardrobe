# 衣橱数字孪生 App 设计文档

## 1. 设计目标

原始方案已经具备一个本地优先衣橱管理 App 的基础能力：拍照录入、分类标签、穿搭搭配、穿着统计、图片流水线、SQLite 本地数据库和后续云同步扩展。

但如果要升级为类似 digital twins 的产品，核心不只是“把衣服拍进 App”，而是建立一个可信的映射关系：

> 现实世界中的每一件具体衣服，都能在数字世界中找到唯一、稳定、可验证的数字实例。

因此，产品目标应从“衣物资料库”升级为“现实衣橱的数字镜像”。App 不只记录衣服的样子，还要持续回答：

- 它是谁？
- 它在哪里？
- 它是否还存在？
- 它和哪个现实物体绑定？
- 这个绑定关系有多可信？
- 上一次确认现实状态是什么时候？

## 2. 原方案理解

原 PPT 的产品设计可以概括为四个核心模块：

- 拍照录入：通过拍照或相册导入衣物图片，并进行裁剪、压缩、存档。
- 分类标签：记录品类、颜色、季节、场合、品牌、自定义标签等信息。
- 穿搭搭配：把多个单品组合成 Outfit，并收藏常用搭配。
- 穿着统计：记录穿着次数、最后穿着时间、单次穿着成本等数据。

技术上，原方案采用：

- Flutter 作为跨端框架。
- Drift/SQLite 作为本地数据库。
- Riverpod 作为状态管理。
- image_picker、image_cropper、flutter_image_compress 作为图片流水线。
- 后续可扩展 Supabase 云同步。

这些设计适合作为 MVP 基础。但它目前更像“衣物管理数据库”，还不是严格意义上的“数字孪生衣橱”。缺失的关键层是：物理身份层。

## 3. 核心问题：如何解决一对一映射

一对一映射的难点在于：现实衣物不是 SKU，也不是照片。

例如，用户有两件完全一样的白色 T 恤。它们品牌、颜色、尺码、购买时间、图片可能都一样，但在现实世界中，它们是两件不同的物品。如果系统只按照片或分类管理，就无法区分它们。

因此，数字孪生的核心对象不应该是“衣服类型”，而应该是“衣物实例”。

推荐定义：

```text
Clothing Item Type  = 一类衣服，例如白色 T 恤
Clothing Item Instance = 一件具体衣服，例如白色 T 恤 #A
```

系统中每一件现实衣物都应该拥有一个永久的 `physical_instance_id`。这个 ID 不依赖名称、照片、分类或标签，而是代表现实世界中的那个具体对象。

一对一映射的解决公式：

```text
唯一实例 ID + 多证据绑定 + 置信度 + 人工确认 + 可选物理锚点
```

## 4. 渐进式 Twin Mapping 方案

推荐采用渐进式映射，而不是一开始强制用户购买硬件或给所有衣服贴标签。

映射能力分为三层。

### Level 1：软映射

适合普通用户和普通衣物。

依赖内容：

- 单品主图。
- 基础标签，例如品类、颜色、季节、场合、品牌。
- 用户手动确认。
- 穿着记录和使用历史。

特点：

- 门槛低，适合 MVP。
- 不需要额外硬件。
- 准确度依赖用户确认。
- 遇到相似衣物时容易混淆。

### Level 2：半强映射

适合相似衣物较多、用户希望提高准确度的场景。

依赖内容：

- 多角度照片：正面、背面、侧面。
- 细节照片：领标、袖口、纽扣、拉链、图案、纹理、瑕疵。
- 相似度识别结果。
- 用户二次确认。

特点：

- 不强制硬件，但比单张照片可靠。
- 能处理部分相似衣物。
- 适合后续接入本地或云端视觉模型。

### Level 3：强绑定

适合贵重衣物、常穿衣物、易混淆衣物、租赁或共享衣橱场景。

依赖内容：

- NFC 标签。
- RFID 标签。
- 二维码洗标贴。
- 唯一锚点 UID。

特点：

- 扫描即可确认现实对象。
- 准确度最高。
- 适合数字孪生叙事中的“强映射”。
- 不适合 MVP 一开始强制使用，否则会提高用户门槛。

推荐策略：

```text
默认使用 Level 1。
对易混淆或高价值衣物升级到 Level 2。
对关键衣物提供 Level 3 强绑定。
```

## 5. Twin 状态设计

每件衣服都应该有一个数字孪生状态，而不是只有普通的 `active / archived`。

建议状态：

```text
unbound      未绑定：只有资料卡，尚未确认现实对应物
mapped       已映射：有照片和特征，用户确认过
anchored     强绑定：已绑定 NFC / RFID / 二维码
review       待确认：系统发现相似或长期未确认，需要用户复核
missing      失联：盘点时找不到，现实状态不确定
retired      已退役：丢弃、捐赠、卖出、损坏或不再使用
```

这些状态让 App 能表达现实世界和数字世界之间的一致性。

例如：

- 用户新建了一件衣服，但还没拍细节图：`unbound`。
- 用户拍了主图和细节图，并确认过：`mapped`。
- 用户贴了 NFC 标签：`anchored`。
- 用户 180 天没有穿过，也没有盘点确认：`review`。
- 用户盘点时找不到：`missing`。
- 用户确认捐赠：`retired`。

## 6. Twin Confidence 置信度

除了状态，还应有一个 `twin_confidence` 字段，表示当前映射关系有多可信。

示例规则：

```text
基础资料完整：+10
主图存在：+20
细节图 >= 2 张：+20
用户最近 30 天确认过：+20
有 NFC / QR / RFID：+40
长期未确认：-20
盘点未找到：-50
存在高度相似单品：-15
```

置信度不一定需要一开始展示为具体分数，也可以转成用户友好的状态：

```text
低可信：需要确认
中可信：已映射
高可信：强绑定
```

在产品体验上，它可以用于：

- 提醒用户补拍细节图。
- 在记录穿着时提示相似单品。
- 在盘点时优先检查低置信度衣物。
- 在统计中展示衣橱数据可信度。

## 7. 用户流程设计

### 7.1 添加衣物流程

原流程是：

```text
拍照 -> 裁剪 -> 压缩 -> 填标签 -> 写入数据库
```

升级后建议为：

```text
创建数字实例
-> 拍主图
-> 拍关键细节
-> 填基础信息
-> 选择是否添加物理锚点
-> 生成 Twin 状态和置信度
```

关键变化：

- 创建时即生成 `physical_instance_id`。
- 图片不再只是展示图，也是身份识别证据。
- 细节图成为一对一映射的重要证据。
- NFC / QR 不强制，但可作为增强选项。

### 7.2 日常穿着记录流程

推荐流程：

```text
选择衣物 / 扫描锚点 / 拍照识别
-> 系统给出候选单品
-> 用户确认现实对象
-> 记录穿着日期、场合、天气、备注
-> 刷新 twin_status 和 twin_confidence
```

这样每一次穿着记录都不只是统计行为，也是一次现实状态同步。

### 7.3 衣橱盘点流程

数字孪生产品非常需要“盘点”功能。

推荐流程：

```text
进入盘点模式
-> 按衣柜位置逐件确认
-> 拍照或扫描锚点
-> 标记存在、移动、失联、退役
-> 生成衣橱健康报告
```

盘点功能可以解决几个问题：

- 数字衣橱中有，但现实中找不到。
- 现实中存在，但没有录入 App。
- 衣服已经捐赠或丢弃，但 App 中还在 active。
- 衣服位置变化，例如从主衣柜移动到行李箱。

## 8. 数据模型优化

原数据模型包括：

- `clothing_items`
- `outfits`
- `wear_records`
- `outfit_clothing_items`
- `wear_record_items`

建议在此基础上增加身份层和事件层。

### 8.1 clothing_items

```text
clothing_items
- id TEXT PK
- physical_instance_id TEXT UNIQUE
- name TEXT
- brand TEXT
- category TEXT
- colors TEXT
- seasons TEXT
- occasions TEXT
- tags TEXT
- purchase_price REAL
- image_path TEXT
- thumbnail_path TEXT
- status TEXT
- twin_status TEXT
- twin_confidence INTEGER
- is_favorite BOOLEAN
- created_at INTEGER
- updated_at INTEGER
```

说明：

- `id` 是数据库主键。
- `physical_instance_id` 是现实衣物实例 ID。
- `twin_status` 表示数字孪生状态。
- `twin_confidence` 表示映射可信度。

### 8.2 item_identity_evidence

```text
item_identity_evidence
- id TEXT PK
- clothing_item_id TEXT FK
- evidence_type TEXT
- value TEXT
- confidence INTEGER
- created_at INTEGER
```

`evidence_type` 可选值：

```text
main_photo
front_photo
back_photo
detail_photo
label_photo
manual_confirm
visual_match
nfc_scan
qr_scan
rfid_scan
```

说明：

- 所有能证明“现实这件 = 数字这件”的信息都放在这里。
- 后续接入 AI 识别时，不需要改主表，只需要新增证据类型。

### 8.3 physical_anchors

```text
physical_anchors
- id TEXT PK
- clothing_item_id TEXT FK
- anchor_type TEXT
- anchor_uid TEXT UNIQUE
- active BOOLEAN
- bound_at INTEGER
- unbound_at INTEGER
```

`anchor_type` 可选值：

```text
nfc
rfid
qr
barcode
```

说明：

- 一个衣物可以没有锚点。
- 一个衣物可以更换锚点。
- 锚点要支持解绑，避免标签损坏或转移后数据混乱。

### 8.4 wardrobe_locations

```text
wardrobe_locations
- id TEXT PK
- name TEXT
- type TEXT
- sort_order INTEGER
- created_at INTEGER
```

示例：

```text
主衣柜
抽屉
待洗区
行李箱
换季收纳箱
已捐赠
```

### 8.5 item_location_events

```text
item_location_events
- id TEXT PK
- clothing_item_id TEXT FK
- location_id TEXT FK
- event_type TEXT
- created_at INTEGER
- notes TEXT
```

`event_type` 可选值：

```text
placed
removed
scanned
moved
missing
retired
restored
```

说明：

- 不建议只在 `clothing_items` 上保存当前 location。
- 位置变化最好做成事件流，方便追踪现实衣物状态变化。

## 9. 页面与交互优化

### 9.1 衣橱列表

列表卡片建议增加：

- 绑定状态标识。
- 最近确认时间。
- 当前所在位置。
- 低置信度提醒。

示例：

```text
白色牛津衬衫
已映射 · 主衣柜 · 12 天前确认
```

或：

```text
黑色羊毛大衣
强绑定 · NFC · 换季收纳箱
```

### 9.2 单品详情页

详情页应成为数字孪生的主界面。

建议模块：

- 主图。
- 细节图。
- Twin 状态。
- Twin Confidence。
- 绑定证据。
- 现实位置。
- 穿着历史。
- 关联搭配。
- 操作按钮：记录穿着、重新确认、绑定锚点、移动位置、退役。

### 9.3 添加单品页

添加流程建议从“填表”变成“建立身份”。

页面重点：

- 先拍主图。
- 引导补拍 1-3 张关键细节。
- 允许跳过细节，但降低置信度。
- 最后询问是否添加 NFC / QR 强绑定。

### 9.4 盘点模式

盘点模式可以是 Phase 2 的核心差异化能力。

功能：

- 按位置盘点。
- 批量确认存在。
- 快速标记找不到。
- 快速移动位置。
- 生成盘点报告。

报告示例：

```text
本次盘点确认 86 件衣物
发现 4 件低置信度衣物
2 件衣物标记为失联
7 件衣物超过 180 天未穿
```

## 10. 技术架构调整

原技术栈可以保留：

```text
Flutter
Riverpod
Drift / SQLite
go_router
image_picker
image_cropper
flutter_image_compress
fl_chart
Supabase optional
```

建议新增几个服务层：

```text
IdentityService
负责生成 physical_instance_id、计算 twin_confidence、更新 twin_status。

EvidenceService
负责写入和读取身份绑定证据。

AnchorService
负责 NFC / QR / RFID 锚点绑定、解绑、扫描确认。

InventoryAuditService
负责衣橱盘点、失联判断、位置事件生成。

LocationService
负责现实位置管理和位置事件记录。
```

Riverpod provider 可以按领域拆分：

```text
wardrobeProvider
itemIdentityProvider
anchorProvider
locationProvider
inventoryAuditProvider
statisticsProvider
```

## 11. MVP 范围建议

不要一开始做完整 RFID 衣柜，也不要强制所有衣服贴 NFC。

MVP 应该做：

- 衣物实例 ID。
- 主图和细节图。
- `twin_status`。
- `twin_confidence`。
- 手动确认。
- 相似衣物提示的基础规则。
- 单品详情页展示绑定状态。
- 穿着记录时刷新确认时间。

Phase 2 再做：

- 盘点模式。
- 位置事件。
- 低置信度提醒。
- 失联状态。

Phase 3 再做：

- 二维码标签。
- NFC 标签。
- 扫描确认。
- 强绑定状态。

Phase 4 再做：

- 视觉相似度识别。
- AI 候选匹配。
- 云同步。
- 多设备协同。

## 12. 关键验证指标

MVP 应验证以下问题：

- 用户能否区分两件相似衣物？
- 用户是否愿意补拍细节图？
- 细节图是否真的帮助后续确认？
- 用户是否理解“绑定状态”？
- 穿着记录是否能顺便完成现实状态确认？
- 盘点是否能发现数字衣橱和现实衣橱的不一致？
- 强绑定是否只服务高价值场景，而不是拖慢普通录入？

建议测试场景：

```text
5 件普通衣物
2 件高度相似衣物
1 件贵重衣物
2 套穿搭
3 次穿着记录
1 次盘点
1 件衣物标记失联
1 件衣物标记退役
```

如果 App 能在这个小样本中准确维护现实和数字之间的关系，就说明数字孪生的核心闭环成立。

## 13. 产品叙事建议

原来的产品叙事是：

```text
数字化衣橱管理，清晰了解你的穿衣状态。
```

升级后可以改为：

```text
把现实衣橱映射到数字世界，让每一件衣服都有可追踪的数字分身。
```

或更产品化一点：

```text
不只是记录衣服，而是同步你的真实衣橱。
```

核心卖点可以写成：

- 每件衣服一个唯一数字实例。
- 普通衣物低门槛建档。
- 重要衣物可用 NFC / QR 强绑定。
- 穿着、盘点、位置变化持续刷新现实状态。
- 统计结果基于可信的衣物身份，而不是混乱的照片相册。

## 14. 最终结论

要解决现实衣橱和数字衣橱的一对一映射，不能只依赖拍照识别，也不能一开始强制硬件绑定。

最合理的方案是渐进式数字孪生：

```text
唯一实例 ID
+ 多证据绑定
+ Twin Confidence
+ 用户确认
+ 可选 NFC / QR / RFID 物理锚点
```

这套方案的优点是：

- MVP 可以低成本启动。
- 高价值场景可以增强准确度。
- 数据模型能支撑后续 AI 识别和云同步。
- 用户能理解并参与维护映射关系。
- 产品概念从“衣物管理”升级为真正的“衣橱数字孪生”。

## 15. 现实衣橱空间建模

前面的设计主要解决“现实衣物和数字单品的一对一身份映射”。但真正的衣橱数字孪生还需要第二层能力：现实衣橱空间建模。

也就是说，系统不只要知道“这件衣服是谁”，还要知道：

- 它属于哪个衣柜？
- 在衣柜的哪一层？
- 在这一层的哪个区域？
- 是挂着、叠着、卷着，还是放在盒子里？
- 如果和很多衣服叠在一起，它大概在第几件？
- 这个位置上次是什么时候确认的？

### 15.1 建模原则

现实衣橱不适合一开始做精确三维坐标，因为普通用户不会愿意维护厘米级位置，而且衣服经常移动、折叠、遮挡、堆叠。

更合理的方式是采用“语义空间地址”。

推荐模型：

```text
衣柜 Wardrobe
-> 区域 Zone
-> 容器/层板 Compartment
-> 存放组 Storage Group
-> 衣物实例 Item Instance
```

例如：

```text
主衣柜
-> 上层
-> 左侧层板
-> 第 2 叠
-> 从上往下第 3 件
-> 白色牛津衬衫
```

这个地址不需要精确到坐标，但足够帮助用户找到衣服，也足够让数字世界反映现实结构。

### 15.2 现实空间层级

建议数据结构如下：

```text
wardrobes
- id
- name
- room
- description

wardrobe_zones
- id
- wardrobe_id
- name
- level
- side
- sort_order

compartments
- id
- zone_id
- name
- type
- row_index
- column_index

storage_groups
- id
- compartment_id
- name
- storage_type
- position_index
- direction

item_storage_assignments
- id
- clothing_item_id
- storage_group_id
- order_index
- order_direction
- visibility
- accessibility
- location_confidence
- last_verified_at
```

字段说明：

- `wardrobe` 表示一个现实衣柜，例如“主卧衣柜”。
- `zone` 表示衣柜中的大区域，例如“上层”“中层”“挂衣区”“抽屉区”。
- `compartment` 表示具体隔间，例如“上层左侧层板”。
- `storage_group` 表示一组衣物，例如“一叠衣服”“一个收纳盒”“一排挂衣”。
- `item_storage_assignment` 表示某件衣服在某个存放组里的位置。

### 15.3 编号方式

编号不应该只给衣服编号，也应该给衣柜空间编号。

推荐使用分层编号：

```text
W01-Z02-C01-G03-I04
```

含义：

```text
W01 = 第 1 个衣柜
Z02 = 第 2 个区域，例如上层
C01 = 该区域第 1 个隔间，例如左侧层板
G03 = 第 3 个存放组，例如第 3 叠衣服
I04 = 该叠中第 4 件衣服
```

对用户展示时不需要显示这么机械的编号，可以显示成自然语言：

```text
主衣柜 / 上层 / 左侧层板 / 第 3 叠 / 从上往下第 4 件
```

系统内部保留结构化编号，方便排序、搜索和同步。

### 15.4 叠放衣服的建模

叠放是现实衣橱中最重要也最难的问题。

例如“一件衣服放在上层，和很多衣服叠在一起”，数字世界中不应该只记录为：

```text
位置：上层
```

这样太粗。应该记录为：

```text
衣柜：主衣柜
区域：上层
隔间：左侧层板
存放组：第 2 叠
叠放方向：top_to_bottom
顺序：第 3 件
可见性：hidden
位置置信度：medium
上次确认：2026-06-08
```

在 UI 中可以表达为：

```text
主衣柜 · 上层左侧 · 第 2 叠 · 从上往下第 3 件
```

注意：叠放顺序不一定长期准确，所以它应该有 `location_confidence`。当用户拿出或放回衣服后，系统可以提示是否更新这叠衣服的顺序。

### 15.5 存放组类型

不同存放方式需要不同的位置模型。

建议支持：

```text
stack        叠放，例如 T 恤、毛衣
hanger_row   挂衣排，例如衬衫、大衣
drawer       抽屉，例如内衣、袜子
box          收纳盒，例如换季衣物
shelf        层板散放
laundry      待洗区
suitcase     行李箱
```

不同类型的位置字段不同：

```text
stack:
- order_index
- order_direction: top_to_bottom

hanger_row:
- order_index
- order_direction: left_to_right

drawer:
- section_name
- approximate_count

box:
- box_label
- sealed
```

### 15.6 现实编号和数字编号如何连接

不建议一开始给每件衣服都贴标签。更自然的做法是先给“空间”贴标签。

例如：

- 主衣柜贴一个 W01 标签。
- 上层左侧层板贴一个 C01 标签。
- 收纳盒贴一个 B03 二维码。
- 贵重衣物再单独贴 NFC 或二维码。

这样用户整理衣橱时可以：

```text
扫描上层左侧层板二维码
-> App 打开该区域的数字视图
-> 用户看到这里应该有 3 叠衣服
-> 点开第 2 叠
-> 查看从上到下的衣物顺序
```

这比要求每件衣服都贴标签更容易落地。

### 15.7 数字世界中的展示方式

数字衣橱不应该只是网格列表，还应该有“空间视图”。

推荐三种视图：

```text
列表视图：按衣物浏览
空间视图：按衣柜结构浏览
盘点视图：按现实整理动作浏览
```

空间视图示例：

```text
主衣柜

上层
[左侧层板] [中间层板] [右侧层板]

左侧层板
- 第 1 叠：黑色 T、灰色 T、白色 T
- 第 2 叠：牛津衬衫、针织衫、卫衣
- 收纳盒 B03：换季毛衣 6 件
```

当用户点开“第 2 叠”，可以看到：

```text
第 2 叠，从上往下：
1. 灰色卫衣
2. 米色针织衫
3. 白色牛津衬衫
4. 蓝色衬衫
```

如果顺序不确定，可以显示：

```text
顺序可能已变化 · 37 天未确认
```

### 15.8 放回衣服的交互

现实衣橱最大的问题不是录入，而是位置会变。

建议增加“放回”动作：

```text
用户记录穿着结束
-> App 问：已放回哪里？
-> 默认上次位置
-> 用户可选择：原位置 / 待洗区 / 行李箱 / 其他
```

如果选择原位置：

```text
主衣柜 / 上层左侧 / 第 2 叠 / 放到最上方
```

系统就能更新该叠的顺序：

```text
白色牛津衬衫 order_index = 1
其他衣物 order_index 顺延
```

这比让用户手动维护整叠衣服顺序更轻。

### 15.9 盘点如何更新空间模型

盘点时不要要求用户一次性精准录入所有位置。推荐按空间逐格确认。

流程：

```text
选择衣柜
-> 选择区域：上层
-> 选择隔间：左侧层板
-> App 显示该隔间的数字预期
-> 用户逐叠确认：存在 / 顺序变化 / 少了 / 多了
```

对于一叠衣服，可以支持三种确认方式：

```text
快速确认：这叠还在，不调整顺序
重新排序：拖拽调整从上到下顺序
拍照识别：拍一张当前叠放照片，作为新的位置证据
```

### 15.10 关键结论

现实衣橱建模的重点不是做一个精确 3D 衣柜，而是建立可维护的语义空间地址。

推荐最终模型：

```text
衣物身份映射：现实这件衣服 = 数字 Item Instance
空间位置映射：现实这个位置 = 数字 Wardrobe Location
叠放顺序映射：现实这一叠中的大概顺序 = 数字 Storage Assignment
```

对“一件衣服放在上层，和很多叠在一起”的表达应该是：

```text
Item: 白色牛津衬衫
Wardrobe: 主衣柜 W01
Zone: 上层 Z01
Compartment: 左侧层板 C01
Storage Group: 第 2 叠 G02
Order: 从上往下第 3 件
Confidence: medium
Last Verified: 2026-06-08
```

用户看到的是：

```text
白色牛津衬衫
位置：主衣柜 / 上层左侧 / 第 2 叠 / 从上往下第 3 件
状态：已映射，位置 37 天未确认
```

这才是现实衣橱和数字衣橱真正的一对一映射：既映射衣服，也映射衣服所在的现实空间结构。

## 16. 多样衣橱样式的映射方式

现实中的衣橱形态非常多，不能假设所有用户都是标准“衣柜 / 上层 / 左侧层板 / 第几叠”。常见情况包括：

- 双开门衣柜。
- 推拉门衣柜。
- 开放式挂衣架。
- 步入式衣帽间。
- 抽屉柜。
- 层板柜。
- 收纳箱。
- 行李箱。
- 鞋柜。
- 待洗衣篮。
- 床底收纳盒。

因此，底层模型不应该写死为 `wardrobes -> zones -> compartments`。更稳的方案是：使用递归的“存储节点 Storage Node”。

### 16.1 核心抽象：Storage Node

现实世界里的任何可存放衣物的东西，都可以是一个 `storage_node`。

例如：

```text
主卧衣柜        storage_node: wardrobe
上层层板        storage_node: shelf
左侧第 2 叠     storage_node: stack
收纳盒 B03      storage_node: box
抽屉 1          storage_node: drawer
挂衣杆          storage_node: hanging_rod
行李箱          storage_node: suitcase
待洗篮          storage_node: laundry_basket
```

节点可以嵌套节点，也可以直接放衣服。

例如：

```text
主衣柜
-> 上层层板
-> 收纳盒 B03
-> 第 1 叠毛衣
-> 灰色羊毛衫
```

或者：

```text
开放挂架
-> 左侧挂杆
-> 从左到右第 5 件
-> 黑色大衣
```

### 16.2 递归数据模型

推荐用一张 `storage_nodes` 表代替过于固定的 `wardrobe_zones / compartments / storage_groups`。

```text
storage_nodes
- id
- parent_id
- node_type
- name
- template_type
- sort_order
- grid_x
- grid_y
- grid_w
- grid_h
- order_axis
- access_pattern
- visibility
- mobility
- created_at
- updated_at
```

字段说明：

- `parent_id`：表示当前节点属于哪个上级节点。没有 parent 的是顶层存储单元。
- `node_type`：wardrobe、shelf、drawer、box、stack、hanging_rod、shoe_rack、suitcase、laundry_basket 等。
- `template_type`：来自哪个模板，例如 two_door_wardrobe、walk_in_closet、open_rack。
- `grid_x / grid_y / grid_w / grid_h`：用于数字界面里的粗略二维布局，不代表真实厘米坐标。
- `order_axis`：该节点内物品的顺序方向，例如 top_to_bottom、left_to_right、front_to_back。
- `access_pattern`：访问方式，例如 open、door、sliding_door、drawer_pull、box_lid。
- `visibility`：visible、covered、hidden。
- `mobility`：fixed、movable、portable。

衣服和空间的关系用 `item_placements` 表表达：

```text
item_placements
- id
- clothing_item_id
- storage_node_id
- order_index
- order_axis
- placement_confidence
- last_verified_at
- created_at
- updated_at
```

这样，一件衣服可以被放在任意类型的节点里，而不是只能放在“衣柜隔间”里。

### 16.3 衣橱模板

为了降低用户建模成本，App 不应该让用户从空白开始画衣柜，而应该提供模板。

推荐模板：

```text
two_door_wardrobe       双开门衣柜
sliding_door_wardrobe   推拉门衣柜
open_rack               开放挂衣架
walk_in_closet          步入式衣帽间
drawer_chest            抽屉柜
shelf_unit              层板柜
shoe_cabinet            鞋柜
storage_boxes           收纳箱组合
suitcase                行李箱
laundry_area            待洗区
```

用户选择模板后，系统自动生成初始节点。例如“双开门衣柜”可以生成：

```text
W01 主衣柜
-> 左侧挂衣区
-> 右侧层板区
-> 上层收纳区
-> 下层抽屉区
```

用户可以继续添加、删除、重命名节点。

### 16.4 不同衣橱样式如何映射

#### 双开门衣柜

```text
主衣柜 W01
-> 左门区域
-> 挂衣杆
-> 从左到右第 6 件
```

适合：衬衫、大衣、连衣裙。

#### 推拉门衣柜

```text
推拉门衣柜 W02
-> 左侧可见区
-> 中间层板
-> 第 2 叠
-> 从上往下第 3 件
```

注意：推拉门会导致一部分区域被遮挡，所以节点需要 `access_pattern = sliding_door`。

#### 开放挂架

```text
开放挂架 R01
-> 上方挂杆
-> 从左到右第 4 件
```

特点：可见性高，位置置信度下降较慢。

#### 抽屉柜

```text
抽屉柜 D01
-> 第 2 层抽屉
-> 左侧分区
-> 从前往后第 5 件
```

抽屉里的衣物通常不可见，需要 `visibility = hidden`。

#### 收纳箱

```text
收纳箱 B03
-> 换季毛衣组
-> 从上往下第 2 件
```

收纳箱可能在衣柜上层，也可能在床底，所以它本身也是可移动节点。

#### 步入式衣帽间

```text
衣帽间 WIC01
-> 左墙
-> 第二段挂杆
-> 从左到右第 8 件
```

步入式衣帽间适合使用二维平面图，但仍然是 storage_nodes 的组合。

### 16.5 数字世界中的展示

数字世界不应该只有一种衣柜图。应该有三种层级：

```text
结构树视图：展示所有 storage_nodes 的层级关系
平面视图：用 grid_x / grid_y 粗略展示衣橱布局
查找视图：直接告诉用户自然语言位置
```

例如查找视图：

```text
黑色大衣
位置：开放挂架 / 上方挂杆 / 从左到右第 4 件
可信度：高，7 天前确认
```

例如结构树视图：

```text
主衣柜
- 上层收纳区
  - 收纳箱 B03
    - 换季毛衣组
- 左侧挂衣区
  - 挂衣杆
- 右侧层板区
  - 第 1 叠 T 恤
  - 第 2 叠衬衫
```

### 16.6 设计结论

要适配现实中各种衣橱样式，不能把模型写死成某一种衣柜结构。

推荐底层统一为：

```text
Storage Node Tree + Item Placement
```

也就是：

```text
任何现实存储空间 = 一个 storage_node
任何衣服的位置 = 一个 item_placement
```

这样既能表达标准衣柜，也能表达开放挂架、抽屉、收纳箱、行李箱、衣帽间和临时待洗区。

最终用户看到的是自然语言位置，系统内部保存的是结构化空间路径：

```text
主衣柜 / 上层收纳区 / 收纳箱 B03 / 第 1 叠 / 从上往下第 2 件
```

内部路径：

```text
storage_node_path: W01 > S01 > B03 > G01
order_axis: top_to_bottom
order_index: 2
```
