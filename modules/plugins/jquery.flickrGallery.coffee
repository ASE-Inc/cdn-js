###
 # Chris Coyier
 # http://css-tricks.com
###
(($) ->
  $.fn.flickrGallery = (o) ->
    o = $.extend {}, o
    @each (i, block) ->
      $.getJSON "http://api.flickr.com/services/feeds/photos_public.gne?ids=40168771@N07&lang=en-us&format=json&jsoncallback=?", (data) ->
        $.each data.items, (index, item) ->
          $("<img/>").attr('src', item.media.m).appendTo(block).wrap '<a href="' + item.link + '"></a>'
) jQuery
###* End Chris Coyier - http://css-tricks.com ###