module.exports = class AcceptHeader
  set: (res) ->
    res.set "Accept", "application/json"
