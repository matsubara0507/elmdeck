var _matsubara0507$elmdeck$Native_Katex = function() {
  function toKatex(code)
  {
    if (typeof katex !== 'undefined')
    {
      try {
        return katex.renderToString(code);
      } catch (e) {
        return code
      }
    }
    return code;
  }

  return {
    toKatex: toKatex
  }
}();
