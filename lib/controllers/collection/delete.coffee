QueryController = require "../query_controller"


module.exports = class CollectionDeleteController extends QueryController
  constructor: ->
    super
    @method = "delete"

  query: (req, res) ->
    @Model.remove @_params req

  controller: (req, res) ->
    query = @_query req, res

    query.exec (err) =>
      return res.send 500 if err
      @_send req, res, 200
