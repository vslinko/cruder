merge = (dest, source) ->
  if typeof source is "object"
    for key, value of source
      if source.hasOwnProperty key
        dest[key] = value
  dest


module.exports = (app) ->
  (Model, options = {}) ->
    options.name ||= Model.modelName
    options.collection ||= {}
    options.document ||= {}

    options.collection.get = merge
      enabled: true
      method: "get"
      url: "/#{options.name}"
      middlewares: []
      query: (req, res) ->
        Model.find()
      beforeSending: (req, res, docs) ->
        docs
      afterSending: (req, res) ->
    , options.collection.get

    options.collection.post = merge
      enabled: true
      method: "post"
      url: "/#{options.name}"
      middlewares: []
      doc: (req, res) ->
        new Model req.body
      beforeSending: (req, res, doc) ->
        res.set "Location", "/#{Model.modelName}/#{doc._id}"
        doc
      afterSending: (req, res) ->
    , options.collection.post

    options.document.get = merge
      enabled: true
      method: "get"
      url: "/#{options.name}/:id"
      middlewares: []
      query: (req, res) ->
        Model.findOne _id: req.params.id
      beforeSending: (req, res, doc) ->
        doc
      afterSending: (req, res) ->
    , options.document.get

    options.document.put = merge
      enabled: true
      method: "put"
      url: "/#{options.name}/:id"
      middlewares: []
      query: (req, res) ->
        Model.findOne _id: req.params.id
      beforeSaving: (req, res, doc) ->
        data = req.body
        delete data._id
        merge doc, data
      beforeSending: (req, res, doc) ->
        doc
      afterSending: (req, res) ->
    , options.document.put

    options.document.delete = merge
      enabled: true
      method: "delete"
      url: "/#{options.name}/:id"
      middlewares: []
      query: (req, res) ->
        Model.remove _id: req.params.id
      beforeSending: (req, res) ->
      afterSending: (req, res) ->
    , options.document.delete

    for context in ["collection", "document"]
      for action, opts of options[context]
        args = []

        args.push opts.url
        args.concat opts.middlewares
        args.push actions[context][action] opts

        app[opts.method].apply app, args


actions =
  collection:
    get: (options) ->
      (req, res) ->
        return res.send 405 unless options.enabled
        query = options.query req, res
        query.exec (err, docs) ->
          return res.send 500 if err
          docs = options.beforeSending req, res, docs
          res.send docs
          options.afterSending req, res, docs

    post: (options) ->
      (req, res) ->
        return res.send 405 unless options.enabled
        doc = options.doc req, res
        doc.save (err) ->
          return res.send 400, err if err?.name is "ValidationError"
          return res.send 500 if err
          doc = options.beforeSending req, res, doc
          res.send 201, doc
          options.afterSending req, res, doc

  document:
    get: (options) ->
      (req, res) ->
        return res.send 405 unless options.enabled
        query = options.query req, res
        query.exec (err, doc) ->
          return req.send 500 if err
          return req.send 404 unless doc
          doc = options.beforeSending req, res, doc
          res.send 200, doc
          options.afterSending req, res, doc

    put: (options) ->
      (req, res) ->
        return res.send 405 unless options.enabled
        query = options.query req, res
        query.exec (err, doc) ->
          return res.send 500 if err
          return res.send 404 unless doc
          doc = options.beforeSaving req, res, doc
          doc.save (err) ->
            return res.send 500 if err
            doc = options.beforeSending req, res, doc
            res.send 200, doc
            options.afterSending req, res, doc

    delete: (options) ->
      (req, res) ->
        return res.send 405 unless options.enabled
        query = options.query req, res
        query.exec (err) ->
          return res.send 500 if err
          options.beforeSending req, res
          res.send 200
          options.afterSending req, res
