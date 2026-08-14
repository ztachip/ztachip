#!/usr/bin/env python3
"""Convert the ztachip Programmer's Guide (ODT source of the PDF) to Markdown.

The ODT carries the structure the PDF has lost: outline levels, paragraph styles
(monospace = code), list nesting and real table cells. Everything below keys off
those rather than trying to re-derive layout from the rendered page.
"""
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

SRC_CONTENT = sys.argv[1] if len(sys.argv) > 1 else 'content.xml'
SRC_STYLES = sys.argv[2] if len(sys.argv) > 2 else 'styles.xml'
OUT = sys.argv[3] if len(sys.argv) > 3 else 'out.md'

# per-document settings
DOC_TITLE = os.environ.get('DOC_TITLE', "ztachip<br>Programmer's Guide")
# {odt href: {"path": ..., "alt": ...}}
IMAGES = json.loads(os.environ.get('DOC_IMAGES', '{}'))
# relative path back to the documentation index, for the Home button
HOME = os.environ.get('DOC_HOME', '')

raw = open(SRC_CONTENT, encoding='utf-8').read()
NS = {k: v for k, v in re.findall(r'xmlns:(\w+)="([^"]+)"', raw[:8000])}


def q(path):
    a, b = path.split(':')
    return f'{{{NS[a]}}}{b}'


# ---------------------------------------------------------------- styles ----
STYLE = {}
for src in (SRC_CONTENT, SRC_STYLES):
    root = ET.parse(src).getroot()
    for st in root.iter(q('style:style')):
        tp = st.find(q('style:text-properties'))
        STYLE[st.get(q('style:name'))] = dict(
            parent=st.get(q('style:parent-style-name')),
            font=tp.get(q('style:font-name')) if tp is not None else None,
            weight=tp.get(q('fo:font-weight')) if tp is not None else None,
            italic=tp.get(q('fo:font-style')) if tp is not None else None,
            size=tp.get(q('fo:font-size')) if tp is not None else None,
        )

MONO_HINTS = ('mono', 'courier', 'consol', 'cascadia')


def inherited(name, key):
    seen = set()
    while name and name in STYLE and name not in seen:
        seen.add(name)
        val = STYLE[name].get(key)
        if val:
            return val
        name = STYLE[name]['parent']
    return None


def is_mono(style_name):
    font = inherited(style_name, 'font')
    return bool(font) and any(h in font.lower() for h in MONO_HINTS)


def is_bold(style_name):
    return (inherited(style_name, 'weight') or '') == 'bold'


def is_italic(style_name):
    return (inherited(style_name, 'italic') or '') == 'italic'


def is_display(style_name):
    """A chapter banner: a paragraph the author formatted to look like a heading
    instead of using an outline heading. Rendered as a heading, but left out of
    the automatic numbering so the outline numbers still match the PDF."""
    size = inherited(style_name, 'size') or ''
    try:
        pts = float(size.replace('pt', ''))
    except ValueError:
        return False
    return pts >= 20 and is_bold(style_name)


# ------------------------------------------------------------ inline text ----
def inline(el, in_code):
    """Text of an element, preserving ODF spacing constructs."""
    out = []
    for node in el:
        tag = node.tag.split('}')[1]
        if tag == 's':
            out.append(' ' * int(node.get(q('text:c')) or 1))
        elif tag == 'tab':
            out.append('    ' if in_code else ' ')
        elif tag == 'line-break':
            out.append('\n')
        elif tag == 'a':
            label = (node.text or '') + ''.join(inline(node, in_code))
            href = node.get(q('xlink:href')) or ''
            out.append(f'[{label}]({href})' if label != href else f'<{href}>')
        elif tag == 'span':
            inner = (node.text or '') + ''.join(inline(node, in_code))
            sn = node.get(q('text:style-name'))
            if not in_code and inner.strip():
                # keep the surrounding whitespace outside the markers, otherwise
                # adjacent spans lose the space that separates their tokens
                lead = inner[:len(inner) - len(inner.lstrip())]
                trail = inner[len(inner.rstrip()):]
                core = inner.strip()
                if is_mono(sn):
                    inner = f'{lead}`{core}`{trail}'
                elif is_bold(sn):
                    inner = f'{lead}**{core}**{trail}'
                elif is_italic(sn):
                    inner = f'{lead}*{core}*{trail}'
            out.append(inner)
        elif tag in ('soft-page-break', 'bookmark', 'bookmark-start',
                     'bookmark-end', 'sequence-decls'):
            pass
        else:
            out.append((node.text or '') + ''.join(inline(node, in_code)))
        if node.tail:
            out.append(node.tail)
    return out


def text_of(el, in_code=False):
    return (el.text or '') + ''.join(inline(el, in_code))


def clean_prose(s):
    s = s.replace(' ', ' ')
    s = re.sub(r'[ \t]+', ' ', s)
    # two inline-code spans sitting next to each other are one run of code
    s = s.replace('``', '')
    return s.strip()


def clean_code(s):
    # OpenOffice autocorrect turned the quotes in the code samples typographic;
    # put them back so the listings are valid source
    for bad, good in (('“', '"'), ('”', '"'), ('‘', "'"),
                      ('’', "'"), ('–', '-'), (' ', ' ')):
        s = s.replace(bad, good)
    return s.rstrip()


# ------------------------------------------------------------- conversion ----
body = ET.parse(SRC_CONTENT).getroot().find(q('office:body')).find(q('office:text'))

lines = []
headings = []          # (level, number, title)
counters = [0] * 6
code_buf = []


def flush_code():
    global code_buf
    while code_buf and not code_buf[0].strip():
        code_buf.pop(0)
    while code_buf and not code_buf[-1].strip():
        code_buf.pop()
    if code_buf:
        lines.append('```c')
        lines.extend(code_buf)
        lines.append('```')
        lines.append('')
    code_buf = []


def add(line=''):
    flush_code()
    lines.append(line)


def heading_title(el):
    title = clean_prose(text_of(el, in_code=True).replace('\n', ' '))
    return re.sub(r'^[-\u2013\s]+', '', title)


def do_heading(el, continuation=''):
    level = int(el.get(q('text:outline-level')) or 1)
    # headings are plain text on one line: a long signature may be broken over
    # several lines in the source, which would split the heading here
    title = heading_title(el)
    if continuation:
        title = f'{title} {continuation}'
    # A list header carries no number in the source document, so it must not
    # advance the counters either (this is what keeps 2.5 = FPU operators)
    if el.get(q('text:is-list-header')) == 'true':
        if title:
            add()
            add(f'{"#" * (level + 1)} {title}')
            add()
        return
    emit_heading(level, title)


def emit_heading(level, title):
    counters[level - 1] += 1
    for i in range(level, 6):
        counters[i] = 0
    number = '.'.join(str(counters[i]) for i in range(level))
    if level == 1:
        number += '.'
    add()
    add(f'{"#" * (level + 1)} {number} {title}')
    add()
    headings.append((level, number, title))


last_prose = [None]     # index in `lines` of the paragraph last emitted


def continues(prev, nxt):
    """True when the author broke one sentence across two paragraphs."""
    if not prev or not nxt:
        return False
    if prev.startswith(('#', '|', '-', '`')) or nxt.startswith(('#', '|', '-', '`')):
        return False
    if prev[-1] in '.:;!?"”)':
        return False
    return nxt[0].islower()


CODE_PUNCT = re.compile(r'[{};=<>#*,\[\]()]|::|//')


def mono_is_prose(text):
    """A monospace paragraph that is really a sentence or a label.

    Parts of this guide set descriptive text in the code font; without this they
    would be fenced as code."""
    t = text.strip()
    if not t or CODE_PUNCT.search(t):
        return False
    words = t.split()
    if len(words) >= 3:
        return t[0].isupper()
    return len(words) <= 2 and t[0].isupper() and t.isprintable()


def runs(el, mono, bold, italic):
    """Flatten a paragraph into styled text runs and line breaks.

    Yields ('t', text, mono, bold, italic) or ('b',). A single ODF paragraph can
    hold prose, a line break and then a listing line (see 3.5.1.x), so the
    breaks have to survive in order to classify each line on its own.
    """
    if el.text:
        yield ('t', el.text, mono, bold, italic)
    for node in el:
        tag = node.tag.split('}')[1]
        if tag == 'line-break':
            yield ('b',)
        elif tag == 's':
            yield ('t', ' ' * int(node.get(q('text:c')) or 1), mono, bold, italic)
        elif tag == 'tab':
            yield ('t', '    ', mono, bold, italic)
        elif tag in ('span', 'a'):
            sn = node.get(q('text:style-name'))
            yield from runs(node, mono or is_mono(sn),
                            bold or is_bold(sn), italic or is_italic(sn))
        elif tag in ('soft-page-break', 'bookmark', 'bookmark-start',
                     'bookmark-end', 'sequence-decls'):
            pass
        else:
            yield from runs(node, mono, bold, italic)
        if node.tail:
            yield ('t', node.tail, mono, bold, italic)


def segments(el):
    """Split a paragraph on line breaks into (text, is_code) pieces."""
    para_mono = is_mono(el.get(q('text:style-name')))
    segs, cur = [], []

    def close():
        raw = ''.join(r[1] for r in cur)
        has_mono = any(r[2] for r in cur if r[1].strip())
        has_plain = any(not r[2] for r in cur if r[1].strip())
        segs.append((cur[:], raw, para_mono or (has_mono and not has_plain)))
        cur.clear()

    for ev in runs(el, para_mono, False, False):
        if ev[0] == 'b':
            close()
        else:
            cur.append(ev)
    close()
    return segs


def render_prose(run_list):
    """Re-apply inline markers to a prose segment."""
    out = []
    for _, text, mono, bold, italic in run_list:
        if not text:
            continue
        if text.strip() and (mono or bold or italic):
            lead = text[:len(text) - len(text.lstrip())]
            trail = text[len(text.rstrip()):]
            core = text.strip()
            if mono:
                core = f'`{core}`'
            elif bold:
                core = f'**{core}**'
            elif italic:
                core = f'*{core}*'
            out.append(f'{lead}{core}{trail}')
        else:
            out.append(text)
    return clean_prose(''.join(out))


# Lines the author left outside the listing style but which clearly belong to
# it: comments, and the ':' / '\\' continuation marks used inside listings.
def is_artifact(text):
    return text.strip() in ('\\', '\\\\')


def code_orphan(text):
    t = text.strip()
    if not t:
        return False
    if t.startswith('//'):
        return True
    return len(t) <= 3 and set(t) <= set(':.')


def do_images(el):
    for fr in el.iter(q('draw:frame')):
        img = fr.find(q('draw:image'))
        href = img.get(q('xlink:href')) if img is not None else None
        info = IMAGES.get(href)
        if info:
            add()
            add(f'![{info["alt"]}]({info["path"]})')
            add()


def do_paragraph(el, code_follows=False):
    do_images(el)
    if is_display(el.get(q('text:style-name'))):
        title = clean_prose(text_of(el, in_code=True).replace('\n', ' '))
        title = re.sub(r'^\d+\s*[-.\u2013]\s*', '', title)
        if title:
            emit_heading(1, title)
            last_prose[0] = None
        return
    for run_list, raw, is_code in segments(el):
        if is_code:
            if not raw.strip() and not code_buf:
                continue
            if not code_buf and not code_follows and mono_is_prose(raw):
                txt = clean_prose(raw)
                if txt:
                    add(txt)
                    last_prose[0] = len(lines) - 1
                    add()
                continue
            if not is_artifact(raw):
                code_buf.append(clean_code(raw))
            continue
        txt = render_prose(run_list)
        if is_artifact(txt) or is_artifact(raw):
            continue
        if not txt:
            # a blank line inside an open listing keeps the listing together
            if code_buf and code_follows:
                code_buf.append('')
            continue
        if code_orphan(txt) and (code_buf or code_follows):
            code_buf.append(clean_code(raw.strip()))
            continue
        idx = last_prose[0]
        if code_buf == [] and idx is not None and idx == len(lines) - 2 \
                and continues(lines[idx], txt):
            lines[idx] = lines[idx] + ' ' + txt
            continue
        add(txt)
        last_prose[0] = len(lines) - 1
        add()


def do_list(el, depth=0):
    flush_code()
    for item in el.findall(q('text:list-item')) + el.findall(q('text:list-header')):
        first = True
        for child in item:
            tag = child.tag.split('}')[1]
            if tag == 'list':
                do_list(child, depth + 1)
            else:
                txt = clean_prose(text_of(child))
                if not txt:
                    continue
                pad = '  ' * depth
                lines.append(f'{pad}- {txt}' if first else f'{pad}  {txt}')
                first = False
    if depth == 0:
        lines.append('')


def cell_text(cell):
    parts = []
    for p in cell:
        tag = p.tag.split('}')[1]
        if tag == 'list':
            for item in p.iter(q('text:p')):
                t = clean_prose(text_of(item))
                if t:
                    parts.append('• ' + t)
        else:
            t = clean_prose(text_of(p, in_code=True).replace('\n', '<br>'))
            if t:
                parts.append(t)
    return '<br>'.join(parts).replace('|', '\\|')


IDENTIFIER = re.compile(r'^[A-Za-z_][\w.]*$')


def split_names(row):
    """Names of a parameter group, when a name cell lists several of them.

    Groups such as clip_x / clip_y / clip_w / clip_h share one description in
    the source. Returns the list of names, or None when the cell is ordinary.
    """
    if len(row) < 2 or '<br>' not in row[0]:
        return None
    names = [n.strip() for n in row[0].split('<br>') if n.strip()]
    if len(names) < 2 or not all(IDENTIFIER.match(n) for n in names):
        return None
    return names


def do_table(el, headers):
    flush_code()
    rows = []
    for row in el.iter(q('table:table-row')):
        cells = [cell_text(c) for c in row.findall(q('table:table-cell'))]
        if any(c for c in cells):
            rows.append(cells)
    if not rows:
        return
    width = max(len(r) for r in rows)
    rows = [r + [''] * (width - len(r)) for r in rows]
    head = headers[:width] + ['Description'] * (width - len(headers))

    # A parameter group needs its description merged down the rows it covers,
    # which markdown tables cannot express - fall back to html for that table.
    if any(split_names(r) for r in rows):
        def cell(text):
            return text.replace('\\|', '|')
        lines.append('<table>')
        lines.append('<tr>' + ''.join(f'<th>{h}</th>' for h in head) + '</tr>')
        for r in rows:
            names = split_names(r)
            if names:
                rest = ''.join(
                    f'<td rowspan="{len(names)}">{cell(c)}</td>' for c in r[1:])
                lines.append(f'<tr><td>{names[0]}</td>{rest}</tr>')
                for n in names[1:]:
                    lines.append(f'<tr><td>{n}</td></tr>')
            else:
                lines.append('<tr>' + ''.join(f'<td>{cell(c)}</td>' for c in r)
                             + '</tr>')
        lines.append('</table>')
        lines.append('')
        return

    lines.append('| ' + ' | '.join(head) + ' |')
    lines.append('|' + '|'.join([' --- '] * width) + '|')
    for r in rows:
        lines.append('| ' + ' | '.join(r) + ' |')
    lines.append('')


# The last table lists the shipped example programs; the rest describe
# parameters and values.
table_index = 0
TABLE_HEADERS = {19: ['Example', 'Source files']}

blocks = list(body)


def code_ahead(i):
    """True when the next paragraph carrying text is a real listing line.

    Code-font prose is stepped over rather than ending the search, so a run of
    such sentences inside a listing does not split it.
    """
    for el in blocks[i + 1:]:
        if el.tag.split('}')[1] != 'p':
            return False
        segs = segments(el)
        code_segs = [sg for sg in segs if sg[2] and sg[1].strip()]
        if any(not mono_is_prose(sg[1]) for sg in code_segs):
            return True
        text = ' '.join(sg[1] for sg in segs).strip()
        if not text or code_orphan(text) or code_segs:
            continue
        return False
    return False


# not every document carries a generated TOC; the body always starts at the
# first heading, and everything before it is the title page
first_heading = next((i for i, e in enumerate(blocks)
                      if e.tag == q('text:h')), 0)

consumed = set()
for i, el in enumerate(blocks):
    tag = el.tag.split('}')[1]
    if i < first_heading or i in consumed:   # title page, TOC, folded lines
        continue
    if tag == 'h':
        # a function signature broken over several lines continues in the
        # paragraphs that follow; pull them into the heading
        title = heading_title(el)
        extra, j = [], i + 1
        while title.count('(') > title.count(')') and j < len(blocks):
            nxt = blocks[j]
            if nxt.tag != q('text:p'):
                break
            segs = segments(nxt)
            if not segs or not all(s[2] for s in segs if s[1].strip()):
                break
            piece = ' '.join(s[1].strip() for s in segs if s[1].strip())
            if not piece:
                break
            extra.append(piece)
            title += ' ' + piece
            consumed.add(j)
            j += 1
        do_heading(el, ' '.join(extra))
    elif tag == 'p':
        do_paragraph(el, code_follows=code_ahead(i))
    elif tag == 'list':
        do_list(el)
    elif tag == 'table':
        do_table(el, TABLE_HEADERS.get(table_index, ['Name', 'Description']))
        table_index += 1
flush_code()


# ------------------------------------------------------------ front matter ----
def anchor(number, title):
    slug = f'{number} {title}'.lower()
    slug = re.sub(r'[^\w\s-]', '', slug)
    return re.sub(r'\s+', '-', slug.strip())


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


LINK_STYLE = 'color:#e8eaed; text-decoration:none;'


def link(number, title):
    return (f'<a href="#{anchor(number, title)}" style="{LINK_STYLE}">'
            f'{esc(number)} {esc(title)}</a>')


# Navigation tree, three levels deep: chapters open, sections collapsed
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
       # resize:horizontal puts a drag handle on the bottom-right corner of the
       # panel; the content column is flex:1 so it reflows as the panel changes
       '<div style="flex:0 0 auto; width:200px; min-width:120px; max-width:70%;'
       ' resize:horizontal; overflow:auto; height:100vh; box-sizing:border-box;'
       ' position:sticky;'
       ' top:0; padding:12px 14px 24px 14px; background:#000000; color:#e8eaed;'
       ' font-size:13px; line-height:1.7;">',
       '',
       # the guide's title now lives here, at the head of the panel
       '<div style="background:#d6e8ff; color:#0b2545; padding:9px 10px;'
       ' border-radius:6px; text-align:center; font-weight:bold;'
       ' font-size:13px; line-height:1.35; margin-bottom:14px;">'
       + DOC_TITLE + '</div>',
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

front = [
] + nav + [
    '',
    '<div style="flex:1 1 auto; min-width:0; background:#ffffff; color:#24292f;'
    ' padding:0 24px;">',
    '',
]

# tighten lists: the source keeps every bullet in its own list element, which
# would otherwise render with a blank line between items
merged = []
for ln in front + lines:
    if (ln.strip() == '' and merged and re.match(r'^\s*- ', merged[-1])):
        merged.append(ln)
        continue
    if (ln.strip() == '' and merged and merged[-1].strip() == ''):
        pass
    merged.append(ln)
tight = []
for i, ln in enumerate(merged):
    if ln.strip() == '' and tight and re.match(r'^(\s*)- ', tight[-1]):
        nxt = next((m for m in merged[i + 1:] if m.strip() != ''), '')
        if re.match(r'^(\s*)- ', nxt):
            continue
    tight.append(ln)

# collapse runs of blank lines
out, blank = [], False
for ln in tight:
    if ln.strip() == '':
        if blank:
            continue
        blank = True
    else:
        blank = False
    out.append(ln)

out += ['', '</div>', '', '</div>']

open(OUT, 'w', encoding='utf-8').write('\n'.join(out).rstrip() + '\n')
print(f'{OUT}: {len(out)} lines, {len(headings)} headings, {table_index} tables')
