<%page args="item, css_class=''" />
<%namespace name="resiz" file="/shortcodes/resize_image.mc" />
<%! from wmk_theme_autoload import get_main_img, get_summary %>
<%
if not item:
    return ''
orig_img = get_main_img(item)
if orig_img.startswith('mynd/'):
    orig_img = '/' + orig_img
img = capture(lambda: resiz.body(orig_img, width=800, height=800, webroot=item['data']['WEBROOT'], self_url=item['url']))
url = item['url']
pg = item['data']['page']
%>
<div class="${ css_class } round-teaser">
  <a href="${url}">
    <img src="${ img }"?o=${ orig_img |u }" loading="lazy" alt="${pg.title |h}" width="680" height="680" class="borad-round">
  </a>
  <div class="intro">
    <h3 class="mt-0"><a href="${url}" class="plain">${ pg.title }</a></h3>
    <p class="m-0">${ get_summary(item, 200) } <a href="${ url }">Meira&nbsp;»</a>
  </div>
</div>
