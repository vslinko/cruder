queryMethods = [
  "where", "equals", "or", "nor", "and", "gt", "gte", "lt", "lte", "ne", "in",
  "nin", "all", "size", "regex", "maxDistance", "near", "nearSphere", "mod",
  "exists", "elemMatch", "box", "center", "centerSphere", "polygon", "select",
  "slice", "sort", "limit", "skip", "maxscan", "batchSize", "comment",
  "snapshot", "hint", "slaveOk", "read", "lean", "tailable", "count",
  "distinct"
]


class ListAction
  constructor: (model) ->
    @query = model.find()

    queryMethods.forEach (method) =>
      @[method] = ->
        @query[method].apply @query, arguments
        @

  make: ->
    (req, res) =>
      @query.exec (err, docs) ->
        return res.send 500 if err
        res.send docs


class PostAction
  constructor: (@model) ->
  make: ->
    (req, res) =>
      doc = new @model req.body

      doc.save (err) ->
        return res.send 400, err if err?.name is "ValidationError"
        return res.send 500 if err
        res.send doc


class GetAction
  constructor: (@model) ->
  make: ->
    (req, res) =>
      @model.findOne _id: req.params.id, (err, doc) ->
        return req.send 500 if err
        return req.send 404 unless doc
        res.send doc


class PutAction
  constructor: (@model) ->
  make: ->
    (req, res) =>
      data = req.body
      delete data._id if data._id

      @model.findOne _id: req.params.id, (err, doc) ->
        return res.send 500 if err
        return res.send 404 unless doc

        for key, value of data
          doc[key] = value

        doc.save (err) ->
          return res.send 500 if err

          res.set "Location", req.url
          res.send 200, doc


class DeleteAction
  constructor: (@model) ->
  make: ->
    (req, res) =>
      @model.remove _id: req.params.id, (err) ->
        return res.send 500 if err
        res.send 200


module.exports.list = (model) ->
  new ListAction model

module.exports.post = (model) ->
  new PostAction model

module.exports.get = (model) ->
  new GetAction model

module.exports.put = (model) ->
  new PutAction model

module.exports.delete = (model) ->
  new DeleteAction model
