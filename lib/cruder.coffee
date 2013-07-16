Resource = require "./resource"


module.exports = (app) ->
  (Model, options) ->
    resource = new Resource Model, options
    resource.register app
    resource
