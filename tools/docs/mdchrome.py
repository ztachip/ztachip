#!/usr/bin/env python3
"""Give an existing Markdown document the same presentation as the converted
programmer guides: numbered headings, a black expandable sidebar, white content
column, light grey code blocks and styled tables.

    mdchrome.py in.md out.md "Title<br>Second line" [code-language]
"""
import os
import re
import sys

SRC = sys.argv[1]
OUT = sys.argv[2]
DOC_TITLE = sys.argv[3] if len(sys.argv) > 3 else 'Guide'
LANG = sys.argv[4] if len(sys.argv) > 4 else ''
# pass '-' as the title for a plain document: numbering and grids, but no
# sidebar and no stylesheet
PANEL = DOC_TITLE != '-'
# relative path back to the documentation index, if the page should carry a
# Home button
HOME = os.environ.get('DOC_HOME', '')

raw = open(SRC, encoding='utf-8').read().split('\n')

# A document whose only level-1 heading is its title: that title belongs in the
# sidebar plate, so everything below it moves up a level and the sections of the
# document become the chapters.
tops = [ln for ln in raw if re.match(r'^#\s+\S', ln)]
first = next((ln for ln in raw if ln.strip()), '')
PROMOTE = PANEL and len(tops) == 1 and first.startswith('# ')

# ------------------------------------------------------------------ body ----
body, headings = [], []
counters = [0] * 6
in_code = False

for line in raw:
    stripped = line.rstrip()

    if stripped.startswith('```'):
        if not in_code and stripped == '```' and LANG:
            stripped = '```' + LANG
        in_code = not in_code
        body.append(stripped)
        continue

    if in_code:
        body.append(line.rstrip())
        continue

    m = re.match(r'^(#{1,6})\s+(.*)$', stripped)
    if m:
        level = len(m.group(1))
        if PROMOTE:
            if level == 1:
                continue          # the title now lives in the sidebar
            level -= 1
        title = m.group(2).strip().rstrip('.: ')
        counters[level - 1] += 1
        for i in range(level, 6):
            counters[i] = 0
        number = '.'.join(str(counters[i]) for i in range(level))
        if level == 1:
            number += '.'
        # with a sidebar the document title lives there, so the body headings
        # move down one; without it they keep their own level
        depth = level + 1 if PANEL else level
        body.append(f'{"#" * depth} {number} {title}')
        headings.append((level, number, title))
        continue

    # a paragraph that is nothing but one inline-code span is a listing
    lone = re.match(r'^`([^`]+)`$', stripped)
    if lone:
        body.append('```' + LANG)
        body.append(lone.group(1))
        body.append('```')
        continue

    body.append(stripped)

# ------------------------------------------------- parameter lists to grids ----
GRID_SECTIONS = re.compile(r'^(parameters?|interfaces?|sub-?components?|components?)$',
                           re.I)


def starts_grid(line):
    """A 'Parameters:' style label, or a heading that introduces a definition list."""
    t = line.strip()
    m = re.match(r'^#{2,6}\s+[\d.]+\s+(.*)$', t)
    if m:
        return bool(GRID_SECTIONS.match(m.group(1).strip()))
    return bool(GRID_SECTIONS.match(t.rstrip(':').strip()))


# a name cell: an identifier, a wildcard like bus_*, or a markdown link
NAME_CELL = re.compile(r'^(\[[^\]]+\]\([^)]+\)|[\w*./-]+(\s+[\w*./-]+)?)$')


def looks_like_name(text):
    t = text.strip()
    return bool(t) and len(t) <= 40 and bool(NAME_CELL.match(t))


def parameters_to_table(lines):
    """Turn a 'name: description' bullet list into a Name/Description grid.

    Used for parameter lists and for the Interfaces / Subcomponents sections.
    Descriptions wrapped over several source lines are joined, and nested
    bullets (a parameter's accepted values) fold into their parent row.
    """
    out, i = [], 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        if not starts_grid(line):
            i += 1
            continue

        j, rows, ok, prev_blank = i + 1, [], True, True
        while j < len(lines):
            item = lines[j]
            if item.strip() == '':
                prev_blank = True
                j += 1
                continue
            top = re.match(r'^-\s+(.*)$', item)
            sub = re.match(r'^\s+-\s+(.*)$', item)
            if top:
                text = top.group(1)
                name, sep, desc = text.partition(':')
                if not sep or not desc.strip():
                    # some entries have no colon; the link is the name and the
                    # rest of the line is the description
                    m = re.match(r'^(\[[^\]]+\]\([^)]+\))\s+(\S.*)$', text)
                    if not m:
                        ok = False
                        break
                    name, desc = m.group(1), m.group(2)
                rows.append([name.strip(), desc.strip()])
            elif sub and rows:
                rows[-1][1] += '<br>' + sub.group(1).strip()
            else:
                # some sections list their entries as plain paragraphs rather
                # than bullets: "name : description"
                name, sep, desc = item.partition(':')
                if sep and desc.strip() and looks_like_name(name):
                    rows.append([name.strip(), desc.strip()])
                elif rows and not prev_blank:
                    # the description wrapped onto the next source line
                    rows[-1][1] += ' ' + item.strip()
                else:
                    break
            prev_blank = False
            j += 1

        if not ok or not rows:      # a single entry is still a grid
            i += 1
            continue

        out.append('')
        out.append('| Name | Description |')
        out.append('| --- | --- |')
        for name, desc in rows:
            out.append(f'| {name} | {desc} |')
        out.append('')
        i = j
    return out


body = parameters_to_table(body)

# collapse runs of blank lines outside code
clean, blank, in_code = [], False, False
for line in body:
    if line.startswith('```'):
        in_code = not in_code
    if not in_code and line == '':
        if blank:
            continue
        blank = True
    else:
        blank = False
    clean.append(line)


# --------------------------------------------------------------- sidebar ----
def anchor(number, title):
    slug = f'{number} {title}'.lower()
    slug = re.sub(r'[^\w\s-]', '', slug)
    return re.sub(r'\s+', '-', slug.strip())


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


LINK_STYLE = 'color:#e8eaed; text-decoration:none;'


def short(title):
    """Sidebar label: the function name without its parameter list."""
    return re.sub(r'\s*[(\[].*$', '', title).strip() or title


def link(number, title):
    # the anchor still points at the full heading; only the label is shortened
    return (f'<a href="#{anchor(number, title)}" style="{LINK_STYLE}">'
            f'{esc(number)} {esc(short(title))}</a>')


tree = []
for level, number, title in headings:
    if level == 1:
        tree.append((number, title, []))
    elif level == 2 and tree:
        tree[-1][2].append((number, title, []))
    elif level == 3 and tree and tree[-1][2]:
        tree[-1][2][-1][2].append((number, title))

nav = ['<div style="display:flex; align-items:flex-start; gap:0;'
       ' background:#ffffff; color:#24292f;">',
       '',
       '<div style="flex:0 0 auto; width:200px; min-width:120px; max-width:70%;'
       ' resize:horizontal; overflow:auto; height:100vh; box-sizing:border-box;'
       ' position:sticky;'
       ' top:0; padding:12px 14px 24px 14px; background:#000000; color:#e8eaed;'
       ' font-size:13px; line-height:1.7;">',
       '',
       '<div style="background:#d6e8ff; color:#0b2545; padding:9px 10px;'
       ' border-radius:6px; text-align:center; font-weight:bold;'
       f' font-size:13px; line-height:1.35; margin-bottom:14px;">{DOC_TITLE}</div>',
       '',
       '<b>Contents</b>',
       '']
if HOME:
    nav.insert(4, f'<a href="{HOME}" style="display:inline-block;'
                  ' margin-bottom:12px; padding:5px 10px; background:#1f2937;'
                  ' color:#e8eaed; border:1px solid #3a4553; border-radius:5px;'
                  ' text-decoration:none; font-size:12px;">&#8592; Home</a>')
    nav.insert(5, '')
for number, title, sections in tree:
    nav.append('<details open>')
    nav.append(f'<summary><b>{link(number, title)}</b></summary>')
    if sections:
        nav.append('<ul style="margin:4px 0 4px 6px; padding-left:14px;">')
        for snum, stitle, subs in sections:
            if subs:
                nav.append('<li><details>')
                nav.append(f'<summary>{link(snum, stitle)}</summary>')
                nav.append('<ul style="margin:2px 0 2px 4px; padding-left:14px;">')
                for tnum, ttitle in subs:
                    nav.append(f'<li>{link(tnum, ttitle)}</li>')
                nav.append('</ul>')
                nav.append('</details></li>')
            else:
                nav.append(f'<li>{link(snum, stitle)}</li>')
        nav.append('</ul>')
    nav.append('</details>')
    nav.append('')
nav.append('</div>')

STYLE = '''<style>
pre { background:#e4e6e8 !important;
      padding:12px 14px; border:1px solid #d8dce0; border-radius:6px; }

/* Base: the highlighter paints tokens with the editor theme, which on a dark
   theme is far too light for this grey. Everything starts near-black ... */
pre, pre code, pre span, pre * {
      background:transparent !important; color:#1f2328 !important; }

/* ... then the token classes take over, in a palette meant for a light
   background. These are more specific, so they win over the rule above. */
pre code .hljs-comment, pre code .hljs-quote {
      color:#6a737d !important; font-style:italic; }
pre code .hljs-keyword, pre code .hljs-selector-tag,
pre code .hljs-literal, pre code .hljs-doctag {
      color:#d73a49 !important; }
pre code .hljs-string, pre code .hljs-meta-string,
pre code .hljs-regexp { color:#032f62 !important; }
pre code .hljs-number, pre code .hljs-built_in,
pre code .hljs-type, pre code .hljs-variable,
pre code .hljs-template-variable { color:#005cc5 !important; }
pre code .hljs-title, pre code .hljs-section,
pre code .hljs-function .hljs-title { color:#6f42c1 !important; }
pre code .hljs-meta, pre code .hljs-meta-keyword {
      color:#e36209 !important; }
pre code .hljs-attr, pre code .hljs-attribute,
pre code .hljs-name { color:#22863a !important; }
pre code .pl-c, pre code .pl-c span {
      color:#6a737d !important; font-style:italic; }
pre code .pl-k { color:#d73a49 !important; }
pre code .pl-s, pre code .pl-s span, pre code .pl-pds {
      color:#032f62 !important; }
pre code .pl-c1, pre code .pl-cce { color:#005cc5 !important; }
pre code .pl-en, pre code .pl-entl { color:#6f42c1 !important; }

/* inline code: !important so a dark editor theme cannot repaint it */
code { background:#e4e6e8 !important; color:#1f2328 !important;
       padding:1px 4px; border-radius:4px; }

/* tables need visible rules on the white page */
table { border-collapse:collapse !important; margin:6px 0 14px 0; }
table th, table td { border:1px solid #c9ced4 !important;
       padding:6px 10px !important; }
table th { background:#eef1f4 !important; color:#1f2328 !important;
       text-align:left; }
table tr, table tbody tr:nth-child(2n) {
       background:#ffffff !important; color:#1f2328 !important; }
</style>'''

if PANEL:
    out = (nav +
           ['', '<div style="flex:1 1 auto; min-width:0; background:#ffffff;'
            ' color:#24292f; padding:0 24px;">', ''] +
           clean + ['', '</div>', '', '</div>'])
else:
    # no sidebar, but the same stylesheet and the same white page
    home = ([f'<a href="{HOME}" style="display:inline-block; margin:14px 0;'
             ' padding:5px 12px; background:#eef1f4; color:#24292f;'
             ' border:1px solid #c9ced4; border-radius:5px;'
             ' text-decoration:none; font-size:13px;">&#8592; Home</a>', '']
            if HOME else [])
    out = ([
            '<div style="background:#ffffff; color:#24292f; padding:0 24px;">',
            ''] + home + clean + ['', '</div>'])

open(OUT, 'w', encoding='utf-8').write('\n'.join(out).rstrip() + '\n')
print(f'{OUT}: {len(out)} lines, {len(headings)} headings')
