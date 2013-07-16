QueryController = require "../query_controller"


module.exports = class CollectionGetController extends QueryController
  constructor: ->
    super
    @method = "get"
    @query = @Model.find()

  controller: (req, res) ->
    query = @_query req, res

    query.exec (err, docs) =>
      return res.send 500 if err
      @_sendFiltered req, res, 200, docs
