###
 # $.preload() function for jQuery
 # Preload images, CSS and JavaScript files without executing them
 # Script by Stoyan Stefanov - http://www.phpied.com/preload-cssjavascript-without-execution/
 # Slightly rewritten by Mathias Bynens - http://mathiasbynens.be/
 # Demo: http://mathiasbynens.be/demo/javascript-preload
 # Note that since @ script relies on jQuery, the preloading process will not start until jQuery has finished loading.
###
(($) ->
  $.fn.preload = (arr) ->
    i = arr.length
    while i--
      if $.browser.msie
        new Image().src = arr[i]
        continue

      o = document.createElement('object')
      o.data = arr[i]
      o.width = o.height = 0
      o.style.position = 'absolute'
      document.getElementById('preloads').appendChild(o)
) jQuery