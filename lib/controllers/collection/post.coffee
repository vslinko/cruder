Controller = require "../controller"


module.exports = class CollectionPostController extends Controller
  constructor: ->
    super
    @method = "post"

  factory: (req, res) ->
    doc = new @Model req.body
    doc[key] = value for key, value of @_params req
    doc

  controller: (req, res) ->
    doc = @factory req, res

    @emit "beforeSaving", req, res, doc

    if typeof @beforeSaving is "function"
      doc = @beforeSaving req, res, doc

    doc.save (err) =>
      return res.send 400, err if err?.name is "ValidationError"
      return res.send 500 if err
      @_sendFiltered req, res, 201, doc
