merge = (dest, source) ->
  if typeof source is "object"
    for key, value of source
      if source.hasOwnProperty key
        dest[key] = value
  dest


module.exports = (app) ->
  (Model, options) ->
    options.actions ||= ["list", "post", "get", "put", "delete"]
    options.name ||= Model.modelName

    options.list = merge
      method: "get"
      url: "/#{options.name}"
      middlewares: []
      query: (req, res) ->
        Model.find()
      beforeSending: (req, res, docs) ->
        docs
      afterSending: (req, res) ->
    , options.list

    options.post = merge
      method: "post"
      url: "/#{options.name}"
      middlewares: []
      doc: (req, res) ->
        new Model req.body
      beforeSending: (req, res, doc) ->
        res.set "Location", "/#{Model.modelName}/#{doc._id}"
        doc
      afterSending: (req, res) ->
    , options.post

    options.get = merge
      method: "get"
      url: "/#{options.name}/:id"
      middlewares: []
      query: (req, res) ->
        Model.findOne _id: req.params.id
      beforeSending: (req, res, doc) ->
        doc
      afterSending: (req, res) ->
    , options.get

    options.put = merge
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
    , options.put

    options.delete = merge
      method: "delete"
      url: "/#{options.name}/:id"
      middlewares: []
      query: (req, res) ->
        Model.remove _id: req.params.id
      beforeSending: (req, res) ->
      afterSending: (req, res) ->
    , options.delete

    for action in options.actions
      opts = options[action]
      args = []

      args.push opts.url
      args.concat opts.middlewares
      args.push actions[action] opts

      app[opts.method].apply app, args


actions =
  list: (options) ->
    (req, res) ->
      query = options.query req, res
      query.exec (err, docs) ->
        return res.send 500 if err
        docs = options.beforeSending req, res, docs
        res.send docs
        options.afterSending req, res, docs

  post: (options) ->
    (req, res) ->
      doc = options.doc req, res
      doc.save (err) ->
        return res.send 400, err if err?.name is "ValidationError"
        return res.send 500 if err
        doc = options.beforeSending req, res, doc
        res.send 201, doc
        options.afterSending req, res, doc

  get: (options) ->
    (req, res) ->
      query = options.query req, res
      query.exec (err, doc) ->
        return req.send 500 if err
        return req.send 404 unless doc
        doc = options.beforeSending req, res, doc
        res.send 200, doc
        options.afterSending req, res, doc

  put: (options) ->
    (req, res) ->
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
      query = options.query req, res
      query.exec (err) ->
        return res.send 500 if err
        options.beforeSending req, res
        res.send 200
        options.afterSending req, res
