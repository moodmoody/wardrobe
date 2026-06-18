from pathlib import Path
import shutil

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SRC = Path(
    r"C:\Users\weife\.codex\skills\.system\imagegen\output"
    r"\20260616-163319-968-create-polished-vertical-9-16-mobile-941x1672.png"
)
OUT_DIR = ROOT / "docs" / "usage-card"
BASE_OUT = OUT_DIR / "wardrobe-usage-card-portrait-compact-imagegen-base.png"
FINAL_OUT = OUT_DIR / "wardrobe-usage-card-portrait-compact-cn.png"

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


def draw_step(draw, box, number, title, body, font_num, font_title, font_body):
    x1, y1, x2, _ = box
    ink = (64, 43, 29, 255)
    muted = (100, 73, 53, 255)
    bronze = (151, 113, 73, 255)
    teal = (0, 116, 111, 255)

    badge_size = 38
    badge = (x1 + 18, y1 + 18, x1 + 18 + badge_size, y1 + 18 + badge_size)
    draw.ellipse(badge, fill=bronze)
    number_text = str(number)
    number_width = draw.textlength(number_text, font=font_num)
    draw.text(
        (badge[0] + badge_size / 2 - number_width / 2, badge[1] + 4),
        number_text,
        font=font_num,
        fill=(255, 247, 235, 255),
    )

    text_x = x1 + 66
    title_y = y1 + 16
    draw.text((text_x, title_y), title, font=font_title, fill=ink)
    underline_width = min(96, int(draw.textlength(title, font=font_title)))
    draw.rounded_rectangle(
        (text_x, title_y + 32, text_x + underline_width, title_y + 37),
        radius=2,
        fill=teal,
    )

    y = y1 + 62
    for line in wrap_by_px(draw, body, font_body, x2 - text_x - 16)[:2]:
        draw.text((text_x, y), line, font=font_body, fill=muted)
        y += 25


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SRC, BASE_OUT)

    img = Image.open(SRC).convert("RGBA")
    draw = ImageDraw.Draw(img)

    font_header = ImageFont.truetype(FONT_BOLD, 34)
    font_sub = ImageFont.truetype(FONT_REGULAR, 18)
    font_num = ImageFont.truetype(FONT_BOLD, 24)
    font_title = ImageFont.truetype(FONT_BOLD, 22)
    font_body = ImageFont.truetype(FONT_REGULAR, 17)

    ink = (64, 43, 29, 255)
    muted = (100, 73, 53, 255)

    # Place the title in the narrow gap above the compact cards.
    draw.rounded_rectangle(
        (170, 1320, 771, 1382),
        radius=24,
        fill=(255, 247, 235, 224),
        outline=(176, 138, 96, 132),
        width=1,
    )
    header = "衣橱数字孪生 APP 使用卡"
    sub = "看位置 · 放衣服 · 找衣服 · 做盘点"
    header_width = draw.textlength(header, font=font_header)
    sub_width = draw.textlength(sub, font=font_sub)
    draw.text((470 - header_width / 2, 1329), header, font=font_header, fill=ink)
    draw.text((470 - sub_width / 2, 1364), sub, font=font_sub, fill=muted)

    steps = [
        ((39, 1433, 244, 1590), 1, "看衣橱", "首页显示 W01 数字衣橱。"),
        ((258, 1433, 463, 1590), 2, "点位置", "进入放置 / 盘点界面。"),
        ((477, 1433, 682, 1590), 3, "放衣服", "建档并绑定定位码。"),
        ((696, 1433, 901, 1590), 4, "找/盘点", "点还在 / 不在同步。"),
    ]

    for box, number, title, body in steps:
        draw_step(draw, box, number, title, body, font_num, font_title, font_body)

    img.save(FINAL_OUT)
    print(FINAL_OUT)


if __name__ == "__main__":
    main()
