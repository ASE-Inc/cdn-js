
#include Location.coffee
#include SerializedAjaxLoader.coffee

mySite_config = $.extend true,
  urls:
    resource: location.protocol + '//' + location.hostname + '/'
    workers:
      ajax: "/modules/ajaxloader.worker.js"
      jsonp: "/modules/jsonploader.worker.js"
  preloads: []
  twitter_streams: []
  flickr_photostreams: []
  facebook: undefined
  #  appid : undefined
  addThis: undefined
  #  id : undefined
  google:
    plus: undefined
    #  lang : undefined
    analytics: undefined
    #  id : undefined
    cse: undefined
    #  id : undefined
    #  autoCompletionId : undefined
  cufon: undefined
, window.mySite_config

mySite = $.extend true,
  domain: location.protocol + '//' + location.hostname + '/'
  resource: mySite_config.urls.resource
  qualifyURL: qualifyURL
  getLevels: getLevels
  ### Internal: Parse URL components and returns a Locationish object.
   # url - String URL
   # Returns HTMLAnchorElement that acts like Location.
  ###
  parseURL: (url) ->
    a = document.createElement('a')
    a.href = url
    a
  checkString: (str) ->
    try
      str = JSON.parse str
    catch e
      console.error e
    str
  location: new PageLocation()
  pre_location: undefined
  next_location: null
  calcLevelChange: (current = mySite.pre_location, previous = mySite.location) ->
    len = Math.min(current.levels.length, previous.levels.length) - 1
    len = 2 if len < 2
    current.pageChangeLevel = 1
    while current.pageChangeLevel < len
      break if current.pageChange and current.levels[current.pageChangeLevel + 1] is previous.levels[current.pageChangeLevel + 1]
      current.pageChangeLevel++
  updateLocation: ->
    mySite.calcLevelChange()
    # try
    #   _gaq.push(['_trackPageview', mySite.location.url])
    # catch e
    #   console.error e
  pushHistory: (stateobj, title, url) ->
    if Modernizr.history
      history.pushState stateobj, title, url
    else
      location.hash = "!" + mySite.qualifyURL(url).replace mySite.domain, ""
    mySite.pre_location = mySite.location
    mySite.location = new PageLocation()
    mySite.updateLocation()
  replaceHistory: (stateobj, title, url) ->
    if Modernizr.history
      history.replaceState stateobj, title, url
    else
      location.hash = "!" + mySite.qualifyURL(url).replace mySite.domain, ""
    mySite.location = new PageLocation()
    mySite.updateLocation()
  ajaxPageLoader: new SerializedAjaxLoader (current) ->
      if mySite.fireEvent('mySite:ajaxstart', relatedTarget: $("#PL" + mySite.location.pageChangeLevel)[0])
        return
      $('html').addClass "PL" + mySite.location.pageChangeLevel + "_ajax"
      mySite.ajaxPageLoader.queue['current'].url = mySite.location.url
    , (responseText, status) ->
      if mySite.fireEvent('mySite:ajaxsuccess', relatedTarget: $("#PL" + mySite.location.pageChangeLevel)[0], [responseText, status])
        return
      # Create a dummy div to hold the results
      responseDOM = jQuery("<div>")
      # inject the contents of the document in, removing the scripts to avoid any 'Permission Denied' errors in IE
      .append responseText.replace /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ""
      $("header#MainHeader").replaceWith responseDOM.find "header#MainHeader"
      $("header#MainHeader").updateSocialPlugins()
      $("#PL" + mySite.location.pageChangeLevel).replaceWith responseDOM.find "#PL" + mySite.location.pageChangeLevel
      responseDOM.find('title').replaceAll 'title'
      responseDOM.find('meta').each ->
        $this = $(@)
        if $this.attr 'http-equiv'
          $this.replaceAll $('meta[name~="' + $this.attr('http-equiv') + '"]')
        else if $this.attr 'name'
          $this.replaceAll $('meta[name~="' + $this.attr('name') + '"]')
        else if $this.attr 'property'
          $this.replaceAll $('meta[name~="' + $this.attr('property') + '"]')
        else if $this.attr 'itemprop'
          $this.replaceAll $('meta[name~="' + $this.attr('itemprop') + '"]')

      responseDOM = null
      $("#PL" + mySite.location.pageChangeLevel).drawDoc().updateSocialPlugins()
      mySite.update()
      mySite.refresh()
      $('html').removeClass "PL" + mySite.location.pageChangeLevel + "_ajax"
      if mySite.fireEvent('mySite:ajaxcompleted', relatedTarget: $("#PL" + mySite.location.pageChangeLevel)[0])
        return
    , (e) ->
      unless mySite.fireEvent('mySite:ajaxerror', relatedTarget: $("#PL" + mySite.location.pageChangeLevel)[0])
        document.location.replace mySite.location.url

  ajaxTo: (queueObj) ->
    try
      mySite.ajaxPageLoader.loadTo queueObj
    catch e
      document.location.replace(mySite.location.url)
  ajaxTo: null
  twitter_streams: {}
  flickr_photostreams: {}
  refreshSocial: ->
    try
      mySite.user.facebook.refresh()
    catch e
      console.error e
  refresh: ->
    mySite.refreshSocial()
  update: ->
    # outOfStructure=true
    $('html').removeClass 'loading'
  sky:
    stars: []
    snow: []
    starsWorker: undefined
    snowWorker: undefined
  fireEvent: (eType, eParams, eExtraParams) ->
    e = jQuery.Event eType, eParams
    $(document).trigger e, eExtraParams
    e.isDefaultPrevented()
  user:
    facebook: undefined
  getVisibilityState: ->
    document.visibilityState || document.webkitVisibilityState || document.msVisibilityState
  applyAcrossBrowser: (fn) ->
    fn browser for browser in browsers = ["", "webkit", "moz", "o", "ms"]
    undefined
  cloneObject: (o) ->
    newObj = if o instanceof Array then [] else {}
    for k,v in o
      if v and typeof(0[k]) is "object"
        newObj[k] = cloneThis v
      else newObj[k] = v
    newObj
  # remove all own properties on obj, effectively reverting it to a new object
  wipeObject: (obj) -> delete obj[k] for k,v in obj when obj.hasOwnProperty(k)
  relative_time: (rawdate) ->
    i = 0
    date = new Date(rawdate)
    seconds = (new Date() - date) / 1000
    formats = [
      [60, 'seconds', 1],
      [120, '1 minute ago'],
      [3600, 'minutes', 60],
      [7200, '1 hour ago'],
      [86400, 'hours', 3600],
      [172800, 'Yesterday'],
      [604800, 'days', 86400],
      [1209600, '1 week ago'],
      [2678400, 'weeks', 604800]
    ]

    while f = formats[i++]
      if seconds < f[0]
        return f[2] ? Math.floor(seconds / f[2]) + ' ' + f[1] + ' ago' : f[1]
    return 'A while ago'
  safeCallback: (callback, safeAfter) ->
    return () ->
      safeAfter(callback)
  importScript: (src, defer, id, callback) ->
    sp = document.createElement('script')
    sp.type = "text/javascript"
    sp.src = src
    sp.async = true
    sp.id = id if id?
    sp.defer = "defer" if defer
    if callback
      sp.onload = sp.onreadystatechange = ->
        rs = @readyState
        return if rs and rs isnt 'complete' && rs isnt 'loaded'
        try
          callback()
        catch e
          console.errore
    s = document.getElementsByTagName('script')[0]
    s.parentNode.insertBefore sp, s
, window.mySite