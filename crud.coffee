queryMethods = [
    'where', 'equals', 'or', 'nor', 'and', 'gt', 'gte', 'lt', 'lte', 'ne', 'in',
    'nin', 'all', 'size', 'regex', 'maxDistance', 'near', 'nearSphere', 'mod',
    'exists', 'elemMatch', 'box', 'center', 'centerSphere', 'polygon', 'select',
    'slice', 'sort', 'limit', 'skip', 'maxscan', 'batchSize', 'comment',
    'snapshot', 'hint', 'slaveOk', 'read', 'lean', 'tailable', 'count',
    'distinct'
]

class ListAction
    constructor: (model) ->
        @query = model.find()

        proxyMethod = (method) ->
            @[method] = ->
                @query[method].apply @query, arguments
                @

        queryMethods.forEach proxyMethod.bind @

    make: ->
        action = (req, res) ->
            @query.exec (err, docs) ->
                if err
                    return res.send 500

                res.send docs

        action.bind @


class PostAction
    constructor: (@model) ->
    make: ->
        action = (req, res) ->
            doc = new @model req.body
            doc.save (err) ->
                if err?.name is 'ValidationError'
                    return res.send 400, err

                if err
                    return res.send 500

                res.send doc

        action.bind @


module.exports.list = (model) ->
    new ListAction model

module.exports.post = (model) ->
    new PostAction model
