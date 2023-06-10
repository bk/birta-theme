<%page args="src, caption=None, img_width=512, img_height=None, rz_op='fit_width'" />
<%!
import os
import subprocess
import hashlib
from urllib.parse import quote_plus
%>\
<%doc>
Display a PDF as an image pointing to the original
</%doc>
<%namespace name="resiz" file="resize_image.mc" />
<%namespace name="figure" file="figure.mc" />
<%
orig_src = src
webroot = context.get('WEBROOT')
if not webroot:
    raise Exception('WEBROOT unknown')
if not src.startswith('/'):
    src = os.path.normpath(os.path.join(os.path.dirname(SELF_URL), src))
full_src = os.path.join(webroot, src.strip('/'))
if not os.path.exists(full_src):
    raise Exception(f'Could not find {full_src}')
imgfile = hashlib.sha1(full_src.encode('utf-8')).hexdigest() + '.pdf.png'
imgfile = os.path.join('resized_images', imgfile)
full_imgfile = os.path.join(webroot, imgfile)
rz_path = os.path.join(webroot, 'resized_images')
if not os.path.exists(rz_path):
    os.mkdirs(rz_path)
if not os.path.exists(full_imgfile):
    status = subprocess.call([
            '/usr/bin/convert',
            '-density', '200',
            '-background', 'white',
            '-flatten',
            full_src + '[0]',
            '-strip',
            '-quality', '80',
            '-trim', '+repage',
            full_imgfile])
    if status != 0:
        raise Exception(
            'Converting PDF to PNG failed with status code %d' % status)
resize_opt = {'path': '/'+imgfile, 'width': img_width, 'height': img_height, 'op': rz_op}
resize_kwargs = context.kwargs
resize_kwargs.update(resize_opt)
thumb = capture(lambda: resiz.body(**resize_kwargs))
%>
% if caption:
  ${ figure.body(thumb, caption=caption, width=img_width, height=img_height, alt=orig_src, resize=False, css_class="pdf-img", img_link=orig_src) }
% else:
  <a href="${ orig_src }"><img src="${ thumb }" loading="lazy" alt="${ orig_src |h }" class="pdf-img"></a>
% endif
