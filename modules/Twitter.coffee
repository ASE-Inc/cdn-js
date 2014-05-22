
class Tweet
  constructor: (data) ->
    @id = data.id_str
    @data = data
    @oEmbedData = undefined
    @worker = undefined
    @loadOEmbed()

  loadOEmbed: ->
    if Modernizr.webworkers
      @worker = new Worker(mySite_config.urls.workers.jsonp)
      @worker.addEventListener 'message', (event) =>
        if event.data.type is "debug"
          console.log event.data.data
        else if event.data.status is 200
          @oEmbedData = event.data.json
      , false
      @worker.addEventListener 'error', (event) ->
        undefined
      , false
      @worker.postMessage "https://api.twitter.com/1/statuses/oembed.json?id=#{data.id_str}&omit_script=true&callback=?"
    else
      jQuery.ajax
        url: "https://api.twitter.com/1/statuses/oembed.json?id=" + data.id_str + "&omit_script=true&callback=?"
        async: true
        dataType: 'json'
        success: (oEmbedData) =>
          @oEmbedData = oEmbedData

class Twitter_Stream
   constructor: (@username) ->
      @count = 30
      @tweets = []
      @updateInterval = 180000
      @loaders =
        update: new SerializedAjaxLoader((current, data) =>
          undefined
        , (responseText, status, data) =>
          responseDOM = null
          window.setTimeout @update, @updateInterval
        , (e)=>
          undefined
        ),
        load: new SerializedAjaxLoader((current, data) =>
          undefined
        , (responseText, status, data) =>
          responseDOM = null
        , (e) =>
          undefined
        )

      @load()
      window.setTimeout(@update, @updateInterval)
      mySite.createTwitterStream = (username) -> new Twitter_Stream(username)

    update: () ->
      $.getJSON "https://twitter.com/status/user_timeline/#{@username}.json?count=9&since_id=#{@tweets[0].id}&callback=?", (data) =>
        $.each data, (index, tweet) =>
          if tweet isnt @tweets[i].data
            @tweets.unshift new Tweet(tweet)

    load: () ->
      $.getJSON "https://twitter.com/status/user_timeline/#{@username}.json?count=9#{if @tweets.length > 0 then "&max_id=" + @tweets[@tweets.length - 1].id else ""}&callback=?", (data) =>
        $.each data, (index, tweet) =>
          @tweets.push new Tweet(tweet)
      #@loader.load.loadTo({url:"https://twitter.com/status/user_timeline/#{@username}.json?count=9"+((@tweets.length>0)?"&max_id="+@tweets[@tweets.length-1].id:"")+"&callback=?"})
