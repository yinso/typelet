// Generated by CoffeeScript 1.10.0
(function() {
  var TypeBinder;

  TypeBinder = (function() {
    function TypeBinder() {
      this.binders = [];
    }

    TypeBinder.prototype.canAssignFrom = function(lhs, rhs) {
      var e, error;
      try {
        this.assignFrom(lhs, rhs);
        return true;
      } catch (error) {
        e = error;
        return false;
      }
    };

    TypeBinder.prototype.canAssignTo = function(lhs, rhs) {
      return this.canAssignFrom(rhs, lhs);
    };

    TypeBinder.prototype.assignFrom = function(lhs, rhs) {
      var binder, j, len, ref;
      ref = this.binders;
      for (j = 0, len = ref.length; j < len; j++) {
        binder = ref[j];
        if (binder.lhs === lhs) {
          if (binder.rhs.canAssignFrom(rhs)) {
            return;
          } else if (rhs.canAssignFrom(binder.rhs)) {
            binder.rhs = rhs;
          } else {
            throw new Error("TypeBinder.cannotRebind at " + i + ": " + lhs + " <- " + rhs);
          }
        } else {
          continue;
        }
        throw new Error("TypeBinder:bindingFailed at " + i + ": " + lhs + " <!= " + rhs);
      }
      return this.binders.push({
        lhs: lhs,
        rhs: rhs
      });
    };

    TypeBinder.prototype.assignTo = function(lhs, rhs) {
      return this.canAssignFrom(rhs, lhs);
    };

    return TypeBinder;

  })();

  module.exports = TypeBinder;

}).call(this);