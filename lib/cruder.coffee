CONTEXTS = ["collection", "document"]
METHODS = ["get", "post", "put", "delete"]


class Resource
  constructor: (app, Model, options = {}) ->
    options.baseUrl ||= Model.modelName

    options.baseUrl = options.baseUrl.replace /\/*$/, ""
    options.baseUrl = options.baseUrl.replace /^\/*/, "/"

    collectionUrl = options.baseUrl
    documentUrl = options.baseUrl + "/:id"

    @collection =
      get: new CollectionGetController Model, collectionUrl
      post: new CollectionPostController Model, collectionUrl
      put: new CollectionPutController Model, collectionUrl
      delete: new CollectionDeleteController Model, collectionUrl

    @document =
      get: new DocumentGetController Model, documentUrl
      post: new DocumentPostController Model, documentUrl
      put: new DocumentPutController Model, documentUrl
      delete: new DocumentDeleteController Model, documentUrl

    for context in CONTEXTS
      for method in METHODS
        controller = @[context][method]

        if options[context]?[method]
          for key, value of options[context]?[method]
            controller[key] = value

  register: (app, methods, contexts) ->
    @_do methods, contexts, (controller) ->
      controller.register app

  disable: (methods, contexts) ->
    @_do methods, contexts, (controller) ->
      controller.disable()

  enable: (methods, contexts) ->
    @_do methods, contexts, (controller) ->
      controller.enable()

  _do: (methods = METHODS, contexts = CONTEXTS, action) ->
    contexts = [contexts] unless Array.isArray contexts
    methods = [methods] unless Array.isArray methods

    for context in contexts
      for method in methods
        action @[context][method]


class Controller
  constructor: (@Model, @url) ->
    @disabled = false

  disable: ->
    @disabled = true

  enable: ->
    @disabled = false

  register: (app) ->
    app[@method].call app, @url, @controller.bind @

  _beforeSending: ->
    if typeof @beforeSending is "function"
      @beforeSending.apply @, arguments
    else
      Array::pop.call arguments

  _afterSending: ->
    if typeof @afterSending is "function"
      @afterSending.apply @, arguments


class DisabledController extends Controller
  controller: (req, res) ->
    @_beforeSending req, res
    res.send 405
    @_afterSending req, res


class QueryController extends Controller
  _query: (req, res) ->
    if typeof @query is "function"
      @query req, res
    else
      @query


class CollectionGetController extends QueryController
  constructor: ->
    super
    @method = "get"
    @query = @Model.find()

  controller: (req, res) ->
    return res.send 405 if @disabled

    query = @_query req, res

    query.exec (err, docs) =>
      return res.send 500 if err

      docs = @_beforeSending req, res, docs
      res.send docs
      @_afterSending req, res, docs


class CollectionPostController extends Controller
  constructor: ->
    super
    @method = "post"

  factory: (req, res) ->
    new @Model req.body

  controller: (req, res) ->
    return res.send 405 if @disabled

    doc = @factory req, res

    doc.save (err) =>
      if err
        return res.send 400, err if err.name is "ValidationError"
        return res.send 500

      res.set "Location", @url.replace ":id", doc._id

      doc = @_beforeSending req, res, doc
      res.send 201, doc
      @_afterSending req, res, doc


class CollectionPutController extends DisabledController
  constructor: ->
    super
    @method = "put"


class CollectionDeleteController extends QueryController
  constructor: ->
    super
    @method = "delete"
    @query = @Model.remove()

  controller: (req, res) ->
    return res.send 405 if @disabled

    query = @_query req, res

    query.exec (err) =>
      return res.send 500 if err

      @_beforeSending req, res
      res.send 200
      @_afterSending req, res


class DocumentGetController extends QueryController
  constructor: ->
    super
    @method = "get"

  query: (req, res) ->
    @Model.findOne _id: req.params.id

  controller: (req, res) ->
    return res.send 405 if @disabled

    query = @_query req, res

    query.exec (err, doc) =>
      return req.send 500 if err
      return req.send 404 unless doc

      doc = @_beforeSending req, res, doc
      res.send 200, doc
      @_afterSending req, res, doc


class DocumentPostController extends DisabledController
  constructor: ->
    super
    @method = "post"


class DocumentPutController extends QueryController
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
    return res.send 405 if @disabled

    query = @_query req, res

    query.exec (err, doc) =>
      return res.send 500 if err
      return res.send 404 unless doc

      doc = @beforeSaving req, res, doc

      doc.save (err) =>
        return res.send 500 if err

        doc = @_beforeSending req, res, doc
        res.send 200, doc
        @_afterSending req, res, doc


class DocumentDeleteController extends QueryController
  constructor: ->
    super
    @method = "delete"

  query: (req, res) ->
    @Model.remove _id: req.params.id

  controller: (req, res) ->
    return res.send 405 if @disabled

    query = @_query req, res

    query.exec (err) =>
      return res.send 500 if err

      @_beforeSending req, res
      res.send 200
      @_afterSending req, res


module.exports = (app) ->
  (Model, options) ->
    resource = new Resource app, Model, options
    resource.register app
    resource


module.exports.Resource = Resource
module.exports.Controller = Controller
module.exports.DisabledController = DisabledController
module.exports.QueryController = QueryController
module.exports.CollectionGetController = CollectionGetController
module.exports.CollectionPostController = CollectionPostController
module.exports.CollectionPutController = CollectionPutController
module.exports.CollectionDeleteController = CollectionDeleteController
module.exports.DocumentGetController = DocumentGetController
module.exports.DocumentPostController = DocumentPostController
module.exports.DocumentPutController = DocumentPutController
module.exports.DocumentDeleteController = DocumentDeleteController
