loadGoogleApis = ->
  google.load 'search', '1',
    language: 'en'
    style: google.loader.themes.V2_DEFAULT
    callback: ->
      customSearchOptions = {}
      imageSearchOptions = {}
      imageSearchOptions['layout'] = google.search.ImageSearch.LAYOUT_POPUP
      customSearchOptions['enableImageSearch'] = true
      customSearchOptions['imageSearchOptions'] = imageSearchOptions
      customSearchControl = new google.search.CustomSearchControl mySite_config.googleCSEId, customSearchOptions
      customSearchControl.setResultSetSize google.search.Search.FILTERED_CSE_RESULTSET
      options = new google.search.DrawOptions()
      options.setSearchFormRoot 'Google_CS_Box'
      options.setAutoComplete true
      customSearchControl.setAutoCompletionId mySite_config.googleCSEAutoCompletionId
      customSearchControl.draw 'cse_result', options
      #Page Search
      if document.getElementById('Google_Page_CS_Box')
        customSearchOptions = {}
        imageSearchOptions = {}
        imageSearchOptions['layout'] = google.search.ImageSearch.LAYOUT_POPUP
        customSearchOptions['enableImageSearch'] = true
        customSearchOptions['imageSearchOptions'] = imageSearchOptions
        customSearchControl = new google.search.CustomSearchControl mySite_config.googleCSEId, customSearchOptions
        customSearchControl.setResultSetSize google.search.Search.FILTERED_CSE_RESULTSET
        options = new google.search.DrawOptions()
        options.setSearchFormRoot 'Google_Page_CS_Box'
        options.setAutoComplete true
        customSearchControl.setAutoCompletionId mySite_config.googleCSEAutoCompletionId
        customSearchControl.draw 'cse_Page_result', options
        customSearchControl.execute document.getElementById('goog-wm-qt').valu