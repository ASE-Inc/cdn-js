# requestAnimationFrame polyfill by Erik Möller
# fixes from Paul Irish and Tino Zijdel
(->
  lastTime = 0
  vendors = ["ms", "moz", "webkit", "o"]
  unless window.requestAnimationFrame
    x = 0
    while x < vendors.length and not window.requestAnimationFrame
      window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"]
      window.cancelAnimationFrame = window[vendors[x] + "CancelAnimationFrame"] or window[vendors[x] + "CancelRequestAnimationFrame"]
      ++x
  unless window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element) ->
      currTime = new Date().getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout(->
        callback currTime + timeToCall
      , timeToCall)
      lastTime = currTime + timeToCall
      id
  unless window.cancelAnimationFrame
    window.cancelAnimationFrame = (id) ->
      clearTimeout id
)()