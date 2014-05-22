### @author Abhishek Munie ###

#include modules/H5BPConsoleFix.coffee
#include modules/Utils.coffee
#include modules/Polyfills.coffee
#include modules/Location.coffee
#include modules/ParticleWorker.coffee
#include modules/Facebook.coffee
#include modules/Twitter.coffee
#include modules/SerializedAjaxLoader.coffee
#include modules/loadGoogleApis.coffee
#include modules/Plugins.coffee
#include modules/mySite.coffee
#include modules/


$('html').addClass if RegExp(" AppleWebKit/").test(navigator.userAgent) then 'applewebkit' else 'not-applewebkit'


mySite.location.is404 = !! $('.container404')[0]
$('html').addClass 'serviceMode' if mySite.location.params.serviceMode

if mySite_config.facebook
  new Facebook()

if mySite_config.google.plus
  window.___gcfg =
    lang: mySite_config.google.plus.lang || 'en-US'
    parsetags: 'explicit'
  mySite.importScript 'https://apis.google.com/js/plusone.js'

(($) ->


  mySite.flickr_photostreams[mySite_config.flickr_photostreams[0]] =
    photos: []

  $.getJSON "http://api.flickr.com/services/feeds/photos_public.gne?ids=40168771@N07&lang=en-us&format=json&jsoncallback=?", (data) ->
    $.each data.items, (index, item) ->
      mySite.flickr_photostreams[mySite_config.flickr_photostreams[0]].photos.push item

  $.fn.updateSocialPlugins = (o) ->
    o = $.extend {}, o
    @each ->
      try
        gapi.plusone.go @
      catch e
        console.error e
      try
        FB.XFBML.parse @
      catch e
        console.error e

  $.fn.drawDoc = (options) ->
    options = $.extend {}, options
    @each ->
      $this = $(@)
      $this.find("a.ajaxedNav").ajaxLinks()
      try
        # $this.find(".alert-message").alert()
      catch e
        console.error e
      $this.find(".lavaLamp").lavaLamp()
      $this.find("a.scroll").click (e) ->
        $.scrollTo @hash || 0, 1500
        e.preventDefault()
      try
        # $this.find("a.lightbox").lightBox()
      catch e
        console.error e
      if Modernizr.canvas
        $this.find(".twinkling-stars").paintTwinklingStars()
      try
        # Cufon.refresh()
      catch e
        console.error e

  $.fn.ajaxLinks = (o) ->
    o = $.extend {}, o
    @each ->
      $(@).on 'click', (e) ->
        link = event.currentTarget

        throw "requires an anchor element" if link.tagName.toUpperCase() isnt 'A'
        return if location.protocol isnt link.protocol or location.host isnt link.host
        return if event.which > 1 or event.metaKey
        #return if link.hash and link.href.replace(link.hash, '') is location.href.replace(location.hash, '')

        $('html').removeClass 'PoppedBack'
        mySite.pushHistory null, '', @href
        mySite.ajaxTo
          url: @href
          callback: (responseText, status) ->

        e.preventDefault()
        return false

)(jQuery)

jQuery(document).ready ($) ->
  $('html').removeClass 'loading'
  $('html').addClass 'interactive'
  enhance = ->
    mySite.enhanced = true
    $(document).updateSocialPlugins()
    mySite.refresh()
    mySite.importScript '//js.abhishekmunie.com/libs/cufon-yui.basicfonts.js', true if mySite_config.cufon
    for twitter_stream in mySite_config.twitter_streams
      mySite.twitter_streams[twitter_stream] = mySite.createTwitterStream twitter_stream
    # if mySite_config.preloads
    #   setTimeout -> $.preload mySite_config.preloads, 5000
    $('html').addClass 'enhanced'

  $.ajaxSetup cache: true

  $(window).load ->
    $('html').removeClass 'interactive'
    $('html').addClass 'complete'
    window.clearTimeout enID
    enhance()

  window.addEventListener 'hashchange', (event) ->

  window.addEventListener 'popstate', (event) ->
    $('html').addClass 'PoppedBack'
    mySite.pre_location = mySite.location
    mySite.location = new PageLocation()
    mySite.updateLocation()
    if mySite.location.is404 or mySite.location.href.replace(mySite.location.hash, '') is mySite.pre_location.href.replace(mySite.pre_location.hash, '')
      mySite.refresh()
      return
    mySite.ajaxTo
      url: location.pathname

  $(window).unload ->

  $(document.body).on 'online', ->
    console.log "Online"
  $(document.body).on 'offine', ->
    console.log "Offline"

  # orientation on firefox
  handleOrientation =
  window.addEventListener "MozOrientation", (orientData) ->
    mySite.orientation = true
    mySite.orientX = orientData.x
    mySite.orientY = orientData.y
  , true
  # orientation on mobile safari
  if window.DeviceMotionEvent?
    mySite.orientation = true
    window.ondevicemotion = (event) ->
      mySite.orientX = event.accelerationIncludingGravity.x
      mySite.orientY = event.accelerationIncludingGravity.y

  if location.hash
    if /!/g.test location.hash
      if Modernizr.history
        history.replaceState null, '', location.hash.toString().substring(2)
        mySite.ajaxTo
          url: location.hash.toString().substring(2)
      else
        document.location.href = location.hash.toString().substring(2)

  $(document).ajaxSuccess ->

  mySite.importScript "https://www.google.com/jsapi?callback=loadGoogleApis", true if mySite_config.google.cse

  mySite.update()
  $('body').drawDoc()
  $('html').addClass 'initialized'
  enID = window.setTimeout enhance, 3000
  setTimeout ->
    $('html').addClass('startup')
  , 500
  setTimeout ->
    $('html').removeClass('startup')
  , 5000
