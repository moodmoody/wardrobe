# 衣橱数字孪生 App 竞争分析

> 调研日期：2026-06-08  
> 结论摘要：市场上已有大量“数字衣橱 / 穿搭规划 / AI 造型”App，也有一些“家庭物品库存 / 容器位置 / QR 标签”App，但很少看到把两者结合起来、专门解决“现实衣橱空间结构 + 单品身份 + 叠放顺序”的产品。

## 1. 市场分层

当前市场可以分成三类。

### 1.1 数字衣橱与穿搭规划类

代表产品：

- Whering
- Stylebook
- Acloset
- Indyx
- Cladwell
- Pureple
- Save Your Wardrobe
- Wearli / Wearra / Qloset / TryDrobe 等新 AI 衣橱产品

核心能力：

- 拍照或导入衣物。
- 自动去背景。
- 自动分类、颜色、季节、场合标签。
- 搭配生成。
- 穿搭日历。
- 穿着次数统计。
- cost-per-wear。
- 旅行打包。
- 社交分享或真人造型师服务。

主要不足：

- 多数产品把数字衣橱当作“衣服图片库”。
- 重点是“穿什么”，不是“现实中这件衣服在哪里”。
- 很少建模真实衣柜结构，例如层板、抽屉、挂杆、收纳箱、叠放顺序。
- 对相似衣物、重复衣物、失联衣物、位置置信度支持较弱。

### 1.2 家庭库存与空间位置类

代表产品：

- NestMap
- LokApp
- Containd
- Closet Shelf Inventory Log

核心能力：

- 用容器、房间、抽屉、盒子管理物品。
- 支持 QR 标签。
- 支持嵌套空间，例如抽屉在柜子里、盒子在架子上。
- 支持搜索物品在哪。
- 部分产品支持 AI 识别、CSV 导出、价值统计。

主要不足：

- 不懂衣服品类、季节、场合、穿搭。
- 不做 outfit planning。
- 不做穿着记录和 cost-per-wear。
- 不做衣物护理、搭配、风格分析。
- 更像通用家庭库存，而不是衣橱数字孪生。

### 1.3 衣物护理与生命周期类

代表产品：

- Save Your Wardrobe

核心能力：

- 衣物数字化。
- 衣物护理、维修、改衣、售后服务。
- 可持续消费和品牌售后。

主要不足：

- 更偏 B2B / 售后服务 / care & repair。
- 对个人衣柜内部空间映射不是核心。

## 2. 主要竞品分析

### 2.1 Whering

定位：社交化数字衣橱、穿搭规划、衣橱分析。

公开信息显示，Whering 主打 digital closet、outfit planner、style analytics、packing list、cost-per-wear tracking 等能力。

优势：

- 品牌认知强，数字衣橱心智明确。
- 功能覆盖衣物录入、搭配、统计、旅行打包。
- 有社交和灵感属性。
- 适合“我今天穿什么”和“怎么盘活已有衣服”。

不足：

- 更偏衣物图片与搭配管理。
- 没看到强现实空间建模，例如衣柜层板、抽屉、挂杆、收纳箱路径。
- 没看到单品物理锚点，例如 NFC / QR / RFID 的强绑定思路。
- 对“这件衣服现实中具体在哪里”的支持不构成核心差异。

对我们的启发：

- Whering 证明“数字衣橱 + 统计 + 搭配”有市场。
- 但我们不应该正面卷 outfit generator，而应切入“真实衣橱可找、可盘点、可同步”。

来源：

- https://www.whering.co/
- https://play.google.com/store/apps/details?id=com.whering.app

### 2.2 Stylebook

定位：经典衣橱管理、穿搭日历、统计和 cost-per-wear。

Stylebook 官网强调 90+ features，包括 outfit shuffle、calendar、cost-per-wear、wardrobe stats 等。

优势：

- 老牌、稳定、偏 power user。
- 用户可高度手动管理衣物、搭配、日历、统计。
- cost-per-wear 和 wardrobe stats 很符合重度衣橱管理用户。
- 更像“个人衣橱数据库”。

不足：

- 手动维护成本高。
- 不是 AI-first。
- 没看到现实衣柜空间结构、叠放顺序、位置置信度。
- 更关注 wardrobe data，而不是 physical wardrobe twin。

对我们的启发：

- Stylebook 的用户说明“愿意认真管理衣橱的人”存在。
- 我们可以借鉴其统计深度，但要降低维护成本，并补上空间映射。

来源：

- https://stylebookapp.com/features.html
- https://stylebookapp.com/landing/vc/closet-forever.html

### 2.3 Acloset

定位：AI smart closet，自动整理衣橱、推荐穿搭、追踪风格。

Acloset 官网称其 AI 可组织衣橱、推荐 outfit，并追踪 style，且宣称有 700 万用户。

优势：

- AI 心智强。
- 自动分类和穿搭推荐降低用户门槛。
- 用户规模大，证明 AI digital closet 需求存在。
- 更适合轻用户和日常穿搭建议。

不足：

- 仍然以“照片数字化 + AI 搭配”为中心。
- 没看到真实衣柜结构映射。
- 对“同款两件衣服如何区分”“衣服是否还在原位置”“收纳盒里第几件”这类问题不是重点。

对我们的启发：

- AI 录入和推荐是基础能力，不能没有。
- 但单靠 AI 搭配已经红海，我们的差异应放在“物理世界一致性”。

来源：

- https://www.acloset.app/
- https://www.acloset.app/-how-it-works

### 2.4 Indyx

定位：数字衣橱、衣橱分析、社交分享、真人/朋友造型。

App Store 信息显示，Indyx 支持上传照片、转发购物收据、粘贴商品链接，AI 自动标签，closet analytics，cost-per-wear，outfit boards，calendar，style workshop，分享衣橱和找人 styling。

优势：

- 录入路径丰富：照片、收据、商品链接。
- AI 标签和图片增强降低建档成本。
- analytics 和 cost-per-wear 比较完整。
- 社交和真人 styling 差异化明显。

不足：

- 更偏“个人风格资产”和“造型服务”。
- location 更多像普通字段，不是递归空间模型。
- 没看到 QR/NFC 空间标签、衣柜节点、叠放顺序、盘点模式。

对我们的启发：

- 可以学习 Indyx 的多入口录入和高质量图片处理。
- 但我们的定位不应是 styling marketplace，而应是 physical wardrobe operating system。

来源：

- https://apps.apple.com/us/app/indyx-wardrobe-outfit-app/id1599179405
- https://www.myindyx.com/

### 2.5 Cladwell

定位：capsule wardrobe 和 daily outfit app。

Cladwell 官网强调 capsule wardrobe、daily outfit 和简化生活。

优势：

- 定位清晰，服务极简衣橱和胶囊衣橱用户。
- 决策成本低，适合“少而精”的衣橱哲学。

不足：

- 更偏穿搭建议和衣橱精简。
- 不适合复杂、多空间、多收纳节点的现实衣橱映射。
- 不是库存/位置/盘点型产品。

对我们的启发：

- 可以吸收“减少决策疲劳”的价值表达。
- 但我们面对的是更复杂、更真实的衣橱管理问题。

来源：

- https://cladwell.com/

### 2.6 Save Your Wardrobe

定位：数字衣橱 + 衣物护理、维修、改衣、品牌售后平台。

Save Your Wardrobe 官网强调其是模块化的 aftersales solution，帮助品牌规模化 repair、care、alteration 服务。

优势：

- 把衣物生命周期延伸到护理、维修和售后。
- 可持续消费叙事强。
- B2B 价值明确。

不足：

- 不以现实衣柜空间建模为核心。
- 个人用户侧可能受服务地域、维修网络限制。
- 更像衣物生命周期服务平台，而不是家庭衣橱数字孪生。

对我们的启发：

- 后续可加入 care / repair / donation / resale 生命周期状态。
- 但早期不应把服务网络作为核心依赖。

来源：

- https://www.saveyourwardrobe.com/
- https://www.saveyourwardrobe.com/en-gb/legal/faq

### 2.7 LokApp / NestMap / Containd

定位：通用家庭库存、容器管理、QR 标签和位置搜索。

LokApp 明确支持 locations 和 containers 的嵌套层级，例如 drawers inside shelves, shelves inside rooms，并支持 QR Code Labels。NestMap 强调给 drawers、boxes、shelves 贴 QR 标签，搜索物品后知道在哪个 drawer、box 或 closet。Containd 强调用 2D canvas 映射 boxes、shelves、drawers、containers。

优势：

- 更接近我们提出的现实空间映射。
- 支持容器、嵌套、QR 标签、搜索位置。
- 对“东西在哪里”这个问题解决得更直接。

不足：

- 通用库存，不懂衣服。
- 不懂穿搭、季节、场合、洗护、cost-per-wear。
- 不建模叠放衣物的 outfit 使用逻辑。
- 不解决“同款两件衣服如何区别穿着历史”。

对我们的启发：

- 这是我们最应该学习的相邻品类。
- 我们的空间建模可以借鉴 home inventory，但上层产品体验必须围绕衣服和穿搭展开。

来源：

- https://lokapp.me/
- https://www.nestmap.co/
- https://containd.app/en/

## 3. 横向能力对比

| 产品 | 数字衣物录入 | AI 标签/推荐 | 穿搭规划 | 穿着统计 | CPW | 衣物护理 | 空间/容器映射 | QR/NFC/RFID | 叠放顺序 | 数字孪生潜力 |
|---|---|---|---|---|---|---|---|---|---|---|
| Whering | 强 | 中/强 | 强 | 强 | 有 | 弱 | 弱 | 弱 | 弱 | 中 |
| Stylebook | 强 | 弱 | 强 | 强 | 强 | 弱 | 弱 | 弱 | 弱 | 中 |
| Acloset | 强 | 强 | 强 | 中 | 中 | 弱 | 弱 | 弱 | 弱 | 中 |
| Indyx | 强 | 强 | 强 | 强 | 强 | 弱 | 弱/中 | 弱 | 弱 | 中 |
| Cladwell | 中 | 中 | 强 | 中 | 弱/中 | 弱 | 弱 | 弱 | 弱 | 低/中 |
| Save Your Wardrobe | 中 | 中 | 中 | 中 | 中 | 强 | 弱 | 弱 | 弱 | 中 |
| LokApp | 中 | 中 | 无 | 弱 | 弱 | 无 | 强 | 强 | 中 | 高但非衣橱专用 |
| NestMap | 中 | 弱/中 | 无 | 弱 | 弱 | 无 | 强 | 强 | 中 | 高但非衣橱专用 |
| Containd | 中 | 弱 | 无 | 弱 | 弱 | 无 | 强 | 中 | 中 | 高但非衣橱专用 |
| 我们的方向 | 强 | 中起步 | 中/强 | 强 | 强 | 可扩展 | 强 | 可选强绑定 | 强 | 高 |

## 4. 用户痛点对比

### 4.1 现有数字衣橱 App 已经解决的问题

- 我有哪些衣服？
- 今天穿什么？
- 哪些衣服很久没穿？
- 某件衣服 cost-per-wear 是多少？
- 出差/旅行带什么？
- 怎样搭配已有衣服？

### 4.2 现有产品普遍没有解决好的问题

- 这件衣服现实中具体在哪里？
- 两件一样的衣服如何区分？
- 一叠衣服里某件在第几件？
- 收纳箱里到底有什么？
- 衣服从主衣柜移动到待洗区后，数字世界是否同步？
- 盘点时如何发现“数字里有但现实找不到”的衣物？
- 不同衣柜样式如何统一建模？
- 不给每件衣服贴标签时，如何仍然保持位置可信？

这些正是我们可以切入的差异化点。

## 5. 市场机会

推荐定位：

```text
不是又一个 AI Outfit App，而是现实衣橱的 Digital Twin OS。
```

一句话表达：

```text
把你的真实衣橱映射到数字世界：每件衣服是谁、在哪里、是否还在、多久没穿，一目了然。
```

差异化能力：

- 递归 Storage Node Tree，适配各种衣橱样式。
- Item Placement，记录衣服在现实空间中的位置。
- Stack Order，表达叠放顺序。
- Twin Confidence，表达身份和位置可信度。
- 盘点模式，校准现实世界和数字世界。
- QR/NFC 可选强绑定，但不强制。
- 穿搭和统计建立在可信物理映射之上。

## 6. 产品策略建议

### 6.1 不要正面卷 AI 穿搭

AI outfit planner 已经很拥挤，Whering、Acloset、Indyx、Pureple、新 AI app 都在做。

我们的早期核心不应是“更会搭配”，而是：

```text
更知道真实衣服在哪里。
```

### 6.2 先打“找得到”和“盘得清”

MVP 应优先验证：

- 用户愿不愿意给衣柜空间建模？
- 用户是否愿意给层板/抽屉/收纳盒贴 QR？
- 用户能否通过空间视图更快找到衣服？
- 叠放顺序是否真的有价值？
- 盘点是否能建立长期使用理由？

### 6.3 录入方式要比竞品更轻

竞品的普遍问题是上传全衣橱太累。

建议：

- 不要求一次性录完整个衣橱。
- 从一个空间节点开始，例如“主衣柜上层左侧”。
- 先录一叠或一个抽屉。
- 每次穿着、放回、盘点时逐步完善。

### 6.4 先做空间标签，不先做每件衣服标签

如果要求每件衣服贴 NFC，门槛太高。

更合理：

```text
先给空间贴标签：衣柜、抽屉、收纳盒、层板。
再给关键衣物贴标签：贵重、易混淆、常穿。
```

这样可用性和准确度能平衡。

## 7. SWOT

### Strengths

- 切入点比普通数字衣橱更深。
- 空间映射和盘点能形成长期使用场景。
- 可兼容后续 AI、QR、NFC、RFID。
- 有机会成为“衣橱操作系统”，而不是单点工具。

### Weaknesses

- 首次建模成本可能高。
- 用户是否愿意维护位置，需要验证。
- 空间 UI 复杂度高。
- 叠放顺序容易过期，需要置信度和轻交互。

### Opportunities

- AI 衣橱 App 红海，但现实空间映射仍少见。
- 家庭库存 App 证明 QR + 容器映射有需求。
- 可延展到换季整理、搬家、旅行打包、护理、二手转卖。
- 可服务重度衣橱用户、胶囊衣橱用户、整理师、民宿/演出服装管理等。

### Threats

- 大型平台可能用系统相册/AI 自动识别衣物，降低建档门槛。
- 现有数字衣橱 App 可能快速增加 location 字段。
- 用户可能觉得维护衣橱太麻烦。
- 硬件绑定方案如果过重，会降低采用率。

## 8. 结论

市场上有类似 App，但大多数类似的是“数字衣橱”和“穿搭规划”，不是完整的“现实衣橱数字孪生”。

真正接近我们空间映射思路的反而是通用家庭库存 App，例如 LokApp、NestMap、Containd。但它们不懂衣服、不懂穿搭、不懂穿着统计。

所以机会点是：

```text
数字衣橱 App 的穿搭与统计能力
+
家庭库存 App 的空间/容器/QR 映射能力
=
现实衣橱 Digital Twin
```

产品早期应该聚焦一句话：

```text
不只是知道你有什么衣服，还知道它们真实放在哪里。
```
