module.exports = class AllowHeader
  constructor: (@controllers) ->

  set: (res) ->
    allow = []

    for controller in @controllers
      if controller.enabled()
        allow.push controller.method.toUpperCase()

    res.set "Allow", allow.join ", "
