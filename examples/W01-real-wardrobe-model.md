# W01 真实衣橱样板建模

> 来源图片：`C:\Users\weife\Pictures\微信图片_20260608202133_59_9.jpg`  
> 建模日期：2026-06-08  
> 目标：把照片中的现实衣橱作为第一个 digital twin 样板，先建空间结构，再逐步录入衣物实例。

## 1. 建模策略

这张照片里的衣橱不适合一上来逐件识别所有衣服。因为存在遮挡、叠放、暗色衣物混在一起、抽屉内部不可见等问题。

第一阶段应先完成“空间建模”：

```text
现实衣橱结构 -> 数字 Storage Node Tree
```

第二阶段再逐步完成“衣物录入”：

```text
每个空间节点中的衣物 -> Item Instance + Item Placement
```

也就是说，先回答：

```text
这个衣橱有哪些可存放位置？
每个位置如何编号？
哪些位置适合叠放？
哪些位置适合挂放？
哪些位置暂时不可见？
```

再回答：

```text
每件衣服是谁？
它在哪个节点里？
在一叠里的第几件？
这个位置有多可信？
```

## 2. 衣橱整体判断

从照片看，这是一个嵌入式双区衣橱，中间有竖向隔板。

整体结构：

```text
W01 主衣橱
├─ L 左侧层板叠放区
└─ R 右侧挂衣 + 抽屉区
```

左侧以层板为主，适合叠放 T 恤、裤子、针织、围巾、杂物。右侧上方是层板，中部是挂杆，下方是三层抽屉。

建议这套衣橱的模板类型设为：

```text
built_in_two_bay_wardrobe
```

## 3. 顶层节点

```text
W01
name: 主衣橱
type: wardrobe
template_type: built_in_two_bay_wardrobe
access_pattern: sliding_or_hinged_door
visibility: mixed
mobility: fixed
```

用户显示名：

```text
主衣橱
```

## 4. 一级分区

### W01-L 左侧层板叠放区

```text
id: W01-L
parent: W01
type: bay
name: 左侧层板叠放区
order_axis: top_to_bottom
visibility: visible
access_pattern: open_when_door_open
```

用户显示名：

```text
主衣橱 / 左侧层板区
```

### W01-R 右侧挂衣抽屉区

```text
id: W01-R
parent: W01
type: bay
name: 右侧挂衣抽屉区
order_axis: top_to_bottom
visibility: mixed
access_pattern: open_when_door_open
```

用户显示名：

```text
主衣橱 / 右侧挂衣抽屉区
```

## 5. 左侧层板区节点

左侧建议先按从上到下分为 5 个主要节点。

### W01-L-S01 左侧顶层层板

照片特征：顶部一层，有多件折叠或松散堆放衣物，颜色包含深色、青绿色、黄色、蓝色等。

```text
id: W01-L-S01
parent: W01-L
type: shelf
name: 左侧顶层层板
order_axis: left_to_right
visibility: partially_visible
access_pattern: shelf_reach_high
```

建议内部先建 3 个临时存放组：

```text
W01-L-S01-G01 顶层左侧深色叠放组
W01-L-S01-G02 顶层中部彩色叠放组
W01-L-S01-G03 顶层右侧薄衣叠放组
```

用户显示：

```text
主衣橱 / 左侧顶层 / 中部彩色叠放组
```

### W01-L-S02 左侧第二层主叠放层

照片特征：这一层衣物最多，明显是多叠衣服混在一起，适合先粗分为左、中、右三组。

```text
id: W01-L-S02
parent: W01-L
type: shelf
name: 左侧第二层主叠放层
order_axis: left_to_right
visibility: visible
access_pattern: shelf
```

建议内部节点：

```text
W01-L-S02-G01 第二层左侧叠放组
W01-L-S02-G02 第二层中部叠放组
W01-L-S02-G03 第二层右侧叠放组
```

每个组的类型：

```text
type: stack
order_axis: top_to_bottom
placement_confidence: low_to_medium
```

这是 MVP 最适合重点录入的一层，因为它代表真实问题：衣服多、叠放混乱、找衣服困难。

### W01-L-S03 左侧第三层混合层

照片特征：左侧有红/白/花色松散衣物，中部有较大的绿色折叠物，右侧有蓝色衣物，整体比较混杂。

```text
id: W01-L-S03
parent: W01-L
type: shelf
name: 左侧第三层混合层
order_axis: left_to_right
visibility: visible
access_pattern: shelf
```

建议内部节点：

```text
W01-L-S03-G01 第三层左侧松散组
W01-L-S03-G02 第三层中部大件折叠组
W01-L-S03-G03 第三层右侧小件组
```

这层可以暂时不做精确 order_index，先记录为：

```text
placement_confidence: low
order_axis: mixed
```

### W01-L-S04 左侧第四层深色裤装层

照片特征：中部和右侧有多件深色裤装或厚衣物，叠放较清晰。

```text
id: W01-L-S04
parent: W01-L
type: shelf
name: 左侧第四层深色裤装层
order_axis: left_to_right
visibility: visible
access_pattern: shelf_low
```

建议内部节点：

```text
W01-L-S04-G01 第四层左侧散放组
W01-L-S04-G02 第四层中部深色裤装叠放组
W01-L-S04-G03 第四层右侧深色叠放组
```

这层适合做“从上往下第几件”的测试，因为深色裤装通常相似，能验证数字孪生区分相似衣物的价值。

### W01-L-S05 左侧底层混杂区

照片特征：底部有大量松散衣物或杂物，遮挡严重，结构不清晰。

```text
id: W01-L-S05
parent: W01-L
type: shelf_or_floor_cubby
name: 左侧底层混杂区
order_axis: mixed
visibility: partially_hidden
access_pattern: low_reach
```

建议先作为一个整体节点，不急着逐件录入。

用户显示：

```text
主衣橱 / 左侧底层混杂区
```

状态：

```text
needs_sorting: true
placement_confidence: low
```

## 6. 右侧挂衣抽屉区节点

### W01-R-S01 右侧顶层层板

照片特征：右侧顶部层板主要是深色衣物，前方有浅色折叠物，整体较暗。

```text
id: W01-R-S01
parent: W01-R
type: shelf
name: 右侧顶层层板
order_axis: left_to_right
visibility: partially_visible
access_pattern: shelf_reach_high
```

建议内部节点：

```text
W01-R-S01-G01 右侧顶层左侧浅色叠放组
W01-R-S01-G02 右侧顶层中部深色叠放组
W01-R-S01-G03 右侧顶层右侧暗区组
```

### W01-R-H01 右侧挂衣杆

照片特征：右侧中部是挂衣区，主要为深色外套、上衣、裙装等，从左到右挂在同一根杆上。

```text
id: W01-R-H01
parent: W01-R
type: hanging_rod
name: 右侧挂衣杆
order_axis: left_to_right
visibility: partially_visible
access_pattern: hanging
```

用户显示：

```text
主衣橱 / 右侧挂衣杆 / 从左到右第 N 件
```

建议第一轮不用逐件精确识别，可以先录入大致挂衣序列：

```text
从左到右：浅色衣物组 -> 深色外套组 -> 黑色裙/长款组 -> 右侧暗色衣物组
```

后续录入单件时再逐步拆分为具体 item placement。

### W01-R-F01 右侧挂衣下方平台

照片特征：挂衣下方、抽屉上方有一块平台，堆了白色/灰色/深色松散衣物。

```text
id: W01-R-F01
parent: W01-R
type: shelf
name: 右侧挂衣下方平台
order_axis: left_to_right
visibility: visible
access_pattern: shelf_low
```

这是一个临时堆放区，建议标记为：

```text
node_role: temporary_buffer
placement_confidence: low
```

### W01-R-D01 右侧上抽屉

照片特征：抽屉关闭，内部不可见。

```text
id: W01-R-D01
parent: W01-R
type: drawer
name: 右侧上抽屉
order_axis: front_to_back
visibility: hidden
access_pattern: drawer_pull
```

### W01-R-D02 右侧中抽屉

```text
id: W01-R-D02
parent: W01-R
type: drawer
name: 右侧中抽屉
order_axis: front_to_back
visibility: hidden
access_pattern: drawer_pull
```

### W01-R-D03 右侧下抽屉

```text
id: W01-R-D03
parent: W01-R
type: drawer
name: 右侧下抽屉
order_axis: front_to_back
visibility: hidden
access_pattern: drawer_pull
```

抽屉因为内部不可见，第一轮只建节点，不录入衣物。等用户打开抽屉拍照后，再继续建抽屉内部的分区节点。

## 7. 推荐编号体系

这套衣橱建议使用以下编号规则：

```text
W01 = 主衣橱
L = 左侧 bay
R = 右侧 bay
S = shelf 层板
H = hanging rod 挂衣杆
D = drawer 抽屉
G = group / stack 存放组
I = item 衣物实例
```

示例：

```text
W01-L-S02-G03-I04
```

含义：

```text
主衣橱 / 左侧 / 第二层 / 右侧叠放组 / 从上往下第 4 件
```

用户显示：

```text
主衣橱 / 左侧第二层 / 右侧叠放组 / 从上往下第 4 件
```

挂衣示例：

```text
W01-R-H01-I06
```

含义：

```text
主衣橱 / 右侧挂衣杆 / 从左到右第 6 件
```

抽屉示例：

```text
W01-R-D02-I05
```

含义：

```text
主衣橱 / 右侧中抽屉 / 从前往后第 5 件
```

## 8. 第一轮录入建议

第一轮不要追求录完所有衣服。建议只完成空间树和 3 个重点区域。

### 必做

```text
W01 主衣橱
W01-L 左侧层板区
W01-R 右侧挂衣抽屉区
W01-L-S01 到 W01-L-S05
W01-R-S01
W01-R-H01
W01-R-F01
W01-R-D01 到 W01-R-D03
```

### 优先录入衣物的区域

```text
W01-L-S02 左侧第二层主叠放层
W01-L-S04 左侧第四层深色裤装层
W01-R-H01 右侧挂衣杆
```

原因：

- 左侧第二层最混乱，最能验证“空间节点 + 叠放组”的价值。
- 左侧第四层深色裤装相似度高，适合验证“同类衣服区分”。
- 右侧挂衣杆适合验证“从左到右顺序”。

### 暂缓录入

```text
W01-L-S05 左侧底层混杂区
W01-R-D01 / D02 / D03 抽屉内部
W01-R-S01 右侧顶层暗区
```

原因：

- 遮挡严重或内部不可见。
- 需要用户后续单独打开/整理/拍照。

## 9. App 中的空间视图草案

可以先做成结构树，而不是复杂 3D。

```text
主衣橱 W01

左侧层板区
- 顶层层板
  - 左侧深色叠放组
  - 中部彩色叠放组
  - 右侧薄衣叠放组
- 第二层主叠放层
  - 左侧叠放组
  - 中部叠放组
  - 右侧叠放组
- 第三层混合层
- 第四层深色裤装层
- 底层混杂区

右侧挂衣抽屉区
- 顶层层板
- 挂衣杆
- 挂衣下方平台
- 上抽屉
- 中抽屉
- 下抽屉
```

点开一个节点后，再显示该节点中的衣物。

例如点开：

```text
左侧第二层主叠放层 / 右侧叠放组
```

显示：

```text
从上往下：
1. 待录入衣物
2. 待录入衣物
3. 待录入衣物

位置可信度：低
建议：拍一张该叠近照，或逐件确认。
```

## 10. 盘点流程建议

针对这套衣橱，第一次盘点建议按以下顺序：

```text
1. 建立 W01 主衣橱
2. 建立左侧 5 层节点
3. 建立右侧顶层、挂杆、平台、3 个抽屉
4. 给左侧第二层拍近照
5. 把左侧第二层拆成 3 个叠放组
6. 给右侧挂衣杆拍近照
7. 按从左到右粗录挂衣序列
8. 暂时标记底层和抽屉为未盘点
```

第一轮成功标准：

```text
用户能在 App 中找到“左侧第二层右侧叠放组”
用户能在 App 中找到“右侧挂衣杆从左到右第 N 件”
用户知道哪些区域已经盘点，哪些区域还未盘点
```

## 11. 关键产品判断

这张衣橱照片说明 MVP 不能只做漂亮的衣物网格。真实衣橱里最常见的是：

- 衣服叠在一起。
- 暗色衣物混成一片。
- 有些区域看不见。
- 抽屉关闭，内部未知。
- 临时堆放区经常变化。
- 同一层里有多个叠放组。

所以 MVP 的第一个核心能力应该是：

```text
让用户先把现实衣橱拆成可管理的空间节点。
```

而不是：

```text
让 AI 一次性识别照片里的所有衣服。
```

这套衣橱的数字孪生应先建立空间，再逐步补衣物。这样用户不会被首次录入成本压垮，系统也不会因为照片遮挡而产生大量错误识别。
