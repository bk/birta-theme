<%page args="tagname, css_class='', exclude=None, chain_exclude=False, by_date=False" />
<%namespace name="resiz" file="/shortcodes/resize_image.mc" />
<%!
import random
from wmk_theme_autoload import get_main_img
from wmk import slugify
%>
<%
tagged = MDCONTENT.has_tag(tagname)
if not tagged:
    return ''
if tagged:
    if exclude:
        tagged = tagged.page_match(exclude, inverse=True)
    if by_date:
        tagged = tagged.sorted_by_date()[:5]
    else:
        random.shuffle(tagged)
        tagged = tagged[:5]
    # Help to prevent duplicates in subsequent calls to tag_teaser
    if chain_exclude and exclude and 'id' in exclude and isinstance(exclude['id'], list):
        for it in tagged[:4]:
            exclude['id'].append(it['data']['page'].id)
if not len(tagged) == 5:
    return ''
tag_page = MDCONTENT.page_match({'slug': '^'+slugify(tagname)+'$'})
img = None
orig_img = None
if tag_page:
    tag_page = tag_page[0]
    orig_img = get_main_img(tag_page, fallback=False)
    if orig_img:
        img = capture(lambda: resiz.body(
            orig_img, width=800, height=800,
            webroot=tag_page['data']['WEBROOT'],
            self_url=tag_page['url']))
if not img:
    orig_img = get_main_img(tagged[4])
    if orig_img.startswith('mynd/'):
        orig_img = '/' + orig_img
    img = capture(lambda: resiz.body(
            orig_img, width=800, height=800,
            webroot=tagged[4]['data']['WEBROOT'],
            self_url=tagged[4]['url']))
tag_url = tag_page['url'] if tag_page else '/flokkar/' + slugify(tagname) + '/'
%>
<div class="round-teaser tag-teaser ${ css_class }">
  <a href="${tag_url}">
    <span>${ tagname }<br><span class="smaller">Skoða flokkinn</span></span>
    <img src="${ img }"?o=${ orig_img |u }" loading="lazy" alt="${ tagname |h}" width="680" height="680" class="borad-round">
  </a>
  <div class="intro">
    <h4 class="section mt-0 mb-1">Sýnishorn</h4>
    <div class="grid-xs c2 c3-md c4-lg">
      % for i, it in enumerate(tagged[:4]):
        ${ _miniteaser(it, i) }
      % endfor
    </div>
  </div>
</div>

<%def name="_miniteaser(it, i)">
<%
url = it['url']
title = it['data']['page']['title']
orig_img = get_main_img(it)
if orig_img.startswith('mynd/'):
    orig_img = '/' + orig_img
img = capture(lambda: resiz.body(orig_img, width=320, height=320, webroot=it['data']['WEBROOT'], self_url=url))
cls = [
    '',
    '',
    ' seen-011 hidden-sm',
    ' seen-001', ]
%>
  <div class="miniteaser${ cls[i] }">
    <a href="${ url }"><img src="${img}?o=${ orig_img |u }" alt="${ title |h }" loading="lazy" class="borad"></a>
    <p><a href="${ url }" class="text plain">${ title }</a></p>
  </div>
</%def>
