# ----------------------------------------------------------
# If you're not in IE (or IE version is less than 5) then:
#   ie is undefined
# If you're in IE (>5) then you can determine which version:
#   ie is 7 # IE7
# Thus, to detect IE:
#   if (ie) {}
# And to detect the version:
#   ie is 6 # IE6
#   ie > 7 # IE8, IE9 ...
#   ie < 9 # Anything less than IE9
# ----------------------------------------------------------
# http://paulirish.com/2011/requestanimationframe-for-smart-animating/
# http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
ieVersion = (->
  v = 3
  div = document.createElement('div')
  while (div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->') and div.getElementsByTagName('i')[0]
    undefined
  return if v > 4 then v else undefined
)()