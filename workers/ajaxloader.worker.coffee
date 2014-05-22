# Take care of vendor prefixes.
self.postMessage = self.webkitPostMessage or self.postMessage

addEventListener 'message', (event) ->
  xhr = new XMLHttpRequest()
  xhr.open 'GET', event.data, false
  xhr.send()
  postMessage
    responseText: xhr.responseText
    readyState: xhr.readyState
    status: xhr.status
    url: event.data
  return
, false
