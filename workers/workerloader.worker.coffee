# Take care of vendor prefixes.
self.postMessage = self.webkitPostMessage or self.postMessage

listner = (event) ->
  importScripts('{{ site.cdn.js }}'+event.data)
  removeEventListener 'message', listner, false
  return

addEventListener 'message', listner, false
