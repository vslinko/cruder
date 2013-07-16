AllowHeaderFactory = require "./headers/allow"
events = require "events"


CONTEXTS = ["collection", "document"]
METHODS = ["get", "post", "put", "delete"]
EVENTS = ["beforeSaving", "beforeSending", "afterSending"]


controllers =
  collection:
    get: require "./controllers/collection/get"
    post: require "./controllers/collection/post"
    put: require "./controllers/collection/put"
    delete: require "./controllers/collection/delete"
  document:
    get: require "./controllers/document/get"
    post: require "./controllers/document/post"
    put: require "./controllers/document/put"
    delete: require "./controllers/document/delete"


module.exports = class Resource extends events.EventEmitter
  constructor: (Model, options = {}) ->
    options.baseUrl ||= Model.modelName

    options.baseUrl = options.baseUrl.replace /\/*$/, ""
    options.baseUrl = options.baseUrl.replace /^\/*/, "/"

    urls =
      collection: options.baseUrl
      document: options.baseUrl + "/:id"

    CONTEXTS.forEach (context) =>
      @[context] = {}

      METHODS.forEach (method) =>
        controller = new controllers[context][method] Model, urls[context]
        @[context][method] = controller

        if options[context]?[method]
          for key, value of options[context]?[method]
            controller[key] = value

        EVENTS.forEach (event) =>
          controller.on event, (req, res, data) =>
            @emit "#{method}:#{context}:#{event}", req, res, data
            @emit "#{context}:#{event}", req, res, data
            @emit "#{method}:#{event}", req, res, data

      @_attachAllowHeader context

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
