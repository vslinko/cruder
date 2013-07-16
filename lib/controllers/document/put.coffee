QueryController = require "../query_controller"


module.exports = class DocumentPutController extends QueryController
  constructor: ->
    super
    @method = "put"

  query: (req, res) ->
    @Model.findOne _id: req.params.id

  beforeSaving: (req, res, doc) ->
    data = req.body
    delete data._id
    doc[key] = value for key, value of data
    doc

  controller: (req, res) ->
    query = @_query req, res

    query.exec (err, doc) =>
      return res.send 500 if err
      return res.send 404 unless doc

      @emit "beforeSaving", req, res, doc
      doc = @beforeSaving req, res, doc

      doc.save (err) =>
        return res.send 500 if err
        @_sendFiltered req, res, 200, doc
