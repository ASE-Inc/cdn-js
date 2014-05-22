
# Take care of vendor prefixes.
self.postMessage = self.webkitPostMessage or self.postMessage

getData = (data) ->
  postMessage
    json: data
    url: Event_data

  throw JSON.stringify(data: data)
  close()
  return

Event_data = undefined

addEventListener 'message', (event) ->
  Event_data = event.data
  Event_data = Event_data.replace('&callback=?', '', 'g')  if Event_data.indexOf('&callback=?') > -1
  if Event_data.indexOf('?') > -1
    Event_data += '&callback='
  else
    Event_data += '?callback='
  Event_data += 'getData&'
  Event_data += encodeURIComponent(event.data.query or '')
  Event_data += '&_=' + new Date().getTime().toString() # prevent caching
  importScripts Event_data
  return
, false
