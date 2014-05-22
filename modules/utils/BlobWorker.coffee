###
 # Inline Worker - http://www.html5rocks.com/en/tutorials/workers/basics/#toc-inlineworkers
 # Prefixed in Webkit, Chrome 12, and FF6: window.WebKitBlobBuilder, window.MozBlobBuilder
###
class BlobWorker
  constructor: () ->

  create: (workerBody, onmessage) ->
    if BlobBuilder
      bb = new (window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder)()
      bb.append workerBody
      # Obtain a blob URL reference to our worker 'file'.
      # Note: window.webkitURL.createObjectURL() in Chrome 10+.
      blobURL = (window.URL || window.webkitURL).createObjectURL bb.getBlob()
      #Blob URLs are unique and last for the lifetime of your application (e.g. until the document is unloaded).
      #If you're creating many Blob URLs, it's a good idea to release references that are no longer needed.
      #You can explicitly release a Blob URLs by passing it to window.URL.revokeObjectURL():
      return new Worker(blobURL)
    else
      console.log 'BlobBuilder is not supported in the browser!'
      return

  release: (blobURL) ->
    (window.URL || window.webkitURL).revokeObjectURL blobURL