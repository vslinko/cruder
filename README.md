# Our CRUD implementation for express and mongoose

## Example usage

```coffeescript
mongoose = require 'mongoose'
express = require 'express'
crud = require 'rithis-crud'


DocumentSchema = new mongoose.Schema
    name: type: 'string', required: true
    date: type: 'date', required: true

Document = db.model 'documents', DocumentSchema


app.get '/documents', crud
    .list(Document)
    .sort('-date')
    .make()

app.post '/documents', crud
    .post(Document)
    .make()


app.listen 3000
```
