util = require './util'
ASTLet = require 'astlet'

$params: [
    { $symbol: 'foo' }
    { $symbol: 'bar' }
  ]
$body:
  $eq:
    $lhs: { $symbol: 'foo' }
    $rhs: { $symbol: 'bar' }

class Check
  constructor: (exp, check) ->
    if not (@ instanceof Check)
      return new Check exp, check
    @exp = exp
    @check = check
  @compile: (exp) ->
    if not (exp.$params and exp.$body)
      throw new Error("Check.compile:toplevel_require_$params_and_$body")
    params =
      for param in exp.$params
        @_compileOne param
    body = @_compileOne exp.$body
    @_verifyBody params, body # what exactly do I want to do here? a full-on AST check?
    proc = ProcedureExp(params, body).compile()
    new @ exp, proc
  @_verifyBody: (params, body) ->
    # can we allow this to be hooked in?
  @_compileOne: (exp) ->
    if exp.$symbol
      SymbolExp exp.$symbol
    else if exp.$literal
      LiteralExp exp.$literal
    else if exp.$member
      head = @_compileOne(exp.$member.head)
      key = LiteralExp(exp.$member.key)
      MemberExp head, key
    else if exp.$eq
      BinaryExp SymbolExp('=='), @_compileOne(exp.$eq.lhs), @_compileOne(exp.$eq.rhs)
    else if exp.$ne
      BinaryExp SymbolExp('!='), @_compileOne(exp.$ne.lhs), @_compileOne(exp.$ne.rhs)
    else if exp.$gt
      BinaryExp SymbolExp('>'), @_compileOne(exp.$gt.lhs), @_compileOne(exp.$gt.rhs)
    else if exp.$gte
      BinaryExp SymbolExp('>='), @_compileOne(exp.$gte.lhs), @_compileOne(exp.$gte.rhs)
    else if exp.$lt
      BinaryExp SymbolExp('<'), @_compileOne(exp.$lt.lhs), @_compileOne(exp.$lt.rhs)
    else if exp.$lte
      BinaryExp SymbolExp('<='), @_compileOne(exp.$lte.lhs), @_compileOne(exp.$lte.rhs)
    else if exp.$and
      BinaryExp SymbolExp('&&'), @_compileOne(exp.$and.lhs), @_compileOne(exp.$and.rhs)
    else if exp.$or
      BinaryExp SymbolExp('||'), @_compileOne(exp.$or.lhs), @_compileOne(exp.$or.rhs)
    else if exp.$not
      NotExp @_compileOne(exp.$not)
    else
      throw new Error("Check.compile:unknown_type: #{exp}")

# the goal of the compiler now is to be a decorator
# of the AST object.
# i.e. we want to compile out an AST, and then walk through AST to return the result.
class Compiler
  constructor: (exp) ->
    ast = AST.load exp
    @compile ast
  compile: (ast) ->
    key = @key ast
    if Compiler.prototype.hasOwnProperty(key)
      @[key] ast
  _integer: (ast) ->
    ast.value.toString()
  _float: (ast) ->
    ast.value.toString()
  _string: (ast) ->
    JSON.stringify ast.value
  _boolean: (ast) ->
    JSON.stringify ast.value
  _date: (ast) ->
    JSON.stringify ast.value.toISOString()
  _symbol: (ast) ->
    ast.value.toString()
  _regex: (ast) ->
    JSON.stringify ast.value.toString()
  _null: (ast) ->
    'null'
  _undefined: (ast) ->
    'undefined'
  _unary: (ast) ->
    '(' + @compile(ast.op) + @compile(ast.rhs) + ')'
  _binary: (ast) ->
    '(' + @compile(ast.lhs) + @compile(ast.op) + @compile(ast.rhs) + ')'
  _member: (ast) ->
    '(' + @compile(ast.head) + '.' + @compile(ast.key) + ')'

class SymbolExp
  constructor: (name) ->
    if not (@ instanceof SymbolExp)
      return new SymbolExp arguments...
    @name = name
  compile: () ->
    @name

class LiteralExp
  constructor: (value) ->
    if not (@ instanceof LiteralExp)
      return new LiteralExp arguments...
    @value = value
  compile: () ->
    if @value == undefined
      'undefined'
    else
      JSON.stringify(@value)

class BinaryExp
  constructor: (op, lhs, rhs) ->
    if not (@ instanceof BinaryExp)
      return new BinaryExp op, lhs, rhs
    @op = op
    @lhs = lhs
    @rhs = rhs
  compile: () ->
    "(" + @lhs.compile() + @op.compile() + @rhs.compile() + ")"

class NotExp
  constructor: (inner) ->
    if not (@ instanceof NotExp)
      return new NotExp inner
    @inner = inner
  compile: () ->
    "!(" + @inner.compile() + ")"

class RefExp
  constructor: (exp) ->
    if not (@ instanceof RefExp)
      return new RefExp exp
    @exp = exp
  compile: () ->
    @exp

class MemberExp
  constructor: (head, key) ->
    if not (@ instanceof MemberExp)
      return new MemberExp head, key
    @head = head
    @key = key
  compile: () ->
    @head.compile() + "[" + @key.compile() + "]"

class ProcedureExp
  constructor: (params, body) ->
    if not (@ instanceof ProcedureExp)
      return new ProcedureExp params, body
    @params = params
    @body = body
  compile: () ->
    params = (param.compile() for param in @params)
    body = @body.compile()
    new Function params, "return " + body

util._mixin Check,
  Symbol: SymbolExp
  Literal: LiteralExp
  Binary: BinaryExp
  Not: NotExp
  Ref: RefExp
  Member: MemberExp
  Procedure: ProcedureExp

class Check
  @compile: (exp) ->

module.exports = Check
