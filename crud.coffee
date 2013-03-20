module.exports.list = (query) ->
  (req, res) ->
    query.exec (err, docs) ->
      return res.send 500 if err
      res.send docs


module.exports.post = (Model) ->
  (req, res) ->
    doc = new Model req.body

    doc.save (err) ->
      return res.send 400, err if err?.name is "ValidationError"
      return res.send 500 if err
      res.send 201, doc


module.exports.get = (Model) ->
  (req, res) ->
    Model.findOne _id: req.params.id, (err, doc) ->
      return req.send 500 if err
      return req.send 404 unless doc
      res.send doc


module.exports.put = (Model) ->
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


module.exports.delete = (Model) ->
  (req, res) ->
    Model.remove _id: req.params.id, (err) ->
      return res.send 500 if err
      res.send 200
