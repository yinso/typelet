# the key thing about constraints is that it's important to ensure
# the particular type can be used.

objHelper = require './object-helper'
HashMap = require './hashmap'
Ref = require './ref'

class Constraint
  @compile: (obj) ->
#    if obj instanceof Constraint
#      obj
#    else if instanceof Object
      
  check: (v) -> true

Constraint.And = class AndConstraint extends Constraint
  @key: '$and'
  constructor: (@list = []) ->
    for item in @list
      if not (item instanceof Constriant)
        throw new Error("$and_must_take_constraint")
  check: (v) ->
    for cons in @list
      if not cons.check(v)
        return false
    true

Constraint.Equal = class EqualConstraint extends Constraint
  constructor: (@inner) ->
  check: (v) ->
    objHelper.equal(v, @inner)

Constraint.Enum = class EnumConstraint extends Constraint
  constructor: (@list = []) ->
  check: (v) ->
    for item in @list
      if objHelper.equal(v, item)
        return true
    false

Constraint.Greater = class GreaterConstraint extends Constraint
  constructor: (@min, @include = true) ->
  check: (v) ->
    objHelper.greater(v, @min, @include)

Constraint.Less = class LessConstraint extends Constraint
  constructor: (@max, @include = true) ->
  check: (v) ->
    objHelper.less v, @max, @include

class NotConstraint extends Constraint
  constructor: (@inner) ->
    if not (@inner instanceof Constraint)
      throw new Error("not_must_take_constraint")
  check: (v) ->
    not @inner.check(v)

Constraint.MultipleOf = class MultipleOf extends Constraint
  constructor: (@value) ->
  check: (v) ->
    v / @value % 1 == 0 

Constraint.Or = class OrConstraint extends Constraint
  constructor: (@list = []) ->
    for item in @list
      if not (item instanceof Constriant)
        throw new Error("or_must_take_constraint")
  check: (v) ->
    for cons in @list
      if cons.check(v)
        return true
    false

Constraint.Pattern = class PatternConstraint extends Constraint
  constructor: (@pattern) ->
    if not (@pattern instanceof RegEx)
      throw new Error("$pattern_must_taken_regex")
  check: (v) ->
    v.match @pattern

Constraint.Unique = class UniqueConstraint extends Constraint
  check: (ary) ->
    map = new HashMap()
    for item, i in ary
      if map.has item
        return false
      else
        map.set item, item
    true

module.exports = Constraint

