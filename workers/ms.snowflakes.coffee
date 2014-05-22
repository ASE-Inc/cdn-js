true
noOfProperties = 6
Snowflakes = (->
  
  # snowflakes objects collection
  
  # if true - we'll guess the best number of snowflakes for the system
  
  # we increment snowflakes with this rate
  
  # we can remove aggressively (to quicker free system resources), basically we remove at snowflakeCountIncrement*snowflakeRemoveFactor rate
  
  # snowflakes sprites
  
  # canvas bounds used for snowflake animation
  
  # postcard bounds to perform landing
  
  # postcard landing probability
  
  # particle movement parameters:
  # we'll advance each particle vertically at least by this amount (think gravity and resistance)
  
  # we'll advance each particle vertically at most by this amount (think gravity and resistance)
  
  # we'll shift each particle horizontally at least by this amound (think wind and resistance)
  
  # we'll shift each particle horizontally at least by this amound (think wind and resistance)
  
  # each particle sprite will be scaled down maxScale / this (this < maxScale) at max
  
  # each particle sprite will be scaled down this / minScale (this > minScale) at max
  
  # each particle also "bobs" on horizontal axis (think volumetric resistance) by this amount at least
  
  # each particle also "bobs" on horizontal axis (think volumetric resistance) by this amount at most
  
  # each particle is at least this opaque
  
  # each particle is at least this opaque
  
  # change opacity by at max 1/maxOpacityIncrement
  
  # dynamic speed:
  # do speed correction every speedCorrectionFrames frames
  
  # start without any speed correction
  
  # fall down to this value at most
  
  # get fast at this value at most
  
  # don't set value immidietly change gradually by this amount
  
  # snow heap
  
  # create number of snowflakes adding if required (or regenerate from scratch)
  generate = (number, add) ->
    
    # initialize sprite
    image = new Image()
    image.onload = ->
      ii = 0

      while ii < spritesCount
        sprite = document.createElement('canvas')
        sprite.width = spriteWidth
        sprite.height = spriteHeight
        context = sprite.getContext('2d')
        
        # source image
        
        # source x
        
        # source y
        
        # source width
        
        # source height
        
        # target x
        
        #target y
        
        # target width
        
        # target height
        context.drawImage image, ii * spriteWidth, 0, spriteWidth, spriteHeight, 0, 0, spriteWidth, spriteHeight
        snowflakeSprites.push sprite
        ii++
      snowflakesDefaultCount = number  if number
      snowflakes = []  unless add
      ii = 0

      while ii < snowflakesDefaultCount
        snowflakes.push generateSnowflake()
        ii++
      return

    image.src = snowflakeSpritesLocation
    return
  generateSnowflake = ->
    scale = Math.random() * (maxScale - minScale) + minScale
    
    # x position
    x: Math.random() * bounds.width
    
    # y position
    y: Math.random() * bounds.height
    
    # vertical velocity
    vv: Math.random() * (maxVerticalVelocity - minVerticalVelocity) + minVerticalVelocity
    
    # horizontal velocity
    hv: Math.random() * (maxHorizontalVelocity - minHorizontalVelocity) + minHorizontalVelocity
    
    # scaled sprite width
    sw: scale * spriteWidth
    
    # scaled sprite width
    sh: scale * spriteHeight
    
    # maximum horizontal delta
    mhd: Math.random() * (maxHorizontalDelta - minHorizontalDelta) + minHorizontalDelta
    
    # horizontal delta
    hd: 0
    
    # horizontal delta increment
    hdi: Math.random() / (maxHorizontalVelocity * minHorizontalDelta)
    
    # opacity
    o: Math.random() * (maxOpacity - minOpacity) + minOpacity
    
    # opacity increment
    oi: Math.random() / maxOpacityIncrement
    
    # sprite index
    si: Math.ceil(Math.random() * (spritesCount - 1))
    
    # not landing flag
    nl: false
  
  # check if snowflake is within bounds of postcard
  isWithinPostcard = (x, y) ->
    return false  if x < landingBounds.left
    return false  if y < landingBounds.top
    return false  if x > landingBounds.right
    return false  if y > landingBounds.bottom
    true
  
  # grow the snowHeap
  progressHeapSize = ->
    return  if heapSize >= maxHeapSize
    heapSize += heapSizeIncrement * speedFactor
    snowHeap.style.height = heapSize * 100 + '%'
    return
  
  # help snowflakes fall
  advanceSnowFlakes = ->
    progressHeapSize()
    ii = 0

    while ii < snowflakes.length
      sf = snowflakes[ii]
      
      # we obey the gravity, 'cause it's the law
      sf.y += sf.vv * speedFactor
      
      # while we're obeying the gravity, we do it with style
      sf.x += (sf.hd + sf.hv) * speedFactor
      
      # advance horizontal axis "bobbing"                
      sf.hd += sf.hdi
      
      # inverse "bobbing" direction if we get to maximum delta limit
      sf.hdi = -sf.hdi  if sf.hd < -sf.mhd or sf.hd > sf.mhd
      
      # increment opacity and check opacity value bounds
      sf.o += sf.oi
      sf.oi = -sf.oi  if sf.o > maxOpacity or sf.o < minOpacity
      sf.o = maxOpacity  if sf.o > maxOpacity
      sf.o = minOpacity  if sf.o < minOpacity
      
      # return within dimensions bounds if we've crossed them
      # and don't forget to reset the not-landing (sf.nl) flag
      resetNotLanding = false
      if sf.y > bounds.height + spriteHeight / 2
        sf.y = 0
        resetNotLanding = true
      if sf.y < 0
        sf.y = bounds.height
        resetNotLanding = true
      if sf.x > bounds.width + spriteWidth / 2
        sf.x = 0
        resetNotLanding = true
      if sf.x < 0
        sf.x = bounds.width
        resetNotLanding = true
      sf.nl = false  if resetNotLanding
      
      # try probable landing
      if not sf.nl and isWithinPostcard(sf.x, sf.y)
        
        # if within postcard - try if it should land
        chance = Math.random()
        if chance < landingProbability
          
          # leave a snowmark at random position
          SnowPostcard.addSnowmark Math.random() * landingBounds.width, Math.random() * landingBounds.height, snowflakeSprites[sf.si]
          
          # 
          sf.y = 0
          sf.x = Math.random() * bounds.width
        else
          sf.nl = true
      ii++
    return
  
  # not using, but it allows to increase/decrease speed based on fps
  # in essence - visual feedback on fps value
  adjustSpeedFactor = ->
    if ++currentSpeedCorrectionFrame is speedCorrectionFrames
      lastFps = SystemInformation.getLastFps()
      targetSpeedFactor = (lastFps * (maxSpeedFactor - minSpeedFactor) / 60) + minSpeedFactor
      speedFactor += (if (targetSpeedFactor < speedFactor) then -speedFactorDelta else speedFactorDelta)
      speedFactor = maxSpeedFactor  if speedFactor > maxSpeedFactor
      speedFactor = minSpeedFactor  if speedFactor < minSpeedFactor
      currentSpeedCorrectionFrame = 0
    return
  renderFrame = (context) ->
    
    # fall down one iteration            
    advanceSnowFlakes()
    
    # clear context and save it 
    context.clearRect 0, 0, context.canvas.width, context.canvas.height
    ii = 0

    while ii < snowflakes.length
      sf = snowflakes[ii]
      context.globalAlpha = sf.o
      
      # image
      
      # source x
      
      # source y
      
      # source width
      
      # source height
      
      # target x
      
      # target y
      
      # target width
      
      # target height
      context.drawImage snowflakeSprites[sf.si], 0, 0, spriteWidth, spriteHeight, sf.x, sf.y, sf.sw, sf.sh
      ii++
    return
  updateBounds = ->
    bounds.width = window.innerWidth
    bounds.height = window.innerHeight
    landingBounds = SnowPostcard.updateBounds()
    return
  count = ->
    snowflakes.length
  
  # increase number of falling snowflakes
  # the default increase is snowflakeCountIncrement
  add = (number) ->
    number = snowflakes.length * snowflakeCountIncrement  unless number
    generate number, true
    return
  
  # remove some snowflakes
  # by default we remove more aggressively to free resources faster
  remove = (number) ->
    number = snowflakes.length * snowflakeCountIncrement * snowflakeRemoveFactor  unless number
    snowflakes = snowflakes.slice(0, snowflakes.length - number)  if snowflakes.length - number > 0
    return
  'use strict'
  snowflakes = []
  snowflakesDefaultCount = 1000
  dynamicSnowflakesCount = false
  snowflakeCountIncrement = 0.1
  snowflakeRemoveFactor = 2
  snowflakeSpritesLocation = './res/Snowflakes.png'
  snowflakeSprites = []
  spritesCount = 5
  spriteWidth = 20
  spriteHeight = 20
  bounds =
    width: window.innerWidth
    height: window.innerHeight

  landingBounds = undefined
  landingProbability = 0.5
  minVerticalVelocity = 1
  maxVerticalVelocity = 4
  minHorizontalVelocity = -1
  maxHorizontalVelocity = 3
  minScale = 0.2
  maxScale = 1.25
  minHorizontalDelta = 2
  maxHorizontalDelta = 3
  minOpacity = 0.2
  maxOpacity = 0.9
  maxOpacityIncrement = 50
  speedCorrectionFrames = 60
  currentSpeedCorrectionFrame = 0
  speedFactor = 1
  minSpeedFactor = 0.1
  maxSpeedFactor = 1.5
  speedFactorDelta = 0.05
  snowHeap = document.getElementById('snowHeap')
  heapSizeIncrement = 0.00006
  minHeapSize = 0.10
  maxHeapSize = 0.15
  heapSize = minHeapSize
  generate: generate
  add: add
  remove: remove
  render: renderFrame
  count: count
  updateBounds: updateBounds
  dynamicSnowflakesCount: dynamicSnowflakesCount
)()
