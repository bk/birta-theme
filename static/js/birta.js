/* Base javascript for the Birta wmk theme */

// We want at most one open dropdown menu at a time
document.addEventListener('click', function(e) {
  let open_dd = document.querySelector('details[role="dropdown"][open]');
  if (open_dd && !open_dd.contains(e.target)) {
    open_dd.removeAttribute('open');
  }
});

// Listen for shortcut keys.
document.addEventListener("keydown", function(e){
  let key = e.which || e.keyCode || window.event && window.event.keyCode;
  // Esc = close modal if it's open
  if (key == 27) {
    let open_modal = document.querySelector('.modal > [type=checkbox]:checked');
    if (open_modal) {
        open_modal.checked = false;
        return;
    }
  }
});

(function(){
    const plsum = document.querySelectorAll('.grid-sm article');
    plsum.forEach(function(el){
        const link = el.querySelector('h4 a')
        if (link) {
            el.addEventListener("click", function(ev){link.click()});
        }
    });
})();
