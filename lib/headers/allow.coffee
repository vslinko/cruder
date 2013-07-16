module.exports = class AllowHeaderFactory
  constructor: (@controllers) ->

  factory: ->
    allow = []

    for controller in @controllers
      if controller.enabled()
        allow.push controller.method.toUpperCase()

    allow.join ", "
