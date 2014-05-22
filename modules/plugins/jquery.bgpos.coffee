###
  @author Alexander Farkas
  v. 1.21
###
(($) ->
  # IE6-IE8
  toArray = (strg) ->
    strg = strg.replace(/left|top/g, '0px')
    strg = strg.replace(/right|bottom/g, '100%')
    strg = strg.replace(/([0-9\.]+)(\s|\)|$)/g, '$1px$2')
    res = strg.match(/(-?[0-9\.]+)(px|\%|em|pt)\s(-?[0-9\.]+)(px|\%|em|pt)/)
    [
      parseFloat(res[1], 10)
      res[2]
      parseFloat(res[3], 10)
      res[4]
    ]
  if not document.defaultView or not document.defaultView.getComputedStyle
    oldCurCSS = jQuery.curCSS
    jQuery.curCSS = (elem, name, force) ->
      name = 'backgroundPosition'  if name is 'background-position'
      return oldCurCSS.apply(this, arguments_)  if name isnt 'backgroundPosition' or not elem.currentStyle or elem.currentStyle[name]
      style = elem.style
      return style[name]  if not force and style and style[name]
      oldCurCSS(elem, 'backgroundPositionX', force) + ' ' + oldCurCSS(elem, 'backgroundPositionY', force)
  oldAnim = $.fn.animate
  $.fn.animate = (prop) ->
    if 'background-position' of prop
      prop.backgroundPosition = prop['background-position']
      delete prop['background-position']
    prop.backgroundPosition = '(' + prop.backgroundPosition  if 'backgroundPosition' of prop
    oldAnim.apply this, arguments_

  $.fx.step.backgroundPosition = (fx) ->
    unless fx.bgPosReady
      start = $.curCSS(fx.elem, 'backgroundPosition')
      #FF2 no inline-style fallback
      start = '0px 0px'  unless start
      start = toArray(start)
      fx.start = [
        start[0]
        start[2]
      ]
      end = toArray(fx.options.curAnim.backgroundPosition)
      fx.end = [
        end[0]
        end[2]
      ]
      fx.unit = [
        end[1]
        end[3]
      ]
      fx.bgPosReady = true

    #return;
    nowPosX = []
    nowPosX[0] = ((fx.end[0] - fx.start[0]) * fx.pos) + fx.start[0] + fx.unit[0]
    nowPosX[1] = ((fx.end[1] - fx.start[1]) * fx.pos) + fx.start[1] + fx.unit[1]
    fx.elem.style.backgroundPosition = nowPosX[0] + ' ' + nowPosX[1]
    return

  return
) jQuery
