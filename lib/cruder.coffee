cruder = (app, Model, options, callback) ->
  options.actions ||= ["list", "post", "get", "put", "delete"]
  options.modelName ||= Model.modelName
  options.query ||= Model.find()

  if "list" in options.actions
    app.get "/#{options.modelName}", cruder.list options.query, callback

  if "post" in options.actions
    app.post "/#{options.modelName}", cruder.post Model, callback

  if "get" in options.actions
    app.get "/#{options.modelName}/:id", cruder.get Model, callback

  if "put" in options.actions
    app.put "/#{options.modelName}/:id", cruder.put Model, callback

  if "delete" in options.actions
    app.delete "/#{options.modelName}/:id", cruder.delete Model, callback


cruder.list = (query, callback) ->
  (req, res) ->
    query.find req.query
    query.exec (err, docs) ->
      return res.send 500 if err
      callback "list", docs if callback
      res.send docs


cruder.post = (Model, callback) ->
  (req, res) ->
    doc = new Model req.body

    doc.save (err) ->
      return res.send 400, err if err?.name is "ValidationError"
      return res.send 500 if err
      callback "post", doc if callback
      res.send 201, doc


cruder.get = (Model, callback) ->
  (req, res) ->
    Model.findOne _id: req.params.id, (err, doc) ->
      return req.send 500 if err
      return req.send 404 unless doc
      callback "get", doc if callback
      res.send doc


cruder.put = (Model, callback) ->
  (req, res) ->
    data = req.body
    delete data._id if data._id

    Model.findOne _id: req.params.id, (err, doc) ->
      return res.send 500 if err
      return res.send 404 unless doc

      for key, value of data
        doc[key] = value

      doc.save (err) ->
        return res.send 500 if err

        res.set "Location", req.url
        callback "put", doc if callback
        res.send 200, doc


cruder.delete = (Model, callback) ->
  (req, res) ->
    Model.remove _id: req.params.id, (err) ->
      return res.send 500 if err
      res.send 200


module.exports = cruder
