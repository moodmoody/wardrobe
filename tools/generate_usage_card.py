from pathlib import Path
import shutil

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SRC = Path(
    r"C:\Users\weife\.codex\skills\.system\imagegen\output"
    r"\20260616-161050-955-create-polished-16-9-product-usage-1672x941.png"
)
OUT_DIR = ROOT / "docs" / "usage-card"
BASE_OUT = OUT_DIR / "wardrobe-usage-card-imagegen-base.png"
FINAL_OUT = OUT_DIR / "wardrobe-usage-card-cn.png"

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


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SRC, BASE_OUT)

    img = Image.open(SRC).convert("RGBA")
    draw = ImageDraw.Draw(img)

    font_title = ImageFont.truetype(FONT_BOLD, 35)
    font_body = ImageFont.truetype(FONT_REGULAR, 25)
    font_small = ImageFont.truetype(FONT_REGULAR, 20)
    font_header = ImageFont.truetype(FONT_BOLD, 32)

    ink = (72, 48, 31, 255)
    muted = (104, 76, 52, 255)
    teal = (18, 116, 112, 255)

    cards = [
        (
            (250, 170, 555, 355),
            "首页：看数字衣橱",
            "手机首页只放核心的 W01 衣橱地图。现实每个格子，对应一个数字节点。",
        ),
        (
            (250, 555, 555, 710),
            "点位置：进入盘点",
            "点击某个衣橱格子，打开“放置衣服 / 盘点”界面，查看该位置应有衣物。",
        ),
        (
            (1125, 170, 1450, 355),
            "放入衣服：建档绑定",
            "拍照或填写衣服信息，系统生成定位码，绑定到当前格子和摆放顺序。",
        ),
        (
            (1125, 555, 1450, 710),
            "找衣服 / 盘点",
            "按数字位置去现实衣橱查找；点“还在 / 不在”，更新映射状态。",
        ),
    ]

    for (x1, y1, x2, _), title, body in cards:
        draw.text((x1, y1), title, font=font_title, fill=ink)
        underline_width = min(118, int(draw.textlength(title, font=font_title)))
        draw.rounded_rectangle(
            (x1, y1 + 47, x1 + underline_width, y1 + 53),
            radius=3,
            fill=teal,
        )
        y = y1 + 70
        for line in wrap_by_px(draw, body, font_body, x2 - x1):
            draw.text((x1, y), line, font=font_body, fill=muted)
            y += 36

    header = "衣橱数字孪生 APP 使用卡"
    sub = "从现实衣橱位置，到数字世界的一对一映射"
    draw.rounded_rectangle(
        (620, 24, 1052, 82),
        radius=22,
        fill=(255, 247, 235, 220),
        outline=(174, 137, 95, 160),
        width=1,
    )
    header_width = draw.textlength(header, font=font_header)
    draw.text((836 - header_width / 2, 36), header, font=font_header, fill=ink)

    draw.rounded_rectangle((614, 84, 1058, 124), radius=18, fill=(255, 247, 235, 185))
    sub_width = draw.textlength(sub, font=font_small)
    draw.text((836 - sub_width / 2, 92), sub, font=font_small, fill=muted)

    img.save(FINAL_OUT)
    print(FINAL_OUT)


if __name__ == "__main__":
    main()
