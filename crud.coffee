assert = require "assert"


crud = (app, Model, options) ->
  options.actions ||= ["list", "post", "get", "put", "delete"]
  options.modelName ||= Model.modelName
  options.query ||= Model.find()

  if "list" in options.actions
    app.get "/#{options.modelName}", crud.list options.query

  if "post" in options.actions
    app.post "/#{options.modelName}", crud.post Model

  if "get" in options.actions
    app.get "/#{options.modelName}/:id", crud.get Model

  if "put" in options.actions
    app.put "/#{options.modelName}/:id", crud.put Model

  if "delete" in options.actions
    app.delete "/#{options.modelName}/:id", crud.delete Model


crud.list = (query) ->
  (req, res) ->
    query.exec (err, docs) ->
      return res.send 500 if err
      res.send docs


crud.post = (Model) ->
  (req, res) ->
    doc = new Model req.body

    doc.save (err) ->
      return res.send 400, err if err?.name is "ValidationError"
      return res.send 500 if err
      res.send 201, doc


crud.get = (Model) ->
  (req, res) ->
    Model.findOne _id: req.params.id, (err, doc) ->
      return req.send 500 if err
      return req.send 404 unless doc
      res.send doc


crud.put = (Model) ->
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
        res.send 200, doc


crud.delete = (Model) ->
  (req, res) ->
    Model.remove _id: req.params.id, (err) ->
      return res.send 500 if err
      res.send 200


module.exports = crud
