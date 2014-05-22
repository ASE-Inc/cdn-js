

qualifyURL = (url) ->
  div = document.createElement('div')
  div.innerHTML = "<a></a>"
  div.firstChild.href = url #Ensures that the href is properly escaped
  div.innerHTML = div.innerHTML #Run the current innerHTML back through the parser
  div.firstChild.href

getLevels = (url) ->
  Levels = url.toString().split '/'
  Levels.splice i--, 1 for i in [0...Levels.length] when not Levels[i]
  Levels

class PageLocation

  constructor: (location = window.location) ->
    @href = location.href
    @url = location.href.replace(location.hash, "")
    @hash = location.hash
    @pageChangeLevel = undefined
    @params =
      serviceMode: location.hash is "#?test=true"
    HASH = @hash

    if HASH
      off1 = HASH.indexOf('!')
      off2 = HASH.indexOf('?')

      if off2 >= 0
        params = []
        for p in HASH.slice(off2 + 1).split /&amp|&/g
          param = p.split '='
          try
            param[1] = JSON.parse(param[1])
          catch e
            console.error e
          params[param[0]] = param[1]

        $.extend @params, params
        @hash = HASH.slice(0, off2 - 1)
        if off1 >= 0
          @url = HASH.slice(off1 + 1, off2 - 1)
          @hash = HASH.slice(0, off1 - 1)

      else if off1 >= 0
        @url = qualifyURL HASH.slice off1 + 1
        @hash = HASH.slice 0, off1 - 1

    @levels = getLevels @url
    @pageLevel = @levels.length - 2 || 1
    @is404 = false