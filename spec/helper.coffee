_      = require 'underscore'
Driver = require '../lib/index'
require '../lib/sync'
require '../lib/spec'

global.expect  = require 'expect.js'

global.p = (args...) -> console.log args...

# Support for synchronous specs.
global.itSync = (desc, callback) ->
  try
    require 'fibers'
  catch e
    console.log """
      WARN:
        You are trying to use synchronous mode.
        Synchronous mode is optional and requires additional `fibers` library.
        It seems that there's no such library in Your system.
        Please install it with `npm install fibers`."""
    throw e

  it desc, (done) ->
    that = @
    Fiber(->
      callback.apply that, [done]
      done()
    ).run()

# Stub for testing Integration wit Model.
exports.Model = class Model
  isModel: true

  constructor: (attrs) ->
    @errors = {}
    @attrs = attrs || {}
    @attrs._class = 'Model'
  getId: -> @attrs.id
  setId: (id) -> @attrs.id = id
  toHash: -> @attrs
  @fromHash: (doc) -> new Model doc

Driver.fromHash = (doc) ->
  if doc._class == 'Model' then new Model(doc) else doc