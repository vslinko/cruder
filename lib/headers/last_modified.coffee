module.exports = class LastModifiedHeader
  constructor: (@field) ->

  set: (res, doc) ->
    if doc?[@field] instanceof Date
      res.set "Last-Modified", doc[@field].toUTCString()
