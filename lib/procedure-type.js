// Generated by CoffeeScript 1.10.0
(function() {
  var ProcedureType, PropertyType, Type,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Type = require('./type');

  PropertyType = require('./property-type');

  ProcedureType = (function(superClass) {
    extend(ProcedureType, superClass);

    ProcedureType.prototype["native"] = function(proc, type) {
      proc.__$t = type;
      return proc;
    };

    function ProcedureType(_arguments, _return, options) {
      this["arguments"] = _arguments;
      this["return"] = _return;
      this.options = options;
      ProcedureType.__super__.constructor.call(this, this.options);
    }

    ProcedureType.prototype.signature = function() {
      var args, type;
      args = (function() {
        var j, len, ref, results;
        ref = this["arguments"].concat([this["return"]]);
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          type = ref[j];
          results.push(type.signature());
        }
        return results;
      }).call(this);
      return args.join('->');
    };

    ProcedureType.prototype.isGeneric = function() {
      var arg, j, len, ref;
      ref = this["arguments"];
      for (j = 0, len = ref.length; j < len; j++) {
        arg = ref[j];
        if (arg.isGeneric()) {
          return true;
        }
      }
      return this["return"].isGeneric();
    };

    ProcedureType.prototype.isa = function(proc) {
      if (this.outerIsa(proc)) {
        if (proc.__$t && this.equal(proc.__$t)) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    };

    ProcedureType.prototype.outerIsa = function(proc) {
      return typeof proc === 'function' || (proc instanceof Function);
    };

    ProcedureType.prototype.resolveType = function(proc) {
      throw new Error("procedure_type_resolve_unsupported");
    };

    ProcedureType.prototype.convert = function(x) {
      throw new Error("procedure_type_convert_unsupported");
    };

    ProcedureType.prototype._specialize = function(args) {
      var normalized;
      normalized = this.merge(args);
      return new ProcedureType(normalized, this["return"], this.options);
    };

    ProcedureType.prototype.merge = function(args) {
      var i, item, j, len, results;
      if (args.length !== this["arguments"].length) {
        throw new Error("procedure_type_merge: not_same_length");
      }
      results = [];
      for (i = j = 0, len = args.length; j < len; i = ++j) {
        item = args[i];
        if (item instanceof PropertyType) {
          results.push(item);
        } else {
          results.push(this["arguments"][i]);
        }
      }
      return results;
    };

    return ProcedureType;

  })(Type);

  module.exports = FunctionType;

}).call(this);