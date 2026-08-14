#!/usr/bin/env python3
"""Build styled HTML pages from the documentation Markdown.

The output directory is self-contained: images are copied in beside the pages
and links to repository files are rewritten to github.com, so the same build
works opened from disk and published to GitHub Pages.

The Markdown files carry their layout as inline HTML (sidebar, buttons, content
column) but cannot carry a stylesheet: GitHub strips <style> and prints its text.
Here the same content is wrapped in a real HTML document, so the code blocks,
tables and syntax colours that GitHub cannot show are available locally.

    mdhtml.py out_dir file.md ...
"""
import html
import os
import shutil
import re
import sys

# ------------------------------------------------------------------- style ----
CSS = """
:root { color-scheme: light; }
body { margin:0; background:#ffffff; color:#24292f;
       font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;
       font-size:17px; line-height:1.65; }
h1,h2,h3,h4,h5,h6 { line-height:1.3; margin:26px 0 10px 0; }
h1 { font-size:30px; } h2 { font-size:25px; border-bottom:1px solid #d8dce0;
     padding-bottom:6px; } h3 { font-size:20px; } h4 { font-size:18px; }
h5,h6 { font-size:17px; }
a { color:#0a58ca; }
img { max-width:100%; }
p { margin:10px 0; }
ul { margin:8px 0 8px 0; padding-left:26px; }
li { margin:3px 0; }
hr { border:0; border-top:1px solid #d8dce0; margin:24px 0; }

pre { background:#e4e6e8; padding:12px 14px; border:1px solid #d8dce0;
      border-radius:6px; overflow-x:auto; }
pre code { background:transparent; color:#1f2328; padding:0;
           font-size:14px; line-height:1.55; }
code { background:#e4e6e8; color:#1f2328; padding:1px 4px; border-radius:4px;
       font-family:'Cascadia Code',Consolas,'Liberation Mono',monospace;
       font-size:14px; }


table { border-collapse:collapse; margin:8px 0 16px 0; }
th, td { border:1px solid #c9ced4; padding:6px 10px; vertical-align:top; }
th { background:#eef1f4; text-align:left; }

details > summary { cursor:pointer; }
"""

def highlight(code, lang):
    """Code is rendered as plain text: no token colouring."""
    return html.escape(code)


# ------------------------------------------------------------ inline markup ----
def inline(text):
    text = html.escape(text)
    text = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)',
                  lambda m: f'<img src="{m.group(2)}" alt="{m.group(1)}">', text)
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)',
                  lambda m: f'<a href="{m.group(2)}">{m.group(1)}</a>', text)
    text = re.sub(r'`([^`]+)`', lambda m: f'<code>{m.group(1)}</code>', text)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'(?<![*\w])\*([^*]+)\*(?!\*)', r'<em>\1</em>', text)
    text = text.replace('&lt;br&gt;', '<br>')
    return text


def slug(title):
    title = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', title)   # [text](link) -> text
    s = re.sub(r'[^\w\s-]', '', title.lower())
    return re.sub(r'\s+', '-', s.strip())


# ------------------------------------------------------------------ blocks ----
def render(md):
    out, i, lines = [], 0, md.split('\n')
    while i < len(lines):
        line = lines[i]

        # fenced code
        m = re.match(r'^```(\w*)\s*$', line)
        if m:
            lang, body, i = m.group(1), [], i + 1
            while i < len(lines) and not lines[i].startswith('```'):
                body.append(lines[i])
                i += 1
            i += 1
            code = '\n'.join(body)
            out.append(f'<pre><code>{highlight(code, lang)}</code></pre>')
            continue

        # raw html passes straight through
        if line.lstrip().startswith(('<div', '</div', '<a ', '</a', '<details',
                                     '</details', '<summary', '</summary', '<ul',
                                     '</ul', '<li', '</li', '<b>', '<p ', '</p',
                                     '<table', '</table', '<tr', '<td', '<th',
                                     '<span', '<img')):
            out.append(line)
            i += 1
            continue

        # heading
        m = re.match(r'^(#{1,6})\s+(.*)$', line)
        if m:
            level, title = len(m.group(1)), m.group(2).strip()
            out.append(f'<h{level} id="{slug(title)}">{inline(title)}</h{level}>')
            i += 1
            continue

        # table
        if line.startswith('|') and i + 1 < len(lines) and \
                re.match(r'^\|[\s:|-]+\|\s*$', lines[i + 1]):
            head = [c.strip() for c in line.strip('|').split('|')]
            rows, i = [], i + 2
            while i < len(lines) and lines[i].startswith('|'):
                rows.append([c.strip() for c in lines[i].strip('|').split('|')])
                i += 1
            out.append('<table>')
            out.append('<tr>' + ''.join(f'<th>{inline(c)}</th>' for c in head) + '</tr>')
            for r in rows:
                out.append('<tr>' + ''.join(f'<td>{inline(c)}</td>' for c in r) + '</tr>')
            out.append('</table>')
            continue

        # list
        if re.match(r'^\s*-\s+', line):
            depth_stack = []
            while i < len(lines) and (re.match(r'^\s*-\s+', lines[i]) or
                                      (lines[i].strip() == '' and i + 1 < len(lines)
                                       and re.match(r'^\s*-\s+', lines[i + 1]))):
                if lines[i].strip() == '':
                    i += 1
                    continue
                indent = len(lines[i]) - len(lines[i].lstrip())
                text = re.sub(r'^\s*-\s+', '', lines[i])
                while depth_stack and indent < depth_stack[-1]:
                    out.append('</ul>')
                    depth_stack.pop()
                if not depth_stack or indent > depth_stack[-1]:
                    out.append('<ul>')
                    depth_stack.append(indent)
                out.append(f'<li>{inline(text)}</li>')
                i += 1
            for _ in depth_stack:
                out.append('</ul>')
            continue

        if line.strip() == '':
            i += 1
            continue

        if line.strip() == '---':
            out.append('<hr>')
            i += 1
            continue

        # paragraph
        para = [line]
        i += 1
        while i < len(lines) and lines[i].strip() and \
                not re.match(r'^(\s*-\s+|#{1,6}\s|```|\||<)', lines[i]):
            para.append(lines[i])
            i += 1
        out.append(f'<p>{inline(" ".join(para))}</p>')
    return '\n'.join(out)


SIDE = """
.layout { display:flex; align-items:flex-start; gap:0; }
.side { flex:0 0 auto; width:290px; min-width:150px; max-width:70%;
        resize:horizontal; overflow:auto; height:100vh; box-sizing:border-box;
        position:sticky; top:0; background:#000000; color:#e8eaed;
        padding:14px 16px 26px 16px; font-size:14px; line-height:1.7; }
.side a { color:#e8eaed; text-decoration:none; }
.side a:hover { text-decoration:underline; }
.side ul { list-style:none; margin:4px 0 4px 4px; padding-left:12px; }
.side .plate { background:#d6e8ff; color:#0b2545; padding:9px 10px;
        border-radius:6px; text-align:center; font-weight:bold;
        margin:0 0 14px 0; line-height:1.35; }
.side .home { display:inline-block; margin-bottom:12px; padding:5px 10px;
        background:#1f2937; color:#e8eaed; border:1px solid #3a4553;
        border-radius:5px; font-size:12px; }
.main { flex:1 1 auto; min-width:0; padding:0 30px; max-width:940px; }
/* pages without a navigation panel still need breathing room */
.page { padding:0 40px; max-width:940px; }
"""


def sidebar(body, title, home):
    """Build the navigation panel from the headings of the rendered page."""
    heads = re.findall(r'<h([2-4]) id="([^"]+)">(.*?)</h\1>', body)
    if not heads:
        return ''
    out = ['<div class="side">']
    if home:
        out.append(f'<a class="home" href="{home}">&#8592; Home</a>')
    out.append(f'<div class="plate">{title}</div>')
    out.append('<b>Contents</b>')
    depth = 0
    for lvl, hid, text in heads:
        lvl = int(lvl) - 1
        text = re.sub(r'<[^>]+>', '', text)
        text = re.sub(r'\s*[(\[].*$', '', text).strip() or text
        while depth < lvl:
            out.append('<ul>'); depth += 1
        while depth > lvl:
            out.append('</ul>'); depth -= 1
        out.append(f'<li><a href="#{hid}">{text}</a></li>')
    out += ['</ul>'] * depth
    out.append('</div>')
    return '\n'.join(out)


PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>{css}{side}</style>
</head>
<body>
{body}
</body>
</html>
"""

# ------------------------------------------------------------------- build ----
GITHUB = 'https://github.com/ztachip/ztachip/blob/master/'
MEDIA = 'media'

# Page names used by the previous documentation site. Links to them are still
# out in the wild, so the build leaves a redirect at each old name.
REDIRECTS = {
    'overview.html': 'Overview.html',
    'hardware_design.html': 'HardwareDesign.html',
    'programmer_guide.html': 'ztachip_programmer_guide.html',
    'visionai_guide.html': 'visionai_programmer_guide.html',
    'micropython_guide.html': 'MicropythonUserGuide.html',
    'genindex.html': 'index.html',
    'search.html': 'index.html',
}

REDIRECT_PAGE = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url={target}">
<link rel="canonical" href="{target}">
<title>Moved</title>
</head>
<body>
<p>This page has moved to <a href="{target}">{target}</a>.</p>
</body>
</html>
'''

out_dir = sys.argv[1]
os.makedirs(os.path.join(out_dir, MEDIA), exist_ok=True)
sources = sys.argv[2:]
doc_names = {os.path.basename(s): os.path.basename(s)[:-3] + '.html' for s in sources}

for src in sources:
    doc_dir = os.path.dirname(src)
    md = open(src, encoding='utf-8').read()
    copied = {}

    def repo_path(path):
        return os.path.normpath(os.path.join(doc_dir, path))

    def fix(path, is_image=False):
        if path.startswith(('http', '#', 'mailto:')):
            return path
        base = os.path.basename(path)
        if base in doc_names:                    # another document
            return doc_names[base]
        target = repo_path(path)
        if is_image:                             # copy it in beside the pages
            name = target.replace(os.sep, '_')
            if target not in copied and os.path.exists(target):
                shutil.copyfile(target, os.path.join(out_dir, MEDIA, name))
                copied[target] = True
            return f'{MEDIA}/{name}'
        return GITHUB + target.replace(os.sep, '/')

    md = re.sub(r'(!\[[^\]]*\]\()([^)]+)(\))',
                lambda m: m.group(1) + fix(m.group(2), True) + m.group(3), md)
    md = re.sub(r'(?<!!)(\[[^\]]*\]\()([^)]+)(\))',
                lambda m: m.group(1) + fix(m.group(2)) + m.group(3), md)
    md = re.sub(r'(<a href=")([^"]+)(")',
                lambda m: m.group(1) + fix(m.group(2)) + m.group(3), md)
    md = re.sub(r'(<img src=")([^"]+)(")',
                lambda m: m.group(1) + fix(m.group(2), True) + m.group(3), md)

    m = re.search(r'^#\s+(.*)$', md, re.M)
    title = m.group(1).strip() if m else os.path.basename(src)
    # the link rewrite above already points this at the html build
    home = re.search(r'\[&#8592; Home\]\(([^)]+)\)', md)
    home = home.group(1) if home else ''

    # the panel replaces the in-page contents block and the home link
    md = re.sub(r'\[&#8592; Home\]\([^)]+\)\n', '', md)
    md = re.sub(r'<details>\s*\n<summary><b>Contents</b></summary>.*?</details>',
                '', md, flags=re.S)

    body = render(md)
    # the launcher is the navigation; it needs no panel of its own
    panel = ('' if os.path.basename(src) == 'index.md'
             else sidebar(body, html.escape(title), home))
    body = (f'<div class="layout">{panel}<div class="main">{body}</div></div>'
            if panel else f'<div class="page">{body}</div>')
    dest = os.path.join(out_dir, doc_names[os.path.basename(src)])
    open(dest, 'w', encoding='utf-8').write(
        PAGE.format(title=html.escape(title), css=CSS, side=SIDE, body=body))
    print(f'  {dest}')

# redirects from the old site's page names
for old, new in REDIRECTS.items():
    if old in doc_names.values():          # never shadow a real page
        continue
    with open(os.path.join(out_dir, old), 'w', encoding='utf-8') as fh:
        fh.write(REDIRECT_PAGE.format(target=new))
    print(f'  {os.path.join(out_dir, old)} -> {new}')
