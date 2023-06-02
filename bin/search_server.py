#!/usr/bin/env python3

import json
import sys
import sqlite3
from bottle import (run, request, response, post, abort)

config = {}


@post('/_/<sitekey:re:\w+>/search/')
def search(sitekey):
    conf = config.get(sitekey)
    response.set_header('Access-Control-Allow-Origin', '*')
    if not conf:
        abort(404, f'Unknown sitekey {sitekey}')
    query = dict(request.forms).get('query')
    if not query:
        print("GOT ONLY", dict(request.forms))
        abort(403, 'Query needed')
    db = sqlite3.connect(conf['db'])
    db.row_factory = sqlite3.Row
    ret = run_query(db, query,
                    conf.get('limit', 1000),
                    conf.get('required_fields', []))
    response.content_type = 'application/json'
    return json.dumps(ret)


def run_query(db, query, limit, required_fields):
    cur = db.cursor()
    res = cur.execute(
        f"""
        select e.url, e.date, e.title, e.tags, e.image, e.summary
        from entry e join entry_fts using (url) where entry_fts match ?
        order by bm25(entry_fts)
        """, (query, ))
    ret = []
    for it in res.fetchall():
        ok = True
        for field in required_fields:
            if not it[field]:
                ok = False
        if ok is False:
            continue
        ret.append(dict(it))
    if limit and len(ret) > limit:
        ret = ret[:limit]
    return ret






if __name__ == '__main__':
    if not len(sys.argv) == 2:
        print("Usage: search_server.py configuration_file.json")
        sys.exit(1)
    config = json.load(open(sys.argv[1]))
    host = config.get('host', 'localhost')
    port = config.get('port', 7088)
    debug = config.get('debug', True)
    run(host=host, port=port, debug=debug)
