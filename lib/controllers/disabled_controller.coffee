Controller = require "./controller"


module.exports = class DisabledController extends Controller
  constructor: ->
    super
    @_disabled = true

  enable: ->
    @
