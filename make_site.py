#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Генерує index.html (головна сторінка посібника для GitHub Pages) зі змісту FTProblems.toc.

Запуск (після збірки PDF і HTML-версії):  python -I make_site.py
Зміст сторінки (частини, розділи, підрозділи) береться з FTProblems.toc, тому збігається з книгою.
Розділи ведуть на сторінки онлайн-версії online/<ім'я>.html (їх імена задає PAGE_NAMES у html/tools/publish_html.py).
"""
import re
from html import escape
from pathlib import Path

HERE = Path(__file__).resolve().parent
TOC = HERE / "FTProblems.toc"
OUT = HERE / "index.html"
SITE = "https://sergiokapone.github.io/FieldTheoryProblems/"
# i-й розділ (за номером у змісті) -> сторінка онлайн-версії
PAGES = {0: "vanaliz", 1: "maxwellmicro", 2: "emstatics", 3: "radiation", 4: "relativity", 5: "maxwellmacro",
         6: "emmedia", 7: "quasistationary", 8: "waves"}
ENTRY = re.compile(r"\\contentsline \{(\w+)\}\{(.*)\}\{(\d+)\}\{[^}]*\}%?\s*$")


def tex2html(s: str) -> str:
    s = re.sub(r"\\mbox\s*\{([^}]*)\}", r"\1", s)
    s = s.replace("---", "—").replace("--", "–").replace("~", " ")
    s = re.sub(r"\\hspace \{[^}]*\}", " ", s)
    s = re.sub(r"\$([^$]*)\$", lambda m: "<i>%s</i>" % escape(m.group(1).strip()), s)
    return s.strip()


def parse():
    cur_part = {"title": "Вступ", "chapters": []}
    parts, cur_ch = [cur_part], None
    for line in TOC.read_text(encoding="utf-8", errors="replace").splitlines():
        m = ENTRY.match(line)
        if not m:
            continue
        kind, body, _ = m.groups()
        nm = re.match(r"\\numberline \{([^}]*)\}(.*)$", body)
        num, title = (nm.group(1), nm.group(2)) if nm else ("", body)
        title = tex2html(title)
        if kind == "part":
            cur_part = {"title": title, "chapters": []}
            parts.append(cur_part)
        elif kind == "chapter" and num.isdigit() and cur_part is not None:
            cur_ch = {"num": int(num), "title": title, "sections": []}
            cur_part["chapters"].append(cur_ch)
        elif kind == "section" and cur_ch is not None and num:
            cur_ch["sections"].append((num, title))
    return parts


def page(parts) -> str:
    cards = []
    for p in parts:
        cards.append('<h3 class="part">%s</h3>' % p["title"])
        for ch in p["chapters"]:
            href = "online/%s.html" % PAGES.get(ch["num"], "") if ch["num"] in PAGES else "online/"
            secs = "".join("<li><span>%s</span> %s</li>" % (n, t) for n, t in ch["sections"])
            cards.append(
                '<article class="ch"><h4><a href="%s"><span class="n">%d</span>%s</a></h4><ul>%s</ul></article>'
                % (href, ch["num"], ch["title"], secs))
    toc = "\n".join(cards)
    return TEMPLATE.replace("@@TOC@@", toc).replace("@@SITE@@", SITE)


TEMPLATE = """<!DOCTYPE html>
<html lang="uk">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Класична електродинаміка. Збірник задач | Навчальний посібник</title>
<meta name="description" content="Збірник задач з класичної електродинаміки: мікроскопічна теорія та електродинаміка суцільних середовищ. Теоретичні відомості, задачі з відповідями.">
<link rel="canonical" href="@@SITE@@">
<meta property="og:title" content="Класична електродинаміка. Збірник задач">
<meta property="og:description" content="Збірник задач з класичної електродинаміки. Читати онлайн або завантажити PDF.">
<meta property="og:type" content="website">
<meta property="og:url" content="@@SITE@@">
<style>
:root{--navy:#002e64;--blue:#0064aa;--ink:#1d2330;--paper:#f6f8fb;--card:#fff;--rule:#d5dce8;color-scheme:light dark}
@media (prefers-color-scheme:dark){:root{--ink:#e6eaf2;--paper:#10151f;--card:#171e2b;--rule:#2b3547;--blue:#6fb0ee}}
*{box-sizing:border-box}
body{margin:0;background:var(--paper);color:var(--ink);font:17px/1.6 "Segoe UI",system-ui,-apple-system,Roboto,sans-serif}
.hero{background:linear-gradient(135deg,#002e64,#0064aa);color:#fff;text-align:center;padding:3.2rem 1.2rem 3rem}
.hero h1{margin:0;font-size:clamp(2rem,6vw,3.2rem);letter-spacing:.01em}
.hero .sub{margin:.3rem 0 0;font-size:1.25rem;opacity:.9}
.hero .by{margin:1.1rem 0 1.6rem;opacity:.85;font-size:.98rem}
.btns{display:flex;flex-wrap:wrap;gap:.7rem;justify-content:center}
.btn{display:inline-block;padding:.65rem 1.5rem;border-radius:999px;font-weight:600;text-decoration:none;border:2px solid #fff;color:#fff}
.btn.primary{background:#fff;color:var(--navy)}
.btn:hover{background:rgba(255,255,255,.2)}.btn.primary:hover{background:#e6f0fb}
main{max-width:62rem;margin:0 auto;padding:2rem 1.2rem 3rem}
h2{color:var(--navy);border-bottom:2px solid var(--rule);padding-bottom:.3rem;margin:2.2rem 0 1rem}
@media (prefers-color-scheme:dark){h2{color:#9db4ff}}
.about p{text-align:justify;hyphens:auto}
.part{margin:1.8rem 0 .6rem;color:var(--blue);font-size:1.05rem;text-transform:uppercase;letter-spacing:.05em}
.toc{display:grid;grid-template-columns:repeat(auto-fill,minmax(17rem,1fr));gap:1rem}
.part,.toc-h{grid-column:1/-1}
.ch{background:var(--card);border:1px solid var(--rule);border-top:3px solid var(--navy);border-radius:6px;padding:.8rem 1rem}
.ch h4{margin:0 0 .4rem;font-size:1.05rem}
.ch h4 a{color:inherit;text-decoration:none}.ch h4 a:hover{color:var(--blue)}
.ch .n{display:inline-block;min-width:1.7rem;margin-right:.4rem;color:var(--blue)}
.ch ul{margin:0;padding:0;list-style:none;font-size:.88rem;color:var(--ink);opacity:.85}
.ch li{padding:.1rem 0}.ch li span{color:var(--blue);margin-right:.3rem}
.authors{display:flex;flex-wrap:wrap;gap:1.2rem;justify-content:center}
.au{display:flex;flex-direction:column;align-items:center;text-align:center;width:16rem;padding:1rem;background:var(--card);border:1px solid var(--rule);border-radius:8px;text-decoration:none;color:inherit}
.au:hover{border-color:var(--blue)}
.au img{width:130px;height:130px;border-radius:50%;object-fit:cover;margin-bottom:.6rem;border:3px solid var(--navy)}
.au span{font-size:.85rem;opacity:.8}
footer{text-align:center;padding:1.4rem 1rem 2.2rem;font-size:.9rem;opacity:.75}
</style>
</head>
<body>
<header class="hero">
<h1>Класична електродинаміка</h1>
<p class="sub">Збірник задач</p>
<p class="by">В. І. Жданов, С. М. Пономаренко, В. Б. Долгошей · КПІ ім. Ігоря Сікорського</p>
<div class="btns">
<a class="btn primary" href="online/">Читати онлайн</a>
<a class="btn" href="FTProblems.pdf">Завантажити PDF</a>
</div>
</header>
<main>
<section class="about">
<h2>Про посібник</h2>
<p>Вивчення класичної електродинаміки забезпечується дисциплінами «Теорія поля» та «Електродинаміка суцільних середовищ», які входять до циклу базової та професійної підготовки бакалаврів за спеціальностями «Прикладна фізика та наноматеріали» і «Прикладна математика» й вивчаються студентами Фізико-технічного інституту КПІ ім. Ігоря Сікорського на третьому курсі. Велика частина програмного матеріалу пов’язана з умінням розв’язувати конкретні задачі, тому потрібна значна самостійна робота студента.</p>
<p>Назви розділів і підрозділів посібника відповідають робочим програмам дисциплін. До кожного з них подано короткий теоретичний матеріал з основними формулами, необхідними для розв’язування задач; наприкінці — відповіді, довідковий матеріал і перелік літератури. Частину задач узято з джерел, наведених у списку літератури, але є й чимало авторських задач, ідеї яких сформувалися на основі власного досвіду викладання.</p>
<p>Це електронне видання: для зручності передбачено гіперпосилання та бічну панель змісту.</p>
</section>
<section>
<h2>Автори</h2>
<div class="authors">
<a class="au" href="https://apd.ipt.kpi.ua/kafedra/stuff/zhdanov/"><img src="authors/zhdanov.jpg" alt="Валерій Іванович Жданов" width="130" height="130"><b>Валерій Іванович Жданов</b><span>доктор фізико-математичних наук, професор</span></a>
<a class="au" href="https://apd.ipt.kpi.ua/kafedra/stuff/ponomarenko/"><img src="authors/ponomarenko.jpg" alt="Сергій Миколайович Пономаренко" width="130" height="130"><b>Сергій Миколайович Пономаренко</b><span>кандидат фізико-математичних наук, доцент кафедри прикладної фізики</span></a>
<a class="au" href="https://apd.ipt.kpi.ua/kafedra/stuff/dolgoshey/"><img src="authors/dolgoshey.jpg" alt="Володимир Борисович Долгошей" width="130" height="130"><b>Володимир Борисович Долгошей</b><span>кандидат фізико-математичних наук, доцент кафедри прикладної фізики</span></a>
</div>
</section>
<section>
<h2>Зміст</h2>
<div class="toc">
@@TOC@@
</div>
</section>
</main>
<footer>© В. І. Жданов, С. М. Пономаренко, В. Б. Долгошей, КПІ ім. Ігоря Сікорського</footer>
</body>
</html>
"""

if __name__ == "__main__":
    OUT.write_text(page(parse()), encoding="utf-8", newline="\n")
    print("written", OUT)
