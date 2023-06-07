#!/usr/bin/env python3

import re
import datetime
from wmk_utils import slugify


def ikiwiki2shortcode(doc, pg):
    """
    Translates selected IkiWiki directives to shortcode calls.
    Also translates internal wiki links '[[...]]' to linkto() shortcode.
    """
    if not '[[!' in doc:
        return ikiwiki_links(doc)
    known_directives = {
        'img': img_directive,
        'tag': tag_directive,
        'meta': meta_directive,
        'map': map_directive,
        'inline': inline_directive,
        'pdf': pdf_directive,
    }
    for k in known_directives:
        if '[[!'+k in doc:
            doc = known_directives[k](doc, pg)
    doc = ikiwiki_links(doc)
    return strong_emph_fixup(doc)


def _simple_directive(name, doc, newname=None):
    if newname is None:
        newname = name
    chunks = doc.split('[[!' + name)
    ret = chunks[0]
    for chunk in chunks[1:]:
        args, rest = chunk.split(']]', 1)
        args = args.strip()
        # Assumes the directive is all on one line
        args = re.sub(r' (\w+=)(\w+)', r' \1"\2"', args)
        args = re.sub(r'"\s+', r'", ', args)
        args = re.sub(r'^([^\s"]+) ', r'"\1", ', args)
        # class is disallowed as an argument name
        args = args.replace(' class=', ' css_class=')
        ret += '{{< %s(%s) >}}' % (newname, args)
        ret += rest
    return ret


def img_directive(doc, pg):
    return _simple_directive('img', doc)


def pdf_directive(doc, pg):
    return _simple_directive('pdf', doc)


def tag_directive(doc, pg):
    if not 'tags' in pg:
        pg['tags'] = []
    tag_re = re.compile(r'\[\[!tag (.+?)\]\]')
    tagm = tag_re.search(doc)
    while tagm:
        tags = tagm.group(1).strip().split()
        pg['tags'] += tags
        doc = tag_re.sub('', doc, count=1)
        tagm = tag_re.search(doc)
    return doc


def meta_directive(doc, pg):
    # date, title, stylesheet
    #
    meta_re = re.compile(r'\[\[!meta (.+?)\]\]')
    metam = meta_re.search(doc)
    while metam:
        metapair = metam.group(1)
        if ' rel=' in metapair:
            metapair = re.sub(r'\s+rel=\S+', '', metapair)
        k, val = metapair.split("=")
        if val.startswith('"'):
            val = val.strip('"')
        if k == 'title':
            pg['title'] = val
        elif k == 'stylesheet':
            if not 'extra_css' in pg:
                pg['extra_css'] = []
            if not val.endswith('.css'):
                val += '.css'
            pg['extra_css'].append(val)
        elif k == 'date':
            try:
                dt = datetime.datetime.fromisoformat(val)
            except Exception as e:
                print("WARNING: Could not convert %s to datetime: %s" % (val, str(e)))
                dt = val
            pg['date'] = dt
        else:
            print("Unknown meta tag key: %s" % k)
        doc = meta_re.sub('', doc, count=1)
        metam = meta_re.search(doc)
    return doc


def map_directive(doc, pg):
    return _simple_directive('map', doc, 'iki_map')


def inline_directive(doc, pg):
    return _simple_directive('inline', doc, 'iki_inline')


def _iki2linkto(m):
    if len(m.groups()) == 3:
        pat = m.group(3)
        label = m.group(1) + m.group(2)
    else:
        pat = m.group(1) + m.group(2)
        label = pat
    if re.search(r'\.\w{2,5}$', pat):
        # ordinary link to a file with an extension
        if '/' in pat and not pat.startswith('/'):
            pat = '/' + pat
        return '<a href="%s" class="iki-conv">%s</a>' % (pat, label)
    else:
        # link to a named page
        return '{{< linkto("%s", label="%s") >}}' % (path_slugify(pat), label)


def path_slugify(pat):
    if not '/' in pat:
        return slugify(pat)
    parts = [slugify(_) for _ in pat.split('/')]
    return '/'.join(parts)


def ikiwiki_links(doc):
    # Normal form without '|'
    doc = re.sub(r'\[\[([^!])([^\]\|]+)\]\]', _iki2linkto, doc)
    # Form with '|'
    doc = re.sub(r'\[\[([^!])([^\]\|]+)\|(.*?)\]\]', _iki2linkto, doc)
    return doc


def strong_emph_fixup(doc):
    """
    Fix common breakage of intro paragraph (which usually has strong emphasis).
    """
    doc = re.sub(r'(\S) +\*\*\s*$', r'\1**', doc, flags=re.M)
    doc = re.sub(r'^\*\* +(\S)', r'**\1', doc, flags=re.M)
    return doc

def lyrics_section_detect(doc, pg):
    """
    A lyrics section consists of a heading, optional paragraph or two, a code
    block, and an optional number of non-heading paragraph following the code
    block.  We try to enclose such sections in <article>...</article>.
    """
    if '<article' in doc:
        return doc
    if not re.search(r'^    ', doc, flags=re.M):
        return doc
    doc = doc.replace(r'\r', '')
    paras = re.split(r'\n\n+', doc)
    cb_ix = []

    for i, p in enumerate(paras):
        if p.startswith('    '):
            cb_ix.append(i)
    # only keep first continguous code block
    cb_keep = []
    for c in cb_ix:
        if cb_keep and c != (cb_keep[-1] + 1):
            break
        cb_keep.append(c)
    cb_ix = cb_keep
    if not cb_ix or cb_ix[0] < 2:
        return doc
    cb_start = cb_ix[0]
    cb_end = cb_ix[-1]
    max_line_length = 0
    line_count = (cb_end - cb_start) * 2
    maybe_multicol = ''
    for p in paras[cb_start:cb_end+1]:
        lines = p.split("\n")
        for l in lines:
            if len(l) > max_line_length:
                max_line_length = len(l)
        line_count += len(lines)
    if max_line_length < 42 and line_count > 16:
        maybe_multicol = ' class="kolonner"'
    if paras[cb_start-1].startswith('#'):
        paras[cb_start-1] = f'<article markdown="1"{maybe_multicol}>\n\n' + paras[cb_start-1]
    elif paras[cb_start-2].startswith('#'):
        paras[cb_start-2] = f'<article markdown="1"{maybe_multicol}>\n\n' + paras[cb_start-2]
    elif cb_ix[0] > 3 and paras[cb_start-3].startswith('#'):
        paras[cb_start-3] = f'<article markdown="1"{maybe_multicol}>\n\n' + paras[cb_start-3]
    else:
        return doc
    pg.has_auto_lyrics_section = True
    if len(paras) == cb_end+1 or paras[cb_end+1].startswith('#'):
        paras[cb_end] += "\n\n</article>"
    else:
        placed = False
        for i in range(cb_end+1, len(paras)):
            if paras[i].startswith(('#', '<div', '<iframe')):
                paras[i] = "</article>\n\n" + paras[i]
                placed = True
                break
        if not placed:
            paras[-1] + "\n\n</article>\n"
    return "\n\n".join(paras)


autoload = {
    'ikiwiki2shortcode': ikiwiki2shortcode,
    'lyrics_section_detect': lyrics_section_detect,
}
