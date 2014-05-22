
#include mySite.coffee

class Facebook

  constructor: () ->
    $.getScript '//connect.facebook.net/en_US/all.js#appId=#{mySite_config.facebook.appid}', ->
      FB.init
        appId: mySite_config.facebook.appid, # App ID
        channelUrl: 'http//' + document.domain + '/channel.html', # Channel File
        status: true, # check login status
        cookie: true, # enable cookies to allow the server to access the session
        xfbml: !!mySite.enhanced, # parse XFBML
        oauth: true,
        frictionlessRequests: true

      $('#loginbutton,#feedbutton').removeAttr 'disabled'

      $.fn.FBWelcome = (o) ->
        o = $.extend {}, o
        @each ->
          if mySite.user.facebook.currentUser?
            @innerHTML = if /undefined/i.test mySite.user.facebook.currentUser.name then 'Welcome, Guest' else 'Welcome, <img id="FBImage" class="fb_profile_image" src="https://graph.facebook.com/' + mySite.user.facebook.currentUser.id + '/picture"/> ' + mySite.user.facebook.currentUser.name
      # Additional initialization code here
      mySite.user.facebook = new FacebookUser()

      # run once with current status and whenever the status changes
      FB.getLoginStatus mySite.user.facebook.update
      FB.Event.subscribe 'auth.statusChange', mySite.user.facebook.update
      FB.Event.subscribe 'auth.login', (response) ->
      FB.Event.subscribe 'auth.logout', (response) ->
      return

class FacebookUser

  constructor: () ->

  setCurrentUser: ->
    FB.api '/me', (user) ->
      mySite.user.facebook.currentUser = user

  getLoginStatus: ->
    FB.getLoginStatus (response) ->
      if response.status is 'connected'
        # the user is logged in and has authenticated your
        # app, and response.authResponse supplies
        # the user's ID, a valid access token, a signed
        # request, and the time the access token
        # and signed request each expire
        uid = response.authResponse.userID
        accessToken = response.authResponse.accessToken
      else if response.status is 'not_authorized'
        # the user is logged in to Facebook,
        # but has not authenticated your app
      else
        # the user isn't logged in to Facebook.

  getUpdateLoginStatus: ->
    FB.getLoginStatus (response) ->
      if response.status is 'connected'
        # the user is logged in and has authenticated your
        # app, and response.authResponse supplies
        # the user's ID, a valid access token, a signed
        # request, and the time the access token
        # and signed request each expire
        uid = response.authResponse.userID
        accessToken = response.authResponse.accessToken
      else if response.status is 'not_authorized'
        # the user is logged in to Facebook,
        # but has not authenticated your app
      else
        # the user isn't logged in to Facebook.
    , true

  login: (callback, scope) ->
    FB.login callback,
      scope: scope

  logout: (callback) ->
    FB.logout callback
  # run once with current status and whenever the status changes

  update: (response) ->
    if response.authResponse
      #user is already logged in and connected
      console.log 'Welcome!  Fetching your information.... '
      FB.api '/me', (response) ->
        mySite.user.facebook.currentUser = response
        console.log 'We are delighted you, ' + response.name + '.'
    else
      #user is not connected to your app or logged out
      console.log 'User cancelled login or did not fully authorize or logged out.'
      mySite.user.facebook.currentUser = undefined
    mySite.user.facebook.refresh()

  refresh: ->
    $('.FBWelcome').FBWelcome()

