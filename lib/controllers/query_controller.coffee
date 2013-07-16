Controller = require "./controller"


module.exports = class QueryController extends Controller
  _query: (req, res) ->
    if typeof @query is "function"
      @query req, res
    else
      @query
