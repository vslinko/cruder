QueryController = require "../query_controller"


module.exports = class DocumentGetController extends QueryController
  constructor: ->
    super
    @method = "get"

  query: (req, res) ->
    @Model.findOne @_params req

  controller: (req, res) ->
    query = @_query req, res

    query.exec (err, doc) =>
      return res.send 500 if err
      return res.send 404 unless doc
      @_sendFiltered req, res, 200, doc
