QueryController = require "../query_controller"


module.exports = class DocumentGetController extends QueryController
  constructor: ->
    super
    @method = "get"

  query: (req, res) ->
    @Model.findOne _id: req.params.id

  _controller: (req, res) ->
    query = @_query req, res

    query.exec (err, doc) =>
      return req.send 500 if err
      return req.send 404 unless doc
      @_sendFiltered req, res, 200, doc
