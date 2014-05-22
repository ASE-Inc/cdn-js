
(($) ->
  $.fn.pasteEvents = (delay = 20) ->
    $(@).each ->
      $el = $(@)
      $el.on "paste", ->
        $el.trigger "prepaste"
        setTimeout =>
          $el.trigger "postpaste"
        , delay
) jQuery
