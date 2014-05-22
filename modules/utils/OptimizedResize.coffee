
#include ../polyfills/requestAnimationFrame.coffee

class OptimizedResize

  callbacks = []
  changed = false
  running = false

  # fired on resize event
  resize = ->
    unless running
      changed = true
      callbackLoop()
    return

  # resource conscious callback loop
  callbackLoop = ->
    unless changed
      running = false
    else
      changed = false
      running = true

      callbacks.forEach (callback) ->
        callback()
        return

      window.requestAnimationFrame callbackLoop
      return

  # adds callback to loop
  addCallback = (callback) ->
    callbacks.push callback if callback
    return

  # initalize resize event listener
  constructor: (callback) ->
    if window.requestAnimationFrame
      window.addEventListener 'resize', resize
      addCallback callback

  # public method to add additional callback
  add: (callback) ->
    addCallback callback
    return
