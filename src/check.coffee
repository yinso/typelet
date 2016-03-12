AST = require 'astlet'
Type = require './type'
require './primitive-type'

typedASTEnv = AST.baseEnv.nestEnv()

# the idea is that we want to use AST to compile a function
# but we need the following.
# 1 - a base type.
# 2 -

typedASTEnv.define 'integer', class IntegerExp extends AST.get('integer')
  getType: () ->
    Type.baseEnv.get('integer')

class Check
  @compile: (exp) ->
    exp

module.exports = Check
