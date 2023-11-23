<%page args="src, align='center', size='650x', alt='', caption=None, sticky_width=True, rz_op='fit', img_link=None, link_target='_blank', rz_focus=None" />
<%!
import os
from urllib.parse import quote_plus
%>\
<%doc>
Shortcode to handle translated IkiWiki-style [[!img...]] directives.
</%doc>
<%namespace name="resiz" file="resize_image.mc" />
<%namespace name="figure" file="figure.mc" />
<%
sticky_widths = (
    {'from': 500, 'to': 1279, 'scale_to': 1024},
    {'from': 150, 'to': 300, 'scale_to': 300},
    {'from': 301, 'to': 512, 'scale_to': 512},
)
orig_src = src
if src.startswith('mynd/'):
    src = '/' + src
if size and 'x' in size:
    width, height = size.split('x')
    width = int(width) if width else None
    height = int(height) if height else None
    if width and not height and sticky_width:
        for it in sticky_widths:
            if it['from'] <= width <= it['to']:
                width = it['scale_to']
    if not height:
        rz_op = 'fit_width'
    if not width:
        rz_op = 'fit_height'
    if width and height and width == height:
        rz_op = 'fill'
if not src.startswith(('/', 'http:', 'https:')):
    src = os.path.normpath(os.path.join(os.path.dirname(SELF_URL), src))
if width or height:
    resize_opt = {'path': src, 'width': width, 'height': height, 'op': rz_op, 'focal_point': rz_focus}
    resize_kwargs = context.kwargs
    resize_kwargs.update(resize_opt)
    src = capture(lambda: resiz.body(**resize_kwargs))
    src += '?o=' + quote_plus(orig_src)
if width and width >= 600:
    align = 'center' # force center if image is to wide for floating
css_class = 'imgalign-%s' % (align or 'none')
if img_link and img_link.lower() in ("1", "true", "yes", "on"):
    img_link = orig_src
if img_link and img_link.startswith(('mynd/', 'file/')):
    img_link = '/' + img_link
%>
% if caption:
  ${ figure.body(src, caption=caption, width=width, height=height, alt=alt,
                 resize=False, css_class=css_class, img_link=img_link, link_target=link_target) }
% elif img_link:
  <a href="${ img_link }"${ f' target="{link_target}"' if link_target else '' }><img src="${ src }" loading="lazy" alt="${ alt or '' |h }" ${ 'width="%d"' % width if width else '' } ${ 'height="%d"' % height if height else '' } class="${ css_class }"></a>

% else:
  <img src="${ src }" loading="lazy" alt="${ alt or '' |h }" ${ 'width="%d"' % width if width else '' } ${ 'height="%d"' % height if height else '' } class="${ css_class }">
% endif
