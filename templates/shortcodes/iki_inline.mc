<%page args="pages=None, template=None, sort='title', feeds=False, show=100, **kwargs" />\
<%! import re %>\
<%doc>
Allar_síður.mdwn:[[!inline template="tagsummary" pages="tagged(*)" sort="title" feeds="no" show="1000"]]
index.mdwn:[[!inline template="summary" pages="Vettlingurinn" show="1" sort="age" feeds="no"]]
index.mdwn:[[!inline template="summary" pages="tagged(*) and !tagged(Smásíður)" show="11" sort="age" feeds="no"]]
tag/Allar_síður.mdwn:[[!inline pages="tagged(Allar_síður)" actions="no" archive="yes"
tag/Hreyfing_og_jóga.mdwn:[[!inline template="tagsummary" pages="tagged(Hreyfing_og_jóga)" sort="title" feeds="no" show="1000"]]
tag/Leikur_og_leikrit.mdwn:[[!inline template="tagsummary" pages="tagged(Leikur_og_leikrit)" sort="title" feeds="no" show="1000"]]
tag/Myndlist.mdwn:[[!inline template="tagsummary" pages="tagged(Myndlist)" sort="title" feeds="no" show="1000"]]
tag/Smáhugmyndir.mdwn:[[!inline template="tagsummary" pages="tagged(Smáhugmyndir)" sort="title" feeds="no" show="1000"]]
tag/Smásíður.mdwn:[[!inline template="tagsummary" pages="tagged(Smásíður)" sort="title" feeds="no" show="1000"]]
tag/Stefbækur.mdwn:[[!inline template="tagsummary" pages="tagged(Stefbækur)" sort="title" feeds="no" show="1000"]]
tag/Söngur_og_tónlist.mdwn:[[!inline template="tagsummary" pages="tagged(Söngur_og_tónlist)" sort="title" feeds="no" show="1000"]]
tag/Viðbótarefni.mdwn:[[!inline template="tagsummary" pages="tagged(Viðbótarefni)" sort="title" feeds="no" show="1000"]]
tag/Ævintýri_og_þjóðsögur.mdwn:[[!inline template="tagsummary" pages="tagged(Ævintýri_og_þjóðsögur)" sort="title" feeds="no" show="1000"]]
</%doc>\
<%namespace name="pagelist" file="pagelist.mc" />\
<%
if ' and ' in pages:
    pages = re.sub(r' and .*', '', pages)
    print(f"WARNING [iki_inline]: removing 'and' clause from pages='{pages}'")
pages = pages.replace('*', '.*')
if 'tagged' in pages:
    tagfound = re.search(r'tagged\((.*?)\)', pages)
    if tagfound:
        tagname = tagfound.group(1)
        match = {'has_tag': True if tagname == '*' else tagname}
    else:
        match = {'has_tag': True}
else:
    match = {'url': pages}
if template:
    # supported: summary, tagsummary
    template = '/lib/' + template + '.mc'
if sort == 'age':
    sort = '-date'
elif sort and sort not in ('date', 'title'):
    sort = 'title'
%>\
${ pagelist.body(match, template=template, ordering=sort, limit=int(show), **kwargs) }
