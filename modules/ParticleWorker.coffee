### Author: Abhishek Munie ###

#include polyfills/requestAnimationFrame.coffee

if Modernizr.canvas
  class ParticleWorker
    constructor:  (@width=1600, @height=900) ->
      @worker = new Worker("/js/workers/workerloader.worker.js")
      @particleFrames = new Array()
      @worker.postMessage = @webkitPostMessage or @worker.postMessage
      @worker.addEventListener "message", (event) =>
        @particleFrames.unshift(if event.data.buffer then event.data else new Float32Array(event.data))
        # canvas.particleWorker.postMessage action: "pause"  if canvas.particles.length > 1500
        @particleFrames.splice 1500  if @particleFrames.length > 5999
      , false
      @worker.addEventListener "error", (event) =>
        console.error "Particle Worker Error: "
        console.error event
      , false
      @worker.postMessage '/workers/particle.worker.transferable.js'
      # Browser Worker Transferable Object Support Check
      transferableSupported = undefined
      ab = new Uint8Array(1).buffer
      try
        @worker.postMessage ab
        @worker.postMessage ab, [ab]
      transferableSupported = not ab.byteLength
      @worker.postMessage
        action: "update"
        property: "useTransferable"
        value: transferableSupported

    initialize: -> @worker.postMessage action: "initialize"

    setWidth: (width) ->
      unless width is @width
        @worker.postMessage
          action: "update"
          property: "width"
          value: width
        @particleFrames.splice 120
        @width = width
    setHeight: (height) ->
      unless height is @height
        @worker.postMessage
          action: "update"
          property: "height"
          value: height
        @particleFrames.splice 120
        @height = height

    updateSize: (width, height) ->
      @setWidth width
      @setHeight height

    importParticleScript: (particleScript) ->
      @worker.postMessage
        action: "importParticleScript"
        script: particleScript

    updateRint: (rint) ->
      @worker.postMessage
        action: "update"
        property: "rint"
        value: rint

    updateNoOfParticles: (@noOfParticles) ->
      @worker.postMessage
        action: "update"
        property: "noOfParticles"
        value: noOfParticles

    updateBatchSize: (batchSize) ->
      @worker.postMessage
        action: "update"
        property: "batchSize"
        value: batchSize

  (->
    $.fn.paintParticles = (o) ->
      o = $.extend(
        speed: 300
        noOfParticles: 60
        batchSize: 1000
        rint: 60
        id: undefined
        className: "particle_canvas"
        particleScript: undefined
        mouseMoveHandler: undefined
        drawParticles: undefined
        relativeto: undefined
        autofit: true
        fallInitialy: true
      , o)
      @each ->
        canvas = undefined
        $canvas = undefined
        if @tagName is "CANVAS"
          canvas = @
          $canvas = $(canvas)
          canvas.relativeto = $canvas.parent()  unless o.relativeto
        else
          canvas = jQuery("<canvas #{if o.id then "id=\"#{o.id}\" " else ""}class=\"#{o.className}\">").insertAfter(@)[0]
          $canvas = $(canvas)
          canvas.relativeto = $(@)  unless o.relativeto
        canvas.relativeto = $(o.relativeto)  if o.relativeto
        canvas.drawParticles = o.drawParticles
        canvas.noOfParticles = o.noOfParticles
        canvas.particleWorker = new ParticleWorker()
        canvas.particleFrames = canvas.particleWorker.particleFrames

        WIDTH = $canvas.width()
        HEIGHT = $canvas.height()
        canvas.update = ->
          WIDTH = $canvas.width()
          HEIGHT = $canvas.height()
          $canvas.attr "width", WIDTH
          $canvas.attr "height", HEIGHT
          canvas.particleWorker.updateSize WIDTH, HEIGHT
        canvas.initFall = ->
          WIDTH = $canvas.width()
          HEIGHT = $canvas.height()
          $canvas.attr "width", WIDTH
          $canvas.attr "height", HEIGHT
          canvas.particleWorker.updateSize WIDTH, 0

        canvas.particleWorker.importParticleScript o.particleScript
        canvas.particleWorker.updateRint o.rint
        canvas.particleWorker.updateNoOfParticles o.noOfParticles
        canvas.particleWorker.updateBatchSize o.batchSize
        if o.fallInitialy
          canvas.initFall()
          window.setTimeout ->
            canvas.update()
          , 100
        else
          canvas.update()
        canvas.particleWorker.initialize()

        window.addEventListener "resize", ->
          canvas.update()
        , false if(o.autofit)

        context = canvas.getContext("2d")
        popped = undefined
        draw = ->
          context.clearRect 0, 0, WIDTH, HEIGHT
          canvas.drawParticles popped, context  if (popped = canvas.particleFrames.pop())

          canvas.particleWorker.worker.postMessage action: "resume"  if canvas.particleFrames.length is 60

          canvas.draw_interval_id = window.requestAnimationFrame(draw)

        canvas.draw_interval_id = window.requestAnimationFrame(draw)
        document.addEventListener "visibilitychange", ->
          if document["hidden"]
            window.cancelAnimationFrame canvas.draw_interval_id
          else
            window.cancelAnimationFrame canvas.draw_interval_id
            canvas.draw_interval_id = window.requestAnimationFrame(draw)
        , false

        # Event Handlers
        canvas.onmousemove = o.mouseMoveHandler  if o.mouseMoveHandler
        $(document).on "mySite:ajaxcompleted", ->
          unless document.body.contains(canvas)
            window.cancelAnimationFrame canvas.draw_interval_id
            mySite.wipeObject canvas

    $.fn.paintTwinklingStars = (o) ->
      @paintParticles $.extend(
        particleScript: 'http://localhost:8080/mySite-js/build/workers/twinkler.js'
        drawParticles: (frame, context) ->
          x = undefined
          y = undefined
          r = undefined
          newo = undefined
          twoπ = Math.PI * 2
          len = undefined
          pLen = undefined
          len = frame.length / 6
          while len
            pLen = --len * 6
            x = frame[pLen]
            y = frame[pLen + 1]
            r = frame[pLen + 2]
            newo = frame[pLen + 4]
            context.beginPath()
            context.arc x, y, r, 0, twoπ, true
            context.closePath()
            g = context.createRadialGradient(x, y, 0, x, y, frame[pLen + 5])
            g.addColorStop 0.0, "rgba(255,255,255,#{newo})"
            g.addColorStop frame[pLen + 3], "rgba(77,101,181,#{(newo * .6)})"
            g.addColorStop 1.0, "rgba(77,101,181,0)"
            context.fillStyle = g
            context.fill()
          undefined
      , o)

    $.fn.paintMSSnowFlakes = (o) ->
      @paintParticles $.extend
        particleScript: "ms.snowflakes.js",
        drawParticles: (frame, context) =>
          len = frame.length / 6
          while len
            pLen = --len * 6
            context.globalAlpha = frame[pLen]
            context.drawImage(
              snowflakeSprites[frame[pLen + 1]], # image
              0, # source x
              0, # source y
              o.spriteWidth, # source width
              o.spriteHeight, # source height
              frame[pLen + 2], # target x
              frame[pLen + 3], # target y
              frame[pLen + 4], # target width
              frame[pLen + 5] # target height
            )
      , o

  ) jQuery
