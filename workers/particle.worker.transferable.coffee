### Author: Abhishek Munie ###

NO_OF_PARTICLES = 60
BATCH_SIZE = 1000

particles = []
width = 1600
height = 900
useTransferable = false
useTypedArray = true
running = false
controller = 0

# Takes care of vendor prefixes.
self.postMessage = self.webkitPostMessage or self.postMessage

run = ->
  running = true
  frameData = undefined
  data = undefined
  dLen = undefined
  offset = undefined
  while controller--
    frameData = new Float32Array(particles.length * NO_OF_PROPERTIES)
    len = particles.length

    while len
      particles[--len].update()
      data = particles[len].getDataArray()
      dLen = data.length
      offset = len * dLen
      while dLen
        --dLen
        frameData[offset + dLen] = data[dLen]

    if useTypedArray
      if useTransferable
        self.postMessage frameData.buffer, [frameData.buffer]
      else
        self.postMessage frameData.buffer
    else
      self.postMessage frameData
  controller = BATCH_SIZE
  running = false

addEventListener "message", (event) ->
  switch event.data.action
    when "importParticleScript"
      importScripts event.data.script
    when "initialize"
      particles = new Array(NO_OF_PARTICLES)
      len = NO_OF_PARTICLES
      while len
        particles[--len] = new Particle()
      controller = BATCH_SIZE
      running = true
      run()
    when "resume"
      unless running
        controller = BATCH_SIZE
        run()
    when "stop"
      close()
    when "update"
      switch event.data.property
        when "width"
          width = event.data.value
        when "height"
          height = event.data.value
        when "rint"
          rint = event.data.value
        when "noOfParticles"
          NO_OF_PARTICLES = event.data.value
        when "batchSize"
          BATCH_SIZE = event.data.value
        when "useTransferable"
          useTransferable = event.data.value
  useTypedArray = !!new Uint8Array(event.data).length  if event.data.byteLength
, false