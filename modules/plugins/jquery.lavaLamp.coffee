
#include ../utils/OptimizedResize.coffee

(($) ->
  $.fn.lavaLamp = (options) ->
    options = $.extend {}, options

    @each ->
      $this = $ @
      inatanceId = "ll" + Math.floor(Math.random() * 100000)
      $leftPad = $('<li class="lavalampback leftPad '+inatanceId+'"></li>').appendTo $this
      $hoverPad = $('<li class="lavalampback hoverPad '+inatanceId+'"></li>').appendTo $this
      $rightPad = $('<li class="lavalampback rightPad '+inatanceId+'"></li>').appendTo $this

      styletag = $('<style type="text/css" class="lavalampStyle"> </style>').appendTo $ 'head'

      $leftPad.addClass  inatanceId
      $hoverPad.addClass inatanceId
      $rightPad.addClass inatanceId

      setCurrent = (el = $("li.active", @)) =>
        el = $("li:first", @) unless el[0]?

        el_OL = el.offset().left
        el_OW = el.width()
        el_parent = el.parent()
        el_parent_OL = el_parent.offset().left
        el_parent_OW = el_parent.width()
        el_OL -= el_parent_OL
        styletag.html '.' + inatanceId + '.leftPad  {' + 'left: 0'        + 'px;' + 'width: ' + el_OL + 'px;' + '} ' +
                      '.' + inatanceId + '.hoverPad {' + 'left: ' + el_OL + 'px;' + 'width: ' + el_OW + 'px;' + '} ' +
                      '.' + inatanceId + '.rightPad {' + 'right: 0'       + 'px;' + 'width: ' + (el_parent_OW - el_OL - el_OW) + 'px;' + '}'
                    # '.' + inatanceId + '.rightPad {' + 'left: ' + (el_OL + el_OW) + 'px;' + 'width: ' + Math.max(0, el_parent_OW - el_OL - el_OW) + 'px;' + '}'

      $(">li>a", @).hover (event) -> setCurrent $ @parentElement

      $(@).hover (event) -> ,
      (event) -> setCurrent $("li.active", @)

      $("li>a", @).not(".lavalampback").click (event) -> setCurrent $ @parentElement

      setCurrent()
      new OptimizedResize setCurrent

  $ ->
    $('.lavalamp').lavaLamp()

    window

) jQuery

