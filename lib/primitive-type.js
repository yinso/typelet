// Generated by CoffeeScript 1.10.0
(function() {
  var BooleanType, DateType, FloatType, IntegerType, NullType, PrimitiveType, RegExpType, StringType, Type, UnitType, util,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Type = require('./type');

  util = require('./util');

  PrimitiveType = (function(superClass) {
    extend(PrimitiveType, superClass);

    function PrimitiveType(name, options) {
      if (options == null) {
        options = {};
      }
      if (!(this instanceof PrimitiveType)) {
        return new PrimitiveType(name, options);
      }
      PrimitiveType.__super__.constructor.call(this);
      util._mixin(this, util._extend({
        name: name,
        typeID: Type.typeID++
      }, options));
      if (util._isFunction(options["instanceof"])) {
        Type.attachType(options["instanceof"], this);
      }
    }

    PrimitiveType.prototype.signature = function() {
      return "1:" + this.Type.typeID;
    };

    PrimitiveType.prototype.typeCategory = 'Primitive';

    PrimitiveType.prototype.isPrimitive = function() {
      return false;
    };

    PrimitiveType.prototype.isComposite = function() {
      return false;
    };

    PrimitiveType.prototype.isGeneric = function() {
      return false;
    };

    PrimitiveType.prototype.isSubTypeOf = function(type) {
      return false;
    };

    PrimitiveType.prototype.canAssignFrom = function(type) {
      return type === this;
    };

    PrimitiveType.prototype.isa = function(obj) {
      return typeof obj === this.name.toLowerCase();
    };

    PrimitiveType.prototype.equal = function(type) {
      return type === this;
    };

    PrimitiveType.prototype._toString = function(env) {
      return this.name;
    };

    return PrimitiveType;

  })(Type);

  UnitType = Type.Unit = PrimitiveType('Unit', {
    isa: function(obj) {
      return obj === void 0;
    }
  });

  NullType = Type.Null = PrimitiveType('Null', {
    isa: function(obj) {
      return obj === null;
    }
  });

  BooleanType = Type.Boolean = PrimitiveType('Boolean', {
    "instanceof": Boolean
  });

  IntegerType = Type.Integer = PrimitiveType('Integer', {
    isa: function(obj) {
      return typeof obj === 'number' && Math.floor(obj) === obj;
    }
  });

  FloatType = Type.Float = PrimitiveType('Float', {
    isa: function(obj) {
      return typeof obj === 'number';
    },
    "instanceof": Number
  });

  StringType = Type.String = PrimitiveType('String', {
    "instanceof": String
  });

  DateType = Type.Date = PrimitiveType('Date', {
    isa: function(obj) {
      return obj instanceof Date;
    },
    "instanceof": Date
  });

  RegExpType = Type.RegExp = PrimitiveType('RegExp', {
    isa: function(obj) {
      return obj instanceof RegExp;
    },
    "instanceof": RegExp
  });

  BooleanType.setConvert({
    type: StringType,
    converter: function(s) {
      if (s === 'true') {
        return true;
      } else if (s === 'false') {
        return false;
      } else {
        throw new errLib.InvalidValueError(BooleanType, s);
      }
    }
  });

  IntegerType.setConvert({
    type: StringType,
    converter: function(s) {
      var res;
      res = parseInt(s);
      if (res.toString() === s) {
        return res;
      } else {
        throw new errLib.InvalidValueError(IntegerType, s);
      }
    }
  });

  IntegerType.setConvert({
    type: FloatType,
    converter: function(i) {
      return Math.round(i);
    },
    explicit: true
  });

  FloatType.setConvert({
    type: StringType,
    converter: function(s) {
      var res;
      res = parseFloat(s);
      if (res.toString() === s) {
        return res;
      } else {
        throw new errLib.InvalidValueError(FloatType, s);
      }
    }
  });

  FloatType.setConvert({
    type: IntegerType,
    converter: function(i) {
      return i;
    }
  });

  DateType.setConvert({
    type: StringType,
    converter: function(s) {
      var ts;
      ts = Date.parse(s);
      if (!isNaN(ts)) {
        return new Date(ts);
      } else {
        throw new errLib.InvalidValueError(s, DateType);
      }
    }
  });

  DateType.setConvert({
    type: IntegerType,
    converter: function(i) {
      return new Date(i);
    }
  });

  StringType.setConvert({
    type: UnitType,
    converter: function() {
      return '';
    }
  });

  StringType.setConvert({
    type: NullType,
    converter: function() {
      return 'null';
    }
  });

  StringType.setConvert({
    type: IntegerType,
    converter: function(i) {
      return i.toString();
    }
  });

  StringType.setConvert({
    type: FloatType,
    converter: function(f) {
      return f.toString();
    }
  });

  StringType.setConvert({
    type: DateType,
    converter: function(d) {
      return d.toISOString();
    }
  });

  StringType.setConvert({
    type: BooleanType,
    converter: function(b) {
      return b.toString();
    }
  });

  util._mixin(Type, {
    makePrimitiveType: PrimitiveType,
    resolve: function(obj) {
      if (obj === void 0) {
        return UnitType;
      } else if (obj === null) {
        return NullType;
      } else if (typeof obj === 'number') {
        if (Math.floor(obj) === obj) {
          return IntegerType;
        } else {
          return FloatType;
        }
      } else if (obj.__$t instanceof Type) {
        return obj.__$t;
      } else if (obj.constructor.__$t instanceof Type) {
        return obj.constructor.__$t.resolve(obj, Type);
      } else {
        throw new Error("unknown_type: " + obj);
      }
    }
  });

  module.exports = PrimitiveType;

}).call(this);