Type = require '../src/type'
TypeEnv = require '../src/type-env'
{ assert } = require 'chai'

describe 'Type env test', ->

  env = null

  it 'can create type env', ->
    env = new TypeEnv()

  it 'can associate name to a type', ->

    env.define 'integer', Type.Integer
    assert.ok env.has 'integer'
    assert.strictEqual Type.Integer, env.get 'integer'

  it 'cannot re-associate name to a new type', ->
    assert.throws ->
      env.define 'integer', Type.Float

  nested = null

  it 'can nest scope', ->

    nested = env.pushEnv()
    nested.define 'integer', Type.Float
    assert.strictEqual Type.Float, nested.get('integer')
    assert.strictEqual Type.Integer, nested.popEnv().get('integer')

  # we want this for what purpose?

