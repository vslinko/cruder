events = require "events"


CONTEXTS = ["collection", "document"]
METHODS = ["get", "post", "put", "delete"]
EVENTS = ["beforeSaving", "beforeSending", "afterSending"]

class Resource extends events.EventEmitter
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

    CONTEXTS.forEach (context) =>
      @_attachAllowHeader context

      METHODS.forEach (method) =>
        controller = @[context][method]

        if options[context]?[method]
          for key, value of options[context]?[method]
            controller[key] = value

        EVENTS.forEach (event) =>
          controller.on event, (req, res, data) =>
            @emit "#{method}:#{context}:#{event}", req, res, data
            @emit "#{context}:#{event}", req, res, data
            @emit "#{method}:#{event}", req, res, data

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

  _attachAllowHeader: (context) ->
    factory = new AllowHeaderFactory [
      @[context].get
      @[context].post
      @[context].put
      @[context].delete
    ]

    @on "#{context}:beforeSending", (req, res) ->
      res.set "Allow", factory.factory()


class AllowHeaderFactory
  constructor: (@controllers) ->

  factory: ->
    allow = []

    for controller in @controllers
      if controller.enabled()
        allow.push controller.method.toUpperCase()

    allow.join ", "


class Controller extends events.EventEmitter
  constructor: (@Model, @url) ->
    @_disabled = false

  disable: ->
    @_disabled = true

  enable: ->
    @_disabled = false

  disabled: ->
    @_disabled

  enabled: ->
    not @_disabled

  register: (app) ->
    app[@method] @url, (req, res) =>
      @controller req, res

  controller: (req, res) ->
    return res.send 405 if @_disabled
    @_controller req, res

  _sendFiltered: (req, res, code, data) ->
    @_send req, res, code, data, true

  _send: (req, res, code, data, filter = false) ->
    @emit "beforeSending", req, res, data

    if typeof @beforeSending is "function"
      if filter
        data = @beforeSending req, res, data
      else
        @beforeSending req, res, data

    res.send code, data

    @emit "afterSending", req, res, data

    if typeof @afterSending is "function"
      @afterSending req, res, data


class DisabledController extends Controller
  constructor: ->
    super
    @_disabled = true

  enable: ->


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

  _controller: (req, res) ->
    query = @_query req, res
    query.exec (err, docs) =>
      return res.send 500 if err
      @_sendFiltered req, res, 200, docs


class CollectionPostController extends Controller
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


class CollectionPutController extends DisabledController
  constructor: ->
    super
    @method = "put"


class CollectionDeleteController extends QueryController
  constructor: ->
    super
    @method = "delete"
    @query = @Model.remove()

  _controller: (req, res) ->
    query = @_query req, res
    query.exec (err) =>
      return res.send 500 if err
      @_send req, res, 200


class DocumentGetController extends QueryController
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

  _controller: (req, res) ->
    query = @_query req, res
    query.exec (err, doc) =>
      return res.send 500 if err
      return res.send 404 unless doc
      @emit "beforeSaving", req, res, doc
      doc = @beforeSaving req, res, doc
      doc.save (err) =>
        return res.send 500 if err
        @_sendFiltered req, res, 200, doc


class DocumentDeleteController extends QueryController
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


module.exports = (app) ->
  (Model, options) ->
    resource = new Resource app, Model, options
    resource.register app
    resource


module.exports.Resource = Resource
module.exports.AllowHeaderFactory = AllowHeaderFactory
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
