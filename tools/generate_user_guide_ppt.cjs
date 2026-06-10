const pptxgen = require("pptxgenjs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const out = path.join(root, "wardrobe-app-user-guide.pptx");
const imagePath = path.join(root, "assets", "images", "w01-reference.jpg");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.author = "Codex";
pptx.company = "";
pptx.subject = "Wardrobe Digital Twin user guide";
pptx.title = "衣橱 Digital Twin App 用户使用说明";
pptx.lang = "zh-CN";
pptx.theme = {
  headFontFace: "Microsoft YaHei",
  bodyFontFace: "Microsoft YaHei",
  lang: "zh-CN",
};
pptx.defineLayout({ name: "CUSTOM_WIDE", width: 13.333, height: 7.5 });
pptx.layout = "CUSTOM_WIDE";
pptx.margin = 0;

const C = {
  ink: "14201D",
  paper: "F7F0E4",
  cream: "EBD8B9",
  mint: "7AD3C2",
  mintLight: "D7FFF6",
  tan: "F2E6D1",
  line: "D7C3A5",
  text: "241D17",
  muted: "4E5A50",
  white: "FFFFFF",
  warn: "F4D4B8",
};

function addBg(slide, color = C.paper) {
  slide.background = { color };
}

function addTitle(slide, title, subtitle, dark = false) {
  slide.addText(title, {
    x: 0.55,
    y: 0.34,
    w: 12.2,
    h: 0.45,
    fontFace: "Microsoft YaHei",
    fontSize: 23,
    bold: true,
    color: dark ? C.white : C.ink,
    margin: 0,
    breakLine: false,
    fit: "shrink",
  });
  if (subtitle) {
    slide.addText(subtitle, {
      x: 0.58,
      y: 0.93,
      w: 12,
      h: 0.34,
      fontFace: "Microsoft YaHei",
      fontSize: 11,
      color: dark ? C.mintLight : C.muted,
      margin: 0,
      fit: "shrink",
    });
  }
}

function addCard(slide, x, y, w, h, title, body, opts = {}) {
  const fill = opts.fill || C.white;
  const line = opts.line || C.line;
  const titleColor = opts.titleColor || C.ink;
  slide.addShape(pptx.ShapeType.roundRect, {
    x,
    y,
    w,
    h,
    rectRadius: 0.08,
    fill: { color: fill },
    line: { color: line, width: 1 },
  });
  slide.addText(title, {
    x: x + 0.15,
    y: y + 0.12,
    w: w - 0.3,
    h: 0.28,
    fontFace: "Microsoft YaHei",
    fontSize: opts.titleSize || 14,
    bold: true,
    color: titleColor,
    margin: 0,
    fit: "shrink",
  });
  const lines = Array.isArray(body) ? body : [body];
  slide.addText(lines.join("\n"), {
    x: x + 0.15,
    y: y + 0.5,
    w: w - 0.3,
    h: h - 0.58,
    fontFace: "Microsoft YaHei",
    fontSize: opts.bodySize || 10.5,
    color: opts.bodyColor || "3B3027",
    breakLine: false,
    margin: 0,
    fit: "shrink",
    valign: "mid",
  });
}

function addArrow(slide, x1, y1, x2, y2) {
  slide.addShape(pptx.ShapeType.line, {
    x: x1,
    y: y1,
    w: x2 - x1,
    h: y2 - y1,
    line: { color: "2F5F58", width: 2, beginArrowType: "none", endArrowType: "triangle" },
  });
}

function addFooter(slide, text) {
  slide.addText(text, {
    x: 0.6,
    y: 7.08,
    w: 12.1,
    h: 0.22,
    fontFace: "Microsoft YaHei",
    fontSize: 9,
    color: C.muted,
    margin: 0,
    fit: "shrink",
  });
}

function titleSlide() {
  const s = pptx.addSlide();
  addBg(s, C.ink);
  addTitle(s, "衣橱 Digital Twin App 用户使用说明", "从用户角度理解：首页显示什么，怎么放衣服，怎么找衣服，怎么盘点", true);
  s.addText("核心不是“衣服相册”，而是“现实衣橱地图”。\n用户先看到真实衣橱的数字孪生，再把每件衣服放到具体位置。", {
    x: 0.75,
    y: 2,
    w: 5.45,
    h: 1.25,
    fontFace: "Microsoft YaHei",
    fontSize: 20,
    bold: true,
    color: C.white,
    fit: "shrink",
    margin: 0,
  });
  addCard(s, 7.0, 1.9, 4.9, 2.8, "当前样板：W01 主衣橱", [
    "左侧：层板叠放区",
    "右侧：挂衣杆 + 抽屉区",
    "重点：左侧第二层、左侧第四层、右侧挂衣杆",
  ], { fill: C.cream, line: C.mint });
  s.addText("这份 PPT 按当前 Flutter 首页界面来解释，不讲底层代码。", {
    x: 0.75,
    y: 6.9,
    w: 11.5,
    h: 0.24,
    fontFace: "Microsoft YaHei",
    fontSize: 10,
    color: C.mintLight,
    margin: 0,
  });
}

function addSlides() {
  let s = pptx.addSlide();
  addBg(s);
  addTitle(s, "1. 用户打开首页，第一眼应该看懂什么？", "首页不是商品橱窗，而是“我的真实衣橱控制台”。");
  addCard(s, 0.65, 1.55, 3.75, 1.45, "真实衣橱模拟舱", "告诉用户：这是 W01 主衣橱的数字孪生，不是普通穿搭 App。", { fill: C.ink, line: C.mint, titleColor: C.mint, bodyColor: C.white });
  addCard(s, 4.75, 1.55, 3.75, 1.45, "现实照片校准", "左边是真实照片，当前选中节点会覆盖高亮到照片对应区域。");
  addCard(s, 8.85, 1.55, 3.75, 1.45, "W01 空间剖面图", "把衣橱拆成可点击格子：层板、挂杆、抽屉、混杂区。");
  addCard(s, 0.65, 3.55, 5.75, 1.85, "节点详情", "用户点某个区域后，右侧显示：节点 ID、现实路径、访问方式、可见性、顺序规则。", { fill: C.tan });
  addCard(s, 6.85, 3.55, 5.75, 1.85, "盘点状态", "每个区域可以标记：已盘点、待整理、未确认。用户知道哪些地方清楚，哪些地方还要处理。", { fill: C.tan });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "2. 产品主逻辑：先建空间，再放衣服", "真实衣橱里有遮挡、叠放、抽屉和临时堆放，所以不能一开始就要求用户逐件录完。");
  addCard(s, 0.7, 2.0, 2.6, 1.45, "现实衣橱照片", "用户拍一张 W01 的整体照片。", { fill: C.cream });
  addArrow(s, 3.45, 2.72, 4.45, 2.72);
  addCard(s, 4.55, 2.0, 2.8, 1.45, "空间节点", "系统/用户确认层板、挂杆、抽屉、叠放组。");
  addArrow(s, 7.45, 2.72, 8.45, 2.72);
  addCard(s, 8.55, 2.0, 3.4, 1.45, "衣物位置", "每件衣服挂靠到某个节点，记录顺序和可信度。", { fill: C.mintLight, line: "2F5F58" });
  s.addText("用户理解方式：不是“我要录入一堆衣服”，而是“我先把衣橱地图建好，以后衣服都放到地图上”。\n这会显著降低首次使用成本。", {
    x: 0.8, y: 4.35, w: 11.2, h: 1.0, fontFace: "Microsoft YaHei", fontSize: 17, bold: true, color: C.text, margin: 0, fit: "shrink",
  });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "3. 第一次使用：怎么建立我的衣橱？", "以当前 W01 首页为例，用户流程可以非常短。");
  s.addImage({ path: imagePath, x: 0.75, y: 1.35, w: 3.25, h: 4.75 });
  addCard(s, 4.35, 1.35, 3.7, 1.2, "步骤 1：拍照", "拍一张衣橱正面照，作为现实校准图。");
  addCard(s, 4.35, 2.75, 3.7, 1.2, "步骤 2：确认空间", "确认左侧层板区、右侧挂衣区、抽屉区。");
  addCard(s, 8.4, 1.35, 3.7, 1.2, "步骤 3：生成节点", "得到 W01-L-S02、W01-R-H01 这类可定位编号。");
  addCard(s, 8.4, 2.75, 3.7, 1.2, "步骤 4：先盘重点", "先处理最常找、最乱、最能验证价值的位置。", { fill: C.mintLight, line: "2F5F58" });
  s.addText("当前首页已经把 W01 样板做成了：照片校准 + 数字网格 + 节点详情 + 盘点状态。", {
    x: 4.35, y: 4.55, w: 7.75, h: 0.8, fontFace: "Microsoft YaHei", fontSize: 16, bold: true, color: C.ink, margin: 0, fit: "shrink",
  });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "4. 用户怎么“放入一件衣服”？", "目标：把一件现实衣服放到一个明确的现实位置里。");
  addCard(s, 0.65, 1.55, 2.55, 1.25, "选位置", "点“左侧第二层主叠放层”或某个叠放组。");
  addArrow(s, 3.35, 2.18, 4.05, 2.18);
  addCard(s, 4.15, 1.55, 2.55, 1.25, "新增衣服", "拍衣服照片，填写名称、类别、颜色。");
  addArrow(s, 6.85, 2.18, 7.55, 2.18);
  addCard(s, 7.65, 1.55, 2.55, 1.25, "记录顺序", "叠放：从上往下第几件。挂衣：从左到右第几件。");
  addArrow(s, 10.35, 2.18, 11.05, 2.18);
  addCard(s, 10.75, 1.55, 1.55, 1.25, "保存", "生成衣物位置。", { fill: C.mintLight, line: "2F5F58" });
  addCard(s, 1.0, 3.65, 10.9, 1.75, "例子", ["白色 T 恤 -> 主衣橱 / 左侧第二层 / 右侧叠放组 / 从上往下第 4 件", "系统内部可编号为：W01-L-S02-G03-I04"], { fill: C.ink, line: C.mint, titleColor: C.mint, bodyColor: C.white, bodySize: 12 });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "5. 用户怎么“找一件衣服”？", "找衣服不是只看照片，而是得到可执行的现实路径。");
  addCard(s, 0.75, 1.35, 3.2, 1.25, "搜索 / 筛选", "输入“黑色外套”或按季节、颜色、类别筛选。");
  addCard(s, 4.35, 1.35, 3.2, 1.25, "看到结果", "衣服卡片显示缩略图 + 位置路径 + 最近确认时间。");
  addCard(s, 7.95, 1.35, 3.7, 1.25, "定位现实位置", "App 高亮照片和数字网格中的对应节点。", { fill: C.mintLight, line: "2F5F58" });
  s.addText("用户拿到的不是一句“在衣柜里”，而是：\n主衣橱 / 右侧挂衣杆 / 从左到右第 6 件", {
    x: 0.85, y: 3.4, w: 11.2, h: 1.15, fontFace: "Microsoft YaHei", fontSize: 21, bold: true, color: C.ink, margin: 0, fit: "shrink",
  });
  s.addText("这就是数字孪生的价值：数字世界给出可执行的位置，现实世界能按同一路径找到。", {
    x: 0.85, y: 5.25, w: 11.2, h: 0.4, fontFace: "Microsoft YaHei", fontSize: 12, color: C.muted, margin: 0, fit: "shrink",
  });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "6. 用户怎么“盘点”？", "盘点的对象不是一件件衣服，而是一个个空间节点。");
  addCard(s, 0.8, 1.4, 3.5, 1.45, "未确认", ["还没打开看过，或只是从照片粗略建模。", "适合：抽屉、暗区。"]);
  addCard(s, 4.75, 1.4, 3.5, 1.45, "待整理", ["区域太乱，先不要强行逐件录。", "适合：底层混杂区。"], { fill: C.warn });
  addCard(s, 8.7, 1.4, 3.5, 1.45, "已盘点", "已经拍近照、确认位置或录入主要衣物。", { fill: C.mintLight, line: "2F5F58" });
  s.addText("当前首页右侧“盘点状态”已经能切换这三种状态。\n实际使用时，用户从“第一轮建议盘点”的三个重点节点开始：左侧第二层、左侧第四层、右侧挂衣杆。", {
    x: 0.85, y: 3.7, w: 11.3, h: 1.0, fontFace: "Microsoft YaHei", fontSize: 16, bold: true, color: C.ink, margin: 0, fit: "shrink",
  });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "7. 当前首页每块区域，回答用户哪个问题？", "把界面翻译成人话。");
  addCard(s, 0.65, 1.3, 3.6, 1.15, "真实衣橱模拟舱", "我现在管理的是哪个衣橱？它是不是我的真实衣橱？", { fill: C.ink, line: C.mint, titleColor: C.mint, bodyColor: C.white });
  addCard(s, 4.55, 1.3, 3.6, 1.15, "现实照片校准", "这个数字节点在真实照片里对应哪一块？");
  addCard(s, 8.45, 1.3, 3.6, 1.15, "W01 空间剖面图", "我能点击哪些真实存放位置？");
  addCard(s, 0.65, 3.0, 3.6, 1.15, "节点详情", "这个位置的编号、路径、可见性、拿取方式是什么？");
  addCard(s, 4.55, 3.0, 3.6, 1.15, "盘点状态", "这个位置是否已经确认？是否需要整理？");
  addCard(s, 8.45, 3.0, 3.6, 1.15, "下一步动作", "我现在应该拍照、整理、录入，还是先跳过？", { fill: C.mintLight, line: "2F5F58" });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "8. 当前 MVP 已经有了什么，还缺什么？", "这页用来防止团队把“可演示界面”和“完整产品”混在一起。");
  addCard(s, 0.8, 1.35, 5.35, 3.9, "当前已经有", ["W01 衣橱空间样板", "现实照片校准卡", "12 x 16 数字空间剖面图", "节点详情：路径、类型、可见性、顺序", "盘点状态：已盘点 / 待整理 / 未确认"], { fill: C.mintLight, line: "2F5F58" });
  addCard(s, 6.65, 1.35, 5.35, 3.9, "下一步需要补", ["新增衣服流程：拍照、命名、分类、选择位置", "找衣服流程：搜索、筛选、定位", "状态持久化：刷新后仍保留盘点结果", "移动记录：衣服从 A 节点移动到 B 节点", "抽屉内部二次建模"]);

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "9. 一个完整用户场景", "用一天里的真实动作串起来。");
  addCard(s, 0.75, 1.3, 2.8, 1.25, "早上找衣服", "搜索“黑色外套”，App 指向右侧挂衣杆。");
  addCard(s, 3.85, 1.3, 2.8, 1.25, "穿走", "衣物状态变成“离柜/穿着中”。");
  addCard(s, 6.95, 1.3, 2.8, 1.25, "晚上放回", "选择放回原位置，或记录新位置。");
  addCard(s, 10.05, 1.3, 2.1, 1.25, "同步", "数字位置更新。", { fill: C.mintLight, line: "2F5F58" });
  s.addText("长期价值：衣服不是静态相册，而是在现实衣橱和数字衣橱之间持续同步。\n用户每次找、拿、放回、移动，都是在维护这个 digital twin。", {
    x: 0.85, y: 3.35, w: 11.1, h: 1.2, fontFace: "Microsoft YaHei", fontSize: 19, bold: true, color: C.ink, margin: 0, fit: "shrink",
  });

  s = pptx.addSlide();
  addBg(s);
  addTitle(s, "10. 建议下一阶段怎么做", "为了让用户真的能闭环，优先做三个最小功能。");
  addCard(s, 0.8, 1.45, 3.55, 3.25, "A. 新增衣服", ["从节点详情进入", "拍照或选择照片", "填写名称、颜色、类别", "选择叠放/挂放顺序"]);
  addCard(s, 4.75, 1.45, 3.55, 3.25, "B. 找衣服", ["搜索框", "筛选：类别/颜色/季节", "结果卡片显示现实路径", "点击后高亮照片和网格"]);
  addCard(s, 8.7, 1.45, 3.55, 3.25, "C. 持久化盘点", ["保存每个节点状态", "记录最后确认时间", "支持“移动到其他节点”", "后续接本地数据库"], { fill: C.mintLight, line: "2F5F58" });
  addFooter(s, "优先顺序建议：新增衣服 -> 找衣服 -> 状态持久化。这样最快形成真实用户闭环。");
}

titleSlide();
addSlides();

pptx.writeFile({ fileName: out });
