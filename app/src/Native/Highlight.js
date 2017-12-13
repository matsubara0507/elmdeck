var _matsubara0507$elmdeck$Native_Highlight = function() {
  function toHighlight(lang, code)
  {
    if (typeof hljs !== 'undefined' && lang && hljs.listLanguages().indexOf(lang) >= 0)
    {
      return hljs.highlight(lang, code, true).value;
    }
    return code;
  }

  return {
    toHighlight: F2(toHighlight)
  }
}();
