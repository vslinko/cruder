QueryController = require "../query_controller"


module.exports = class DocumentDeleteController extends QueryController
  constructor: ->
    super
    @method = "delete"

  query: (req, res) ->
    @Model.findOne @_params req

  controller: (req, res) ->
    query = @_query req, res

    query.exec (err, doc) =>
      return res.send 500 if err
      return res.send 404 unless doc

      doc.remove (err) =>
        return res.send 500 if err
        @_send req, res, 200
