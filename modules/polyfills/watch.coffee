
unless Object::watch?
  Object::watch = (prop,handler) ->
    oldval= @[prop]
    newval=oldval
    getter= ->
      return newval
    setter = (val) ->
      oldval = newval
      return newval = handler.call @, prop, oldval, val

    if delete @[prop] # can't watch constants
      if Object.defineProperty # ECMAScript 5
        Object.defineProperty @, prop,
          get:getter
          set:setter
          enumerable:false
          configurable:true
      else if Object::__defineGetter__ and Object::__defineSetter__ # legacy
        Object::__defineGetter__.call @, prop, getter
        Object::__defineSetter__.call @, prop, setter

unless Object::unwatch
  Object::unwatch = (prop) ->
    val = @[prop]
    delete @[prop] # remove accessors
    @[prop] = val
