
unless Object::cloneThis?
  Object::cloneThis = ->
    newObj = if @ instanceof Array then [] else {}
    for i in @
      continue if i is 'cloneThis'
      if @[i] and typeof @[i] is "object"
        newObj[i] = @[i].cloneThis()
      else
        newObj[i] = @[i]
    return newObj
