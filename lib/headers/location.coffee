module.exports = class LocationHeader
  constructor: (@url) ->

  set: (res, doc) ->
    location = @url

    for key, value of doc
      location = location.replace ":" + key, value

    res.set "Location", location
