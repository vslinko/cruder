DisabledController = require "../disabled_controller"


module.exports = class CollectionPutController extends DisabledController
  constructor: ->
    super
    @method = "put"
