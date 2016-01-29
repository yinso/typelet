// Generated by CoffeeScript 1.10.0
(function() {
  var AnyType, ArrayType, ObjectType, ScalarType, Type, TypeSpace;

  Type = require('./type');

  ScalarType = require('./scalar-type');

  ArrayType = require('./array-type');

  ObjectType = require('./object-type');

  AnyType = require('./any-type');

  TypeSpace = (function() {
    function TypeSpace() {}

    TypeSpace.prototype.resolve = function(val) {
      var type;
      if (val === void 0) {
        return ScalarType.Unit;
      } else if (val === null) {
        return ScalarType.Null;
      } else if (typeof val === 'number') {
        if (val % 1 === 0) {
          return ScalarType.Integer;
        } else {
          return ScalarType.Float;
        }
      } else if (val.constructor.__$t) {
        type = val.constructor.__$t;
        if (type.isConstructor) {
          return type.resolve(val, this);
        } else {
          return type;
        }
      } else {
        throw new Error("unknown_type: " + val);
      }
    };

    return TypeSpace;

  })();

  Boolean.__$t = ScalarType.Boolean;

  Number.__$t = ScalarType.Float;

  String.__$t = ScalarType.String;

  Date.__$t = ScalarType.Date;

  Array.__$t = ArrayType;

  Object.__$t = ObjectType;

  module.exports = TypeSpace;

}).call(this);