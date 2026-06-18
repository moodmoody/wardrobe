from pathlib import Path
import shutil

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SRC = Path(
    r"C:\Users\weife\.codex\skills\.system\imagegen\output"
    r"\20260616-161902-911-create-polished-vertical-9-16-mobile-941x1672.png"
)
OUT_DIR = ROOT / "docs" / "usage-card"
BASE_OUT = OUT_DIR / "wardrobe-usage-card-portrait-imagegen-base.png"
FINAL_OUT = OUT_DIR / "wardrobe-usage-card-portrait-cn.png"

FONT_REGULAR = r"C:\Windows\Fonts\msyh.ttc"
FONT_BOLD = r"C:\Windows\Fonts\msyhbd.ttc"


def wrap_by_px(draw, text, font, max_width):
    lines = []
    current = ""
    for char in text:
        candidate = current + char
        if draw.textlength(candidate, font=font) <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = char
    if current:
        lines.append(current)
    return lines


def draw_card(draw, box, number, title, body, fonts):
    x1, y1, x2, _ = box
    font_num, font_title, font_body = fonts
    ink = (66, 45, 31, 255)
    muted = (98, 72, 52, 255)
    teal = (15, 122, 117, 255)
    bronze = (151, 113, 73, 255)

    badge = (x1 + 28, y1 + 26, x1 + 82, y1 + 80)
    draw.ellipse(badge, fill=bronze)
    num_width = draw.textlength(str(number), font=font_num)
    draw.text(
        (badge[0] + 27 - num_width / 2, badge[1] + 7),
        str(number),
        font=font_num,
        fill=(255, 247, 235, 255),
    )

    title_x = x1 + 104
    title_y = y1 + 27
    draw.text((title_x, title_y), title, font=font_title, fill=ink)
    underline_width = min(150, int(draw.textlength(title, font=font_title)))
    draw.rounded_rectangle(
        (title_x, title_y + 44, title_x + underline_width, title_y + 50),
        radius=3,
        fill=teal,
    )

    y = y1 + 92
    for line in wrap_by_px(draw, body, font_body, x2 - title_x - 36):
        draw.text((title_x, y), line, font=font_body, fill=muted)
        y += 34


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SRC, BASE_OUT)

    img = Image.open(SRC).convert("RGBA")
    draw = ImageDraw.Draw(img)

    font_header = ImageFont.truetype(FONT_BOLD, 34)
    font_sub = ImageFont.truetype(FONT_REGULAR, 20)
    font_num = ImageFont.truetype(FONT_BOLD, 31)
    font_title = ImageFont.truetype(FONT_BOLD, 30)
    font_body = ImageFont.truetype(FONT_REGULAR, 23)

    ink = (66, 45, 31, 255)
    muted = (98, 72, 52, 255)

    draw.rounded_rectangle(
        (96, 760, 845, 828),
        radius=26,
        fill=(255, 247, 235, 224),
        outline=(176, 138, 96, 145),
        width=1,
    )
    header = "衣橱数字孪生 APP 使用卡"
    sub = "现实衣橱位置  ↔  数字世界节点"
    header_width = draw.textlength(header, font=font_header)
    sub_width = draw.textlength(sub, font=font_sub)
    draw.text((470 - header_width / 2, 774), header, font=font_header, fill=ink)
    draw.text((470 - sub_width / 2, 812), sub, font=font_sub, fill=muted)

    fonts = (font_num, font_title, font_body)
    cards = [
        (
            (55, 855, 885, 1008),
            1,
            "首页看数字衣橱",
            "打开 APP，首页只看 W01 衣橱地图；现实格子对应数字节点。",
        ),
        (
            (55, 1050, 885, 1203),
            2,
            "点位置进入盘点",
            "点某个衣橱位置，进入“放置衣服 / 盘点”界面。",
        ),
        (
            (55, 1248, 885, 1400),
            3,
            "放入衣服建档",
            "拍照或填写衣服信息，绑定当前格子、顺序和定位码。",
        ),
        (
            (55, 1445, 885, 1598),
            4,
            "找衣服并更新",
            "按数字位置去现实衣橱查找；点“还在 / 不在”同步状态。",
        ),
    ]

    for box, number, title, body in cards:
        draw_card(draw, box, number, title, body, fonts)

    img.save(FINAL_OUT)
    print(FINAL_OUT)


if __name__ == "__main__":
    main()
