QueryController = require "../query_controller"


module.exports = class CollectionDeleteController extends QueryController
  constructor: ->
    super
    @method = "delete"
    @query = @Model.remove()

  _controller: (req, res) ->
    query = @_query req, res

    query.exec (err) =>
      return res.send 500 if err
      @_send req, res, 200
