// Generated by CoffeeScript 1.10.0
(function() {
  var Environment;

  Environment = (function() {
    function Environment(prev) {
      this.prev = prev != null ? prev : null;
      if (!(this instanceof Environment)) {
        return new Environment(this.prev);
      }
      this.inner = {};
    }

    Environment.prototype.has = function(name) {
      if (this.inner.hasOwnProperty(name)) {
        return true;
      } else if (this.prev) {
        return this.prev.has(name);
      } else {
        return false;
      }
    };

    Environment.prototype.get = function(name) {
      if (this.inner.hasOwnProperty(name)) {
        return this.inner[name];
      } else if (this.prev) {
        return this.prev.get(name);
      } else {
        throw new Error("unknown_type: " + name);
      }
    };

    return Environment;

  })();

  module.exports = Environment;

}).call(this);