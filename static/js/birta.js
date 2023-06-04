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


// Causes html elements in the 'relativedate' class to be displayed
// as relative dates. The date is parsed from the title attribute, or from
// the element content.

(function(){
  function getDates() {
    let dateElements = document.querySelectorAll('.relativedate');
    for (let i = 0; i < dateElements.length; i++) {
      let elt = dateElements[i];
      let title = elt.attributes.datetime;
      let d = new Date(title ? title.value : elt.innerHTML);
      if (! isNaN(d)) {
        dateElements[i].date=d;
        elt.title=elt.innerHTML;
      }
    }
    showDates(dateElements);
  }

  function showDates(dateElements) {
    for (var i = 0; i < dateElements.length; i++) {
      var elt = dateElements[i];
      var d = elt.date;
      if (! isNaN(d)) {
        elt.innerHTML=relativeDate(d);
      }
    }
    setTimeout(function(){showDates(dateElements)},30000); // keep updating every 30s
  }

  var timeUnits = [
    // þgf.et, þgf.ft, þf.et, þf.ft
    { unit: ['ári', 'árum', 'ár', 'ár'],		seconds: 60 * 60 * 24 * 364 },
    { unit: ['mánuði', 'mánuðum', 'mánuð', 'mánuði'],	seconds: 60 * 60 * 24 * 30 },
    { unit: ['degi', 'dögum', 'dag', 'daga'],		seconds: 60 * 60 * 24 },
    { unit: ['klst.', 'klst.', 'klst.', 'klst.'],		seconds: 60 * 60 },
    { unit: ['mínútu', 'mínútum', 'mínútu', 'mínútur'],	seconds: 60 }
  ];

  function relativeDate(date) {
    var now = new Date();
    var offset = date.getTime() - now.getTime();
    var seconds = Math.round(Math.abs(offset) / 1000);

    // hack to avoid reading just in the future if there is a minor
    // amount of clock slip
    if (offset >= 0 && seconds < 30 * 60 * 60) {
      return "rétt í þessu";
    }

    var ret = "";
    var shown = 0;
    var tu_ix = 0;
    for (i = 0; i < timeUnits.length; i++) {
      if (seconds >= timeUnits[i].seconds) {
        var num = Math.floor(seconds / timeUnits[i].seconds);
        seconds -= num * timeUnits[i].seconds;
        if (ret)
          ret += "og ";
        // ret += num + " " + timeUnits[i].unit + (num > 1 ? "s" : "") + " ";
        tu_ix = (num == 1 || (num % 10 == 1 && num != 11)) ? 0 : 1;
        if (offset >= 0) tu_ix += 2;
        ret += num + " " + timeUnits[i].unit[tu_ix] + " ";

        if (++shown == 2)
          break;
      }
      else if (shown)
        break;
    }

    if (! ret)
      return "rétt áðan";

    var prefix = offset < 0 ? 'fyrir ' : 'eftir ';
    return prefix + ret;
  }
  getDates();
})();
