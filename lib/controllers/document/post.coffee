DisabledController = require "../disabled_controller"


module.exports = class DocumentPostController extends DisabledController
  constructor: ->
    super
    @method = "post"
