Controller = require "../controller"


module.exports = class CollectionPostController extends Controller
  constructor: ->
    super
    @method = "post"

  factory: (req, res) ->
    new @Model req.body

  _controller: (req, res) ->
    doc = @factory req, res

    @emit "beforeSaving", req, res, doc

    if typeof @beforeSaving is "function"
      doc = @beforeSaving req, res, doc

    doc.save (err) =>
      return res.send 400, err if err?.name is "ValidationError"
      return res.send 500 if err

      res.set "Location", @url + "/" +  doc._id
      @_sendFiltered req, res, 201, doc
