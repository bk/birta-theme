import re
from markdown.extensions import Extension
from markdown.postprocessors import Postprocessor


class EmphasizedInPre(Extension):
    """
    Allow strong and emphasized markup in <pre> tags, as long as each instance
    is kept within one line of text.
    """

    def extendMarkdown(self, md):
        md.registerExtension(self)
        # Insert a postprocessor as late as possible
        md.postprocessors.register(EmphasizedInPrePostprocess(self), 'footnote', 99)



class EmphasizedInPrePostprocess(Postprocessor):
    def run(self, text):
        def inside_codeblock(m):
            s = m.group(0)
            if not '*' in s:
                return s
            s = re.sub(r'\*\*([^*]*)\*\*', r'<strong>\1</strong>', s)
            return re.sub(r'\*([^*]*)\*', r'<em>\1</em>', s)
        if '<pre>' in text:
            text = re.sub(r'<pre>.*?</pre>', inside_codeblock, text, flags=re.S)
        return text
