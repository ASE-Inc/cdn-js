
class SerializedAjaxLoader

  constructor: (@preprocess, @callback, @onError) ->
    @preprocess = preprocess
    @data = {}
    @queue = {
      current: {
        url: location.href,
        callback: null
      },
      waiting: null
    }
    @ajaxloader = null
    @ajaxCritical = false
    @useWebWorkers = true

    @onComplete = (responseText, status) =>
      if status is 200 or (mySite.location.is404 and status is 404)
        mySite.location.is404 = false
        callback responseText, status, @data
        @queue['current'].callback(responseText, status) if @queue['current'].callback
        @queue['current'] = null
        @load() if @queue['waiting']
      else
        @onError status #$("#error").html(msg + xhr.status + " " + xhr.statusText)

  load: ->
    if not @ajaxCritical  and (@queue['current'] or @queue['waiting'])
      @ajaxloader.terminate() if @ajaxloader
      if @queue['waiting']
        @queue['current'] = @queue['waiting']
        @queue['waiting'] = null

      @preprocess @queue['current']
      if Modernizr.webworkers and @useWebWorkers
        @ajaxloader = new Worker(mySite_config.urls.workers[@queue['current'].dataType or 'ajax'])
        @ajaxloader.addEventListener 'message', (event) =>
          try
            @ajaxCritical = true
            #(jqXHR,status,responseText)
            # If successful, inject the HTML into all the matched elements
            @onComplete event.data.responseText, event.data.status
            @ajaxCritical = false
          catch e
            onError e
        , false
        @ajaxloader.addEventListener 'error', (e) =>
          console.error ['ERROR: Line ', e.lineno, ' in ', e.filename, ': ', e.message].join ''
          onError event
        , false
        # Take care of vendor prefixes.
        #mySite.webworkers.ajaxloader.postMessage = mySite.webworkers.ajaxloader.webkitPostMessage || mySite.webworkers.ajaxloader.postMessage
        @ajaxloader.postMessage @queue['current'].url
      else
        jQuery.ajax
          url: @queue['current'].url
          type: "GET"
          dataType: @queue['current'].dataType || "html"
          # Complete callback (responseText is used internally)
          complete: (jqXHR, status, responseText) =>
            try
              @ajaxCritical = true
              # Store the response as specified by the jqXHR object
              responseText = jqXHR.responseText
              # If successful, inject the HTML into all the matched elements
              if jqXHR.isResolved()
                # #4825: Get the actual response in case a dataFilter is present in ajaxSettings
                jqXHR.done (r) =>
                  responseText = r
                  @onComplete responseText, status
              else if status is "error"
                onError status
              @ajaxCritical = false
            catch e
              onError e
          error: (jqXHR, textStatus, errorThrown) =>
            onError errorThrown

  loadTo: (queueObj) ->
    @queue['waiting'] = queueObj
    @load()