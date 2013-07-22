Resource = require "./resource"


module.exports = (app, db) ->
  (model, options) ->
    if typeof model is "string" and db
      model = db.model model

    resource = new Resource model, options
    resource.register app
    resource
