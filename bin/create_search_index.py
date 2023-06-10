#!/usr/bin/env python3

import sqlite3
import json
import os
import re
from PIL import Image, ImageOps
from hashlib import sha1
from urllib.parse import quote_plus


def main():
    with open("data/mdcontent.json") as f:
        content = json.loads(f.read())
    if not os.path.exists('tmp'):
        os.mkdir('tmp')
    db_path = os.path.join('tmp', 'search.db')
    if os.path.exists(db_path):
        os.unlink(db_path)
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    init_db(cur)
    create_search_index(cur, content)
    conn.commit()
    conn.close()
    dest_db_path = os.path.join('htdocs', 'search.db')
    if os.path.exists(dest_db_path):
        os.unlink(dest_db_path)
    os.rename(db_path, dest_db_path)


def init_db(cur):
    cur.execute("""
        create table entry (
          url   text primary key not null,
          date  datetime,
          title text not null,
          slug  text not null,
          tags text,
          image text,
          summary text not null,
          body text not null
        ); """)
    cur.execute("""
        create virtual table entry_fts using fts5 (
          url,
          tags,
          title,
          body,
          tokenize="trigram"
        ); """)

def create_search_index (cur, content):
    seen = set()
    ins = []
    for it in content:
        data = it['data']
        page = data.get('page')
        if data.get('is_draft') or data.get('draft') or page.get('do_not_render'):
            contiue
        url = it['data']['SELF_URL']
        if url in seen:
            print(f"WARNING: URL {url} seen again - skipped!")
            continue
        title = page['title']
        slug = page['slug']
        image = page.get('main_image') or get_image(it['doc'])
        image = scale_image(image, url)
        if image and not image.startswith('/'):
            image = os.path.join(os.path.split(url)[0], image)
        body = clean_html(it['rendered'])
        summary = page.get('summary') or get_summary(body)
        date = page.get('date') or page.get('created_date')
        tags = get_tags(page)
        url = re.sub(r'/index.html$', '/', url)
        ins.append((url, date, title, slug, tags, image, summary, body))
    if ins:
        cur.executemany(
            """insert into entry (url, date, title, slug, tags, image, summary, body)
               values (?, ?, ?, ?, ?, ?, ?, ?);""", ins)
        cur.execute(
            """
            insert into entry_fts (url, title, tags, body)
            select url, title, tags, body from entry;
            """
        )


def get_tags(page):
    tags = []
    if 'tag' in page:
        tags.append(page['tag'])
    if 'tags' in page and isinstance(page['tags'], str):
        tags.append(page['tags'])
    elif 'tags' in page:
        tags += page['tags']
    if tags:
        return '; '.join(tags)
    return None


def get_image(doc):
    # Very specific to Ikiwiki-ported content
    found = re.search(r'\[\[!img +(\S+)', doc)
    if found:
        return found.group(1).strip('"')
    return None


def scale_image(img, url):
    if not img:
        return None
    orig_img = img
    if not '/' in img:
        img = os.path.join(os.path.dirname(url), img)
    src = os.path.join('htdocs', img.strip('/'))
    if not os.path.exists(src):
        return None
    width = 512
    height = 320
    op = 'fill'
    path = '/' + img.strip('/')  # for consistency with rezize_image shortcode
    hash = sha1('::'.join(
        [path, str(width), str(height), op, 'jpg', '0.8']).encode('utf-8')).hexdigest()
    targetdir = 'htdocs/resized_images/512x320'
    if not os.path.exists(targetdir):
        os.makedirs(targetdir)
    target_url = f'/resized_images/512x320/{hash}.jpg?o=' + quote_plus(orig_img)
    target_path = os.path.join(targetdir, (hash + '.jpg'))
    if not os.path.exists(target_path):
        im = Image.open(src)
        im2 = ImageOps.fit(im, (width, height))
        if im2.mode != 'RGB':
            im2 = im2.convert('RGB')
        pil_opt = {'quality': 80}
        im2.save(target_path, 'JPEG', **pil_opt)
    return target_url


def clean_html(s):
    s = re.sub(r'<[^>]+>', ' ', s)
    s = re.sub(r'\s+', ' ', s)
    return s.strip()


def get_summary(s):
    if len(s) > 160:
        s = s[:160]
        s = re.sub(r' \S+$', '', s)
        s = s.strip()
        s += '…'
    return s


if __name__ == '__main__':
    main()
