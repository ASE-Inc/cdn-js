### Thanks: http://timothypoon.com/blog/2011/01/19/html5-canvas-particle-animation/ ###
NO_OF_PROPERTIES = 6
rint = 60

class Particle

  constructor: ->
    @s =
      ttl: 800
      xmax: 2
      ymax: 1
      rmax: 10
      rt: 1
      xdef: 320
      ydef: 120
      xdrift: 4
      ydrift: 4
      random: true
      blink: true
    @reset()
    return

  reset: ->
    @x = if @s.random then width*Math.random() else @s.xdef
    @y = if @s.random then height*Math.random() else @s.ydef
    @r = ((@s.rmax-1)*Math.random()) + 1
    @dx = (Math.random()*@s.xmax)*(if Math.random()<.5 then -1 else 1)
    @dy = (Math.random()*@s.ymax)*(if Math.random()<.5 then -1 else 1)
    @hl = (@s.ttl/rint)*(@r/@s.rmax)
    @rt = Math.random()*@hl
    @s.rt = Math.random()+1
    @stop = Math.random()*.2+.4
    @s.xdrift *= Math.random() * (if Math.random()<.5 then -1 else 1)
    @s.ydrift *= Math.random() * (if Math.random()<.5 then -1 else 1)
    return

  fade: -> @rt += @s.rt; return

  move: ->
    @x += (@rt/@hl)*@dx
    @y += (@rt/@hl)*@dy
    @dx *= -1 if @x>width or @x<0
    @dy *= -1 if @y>height or @y<0
    return

  draw: ->
    if @s.blink and (@rt <= 0 or @rt >= @hl)
      @s.rt *= -1
    else if @rt >= @hl
      @reset()
    @newo = 1-(@rt/@hl)
    @cr = @r*@newo
    @cr = if @cr <= 0 then 1 else @cr
    return

  update: ->
    @fade()
    @move()
    @draw()
    return

  getDataArray: ->
    return [@x, @y, @r, @stop, @newo, @cr]
