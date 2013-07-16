QueryController = require "../query_controller"


module.exports = class DocumentDeleteController extends QueryController
  constructor: ->
    super
    @method = "delete"

  query: (req, res) ->
    @Model.remove _id: req.params.id

  _controller: (req, res) ->
    query = @_query req, res

    query.exec (err) =>
      return res.send 500 if err
      @_send req, res, 200
