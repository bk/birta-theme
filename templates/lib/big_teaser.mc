<%page args="item, css_class=''" />
<%namespace name="resiz" file="/shortcodes/resize_image.mc" />
<%! from wmk_theme_autoload import get_main_img, get_summary %>
<%
if not item:
    return ''
orig_img = get_main_img(item)
if orig_img.startswith('mynd/'):
    orig_img = '/' + orig_img
img = capture(lambda: resiz.body(orig_img, width=1020, height=680, webroot=item['data']['WEBROOT'], self_url=item['url']))
url = item['url']
pg = item['data']['page']
%>
<div class="${ css_class } big-teaser grid-sm c2 nogap">
  <a href="${ url | cleanurl }">
    <img src="${ img }"?o=${ orig_img |u }" loading="lazy" alt="${pg.title |h}" width="1020" height="680" class="d-block">
  </a>
  <div class="intro p-2">
    <h3 class="mt-0"><a href="${ url | cleanurl }" class="plain">${ pg.title }</a></h3>
    <p class="m-0">${ get_summary(item, 150) } <a href="${ url | cleanurl }">Meira&nbsp;»</a>
  </div>
</div>
