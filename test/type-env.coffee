Type = require '../src/type'
TypeEnv = require '../src/type-env'
{ assert } = require 'chai'

describe 'Type env test', ->

  env = null

  it 'can create type env', ->
    env = new TypeEnv()

  it 'can associate name to a type', ->

    env.define 'integer', Type.baseEnv.get('integer')
    assert.ok env.has 'integer'
    assert.strictEqual Type.baseEnv.get('integer'), env.get 'integer'

  it 'cannot re-associate name to a new type', ->
    assert.throws ->
      env.define 'integer', Type.baseEnv.get('float')

  nested = null

  it 'can nest scope', ->

    nested = env.pushEnv()
    nested.define 'integer', Type.baseEnv.get('float')
    assert.strictEqual Type.baseEnv.get('float'), nested.get('integer')
    assert.strictEqual Type.baseEnv.get('integer'), nested.popEnv().get('integer')

  # we want this for what purpose?
