#!/usr/bin/env python3
"""Build styled HTML pages from the documentation Markdown.

The Markdown files carry their layout as inline HTML (sidebar, buttons, content
column) but cannot carry a stylesheet: GitHub strips <style> and prints its text.
Here the same content is wrapped in a real HTML document, so the code blocks,
tables and syntax colours that GitHub cannot show are available locally.

    mdhtml.py out_dir file.md[:prefix] ...
"""
import html
import os
import re
import sys

# ------------------------------------------------------------------- style ----
CSS = """
:root { color-scheme: light; }
body { margin:0; background:#ffffff; color:#24292f;
       font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;
       font-size:15px; line-height:1.6; }
h1,h2,h3,h4,h5,h6 { line-height:1.3; margin:26px 0 10px 0; }
h1 { font-size:26px; } h2 { font-size:22px; border-bottom:1px solid #d8dce0;
     padding-bottom:6px; } h3 { font-size:18px; } h4 { font-size:16px; }
h5,h6 { font-size:15px; }
a { color:#0a58ca; }
img { max-width:100%; }
p { margin:10px 0; }
ul { margin:8px 0 8px 0; padding-left:26px; }
li { margin:3px 0; }
hr { border:0; border-top:1px solid #d8dce0; margin:24px 0; }

pre { background:#e4e6e8; padding:12px 14px; border:1px solid #d8dce0;
      border-radius:6px; overflow-x:auto; }
pre code { background:transparent; color:#1f2328; padding:0;
           font-size:13px; line-height:1.5; }
code { background:#e4e6e8; color:#1f2328; padding:1px 4px; border-radius:4px;
       font-family:'Cascadia Code',Consolas,'Liberation Mono',monospace;
       font-size:13px; }

.c-com { color:#6a737d; font-style:italic; }
.c-str { color:#032f62; }
.c-key { color:#d73a49; }
.c-num { color:#005cc5; }
.c-pre { color:#e36209; }

table { border-collapse:collapse; margin:8px 0 16px 0; }
th, td { border:1px solid #c9ced4; padding:6px 10px; vertical-align:top; }
th { background:#eef1f4; text-align:left; }

details > summary { cursor:pointer; }
"""

# --------------------------------------------------------- syntax colouring ----
KEYWORDS = set("""auto break case char const continue default do double else enum
extern float for goto if inline int long register return short signed sizeof static
struct switch typedef union unsigned void volatile while bool true false uint8_t
uint16_t uint32_t int8_t int16_t int32_t size_t class public private virtual new
delete this namespace using template import from def lambda None True False and or
not in is elif except raise with as pass global nonlocal yield assert""".split())

TOKEN = re.compile(r"""
    (?P<com>//[^\n]*|\#[^\n]*|/\*.*?\*/)
  | (?P<str>"[^"\n]*"|'[^'\n]*')
  | (?P<pre>^\s*\#\s*(?:include|define|ifdef|ifndef|endif)\b[^\n]*)
  | (?P<num>\b\d+\b)
  | (?P<word>[A-Za-z_]\w*)
""", re.X | re.S | re.M)


def highlight(code, lang):
    out, last = [], 0
    for m in TOKEN.finditer(code):
        out.append(html.escape(code[last:m.start()]))
        kind = m.lastgroup
        text = html.escape(m.group())
        if kind == 'word':
            out.append(f'<span class="c-key">{text}</span>'
                       if m.group() in KEYWORDS else text)
        else:
            cls = {'com': 'c-com', 'str': 'c-str', 'num': 'c-num', 'pre': 'c-pre'}[kind]
            out.append(f'<span class="{cls}">{text}</span>')
        last = m.end()
    out.append(html.escape(code[last:]))
    return ''.join(out)


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


PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>{css}</style>
</head>
<body>
{body}
</body>
</html>
"""

# ------------------------------------------------------------------- build ----
out_dir = sys.argv[1]
os.makedirs(out_dir, exist_ok=True)
doc_names = {}
for spec in sys.argv[2:]:
    src = spec.split(':')[0]
    doc_names[os.path.basename(src)] = os.path.basename(src)[:-3] + '.html'

for spec in sys.argv[2:]:
    src, _, prefix = spec.partition(':')
    md = open(src, encoding='utf-8').read()

    # links between documents point at the html build; everything else is a
    # repository path that has to climb back out of the html directory
    def fix(path):
        base = os.path.basename(path)
        if base in doc_names:
            return doc_names[base]
        if path.startswith(('http', '#', 'mailto:')):
            return path
        return prefix + path

    md = re.sub(r'(\]\()([^)]+)(\))', lambda m: m.group(1) + fix(m.group(2)) + m.group(3), md)
    md = re.sub(r'(<a href=")([^"]+)(")', lambda m: m.group(1) + fix(m.group(2)) + m.group(3), md)
    md = re.sub(r'(<img src=")([^"]+)(")', lambda m: m.group(1) + fix(m.group(2)) + m.group(3), md)

    title = re.search(r'>([^<>]+?)</div>', md)
    title = re.sub(r'<br>', ' ', title.group(1)).strip() if title else os.path.basename(src)
    dest = os.path.join(out_dir, doc_names[os.path.basename(src)])
    open(dest, 'w', encoding='utf-8').write(
        PAGE.format(title=html.escape(title), css=CSS, body=render(md)))
    print(f'  {dest}')
