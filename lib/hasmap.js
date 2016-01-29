// Generated by CoffeeScript 1.10.0
(function() {
  var HashMap, equal, hashCode;

  equal = function(x, y) {
    return x === y;
  };

  hashCode = function(str) {
    var char, hash, i, j, ref;
    hash = 0;
    if (str.length === 0) {
      return hash;
    }
    for (i = j = 0, ref = str.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return hash;
  };

  HashMap = (function() {
    HashMap.defaultOptions = {
      hashCode: hashCode,
      equal: function(k, v) {
        return k === v;
      }
    };

    function HashMap(options) {
      this.buckets = [];
      this.hashCode = options.hashCode || hashCode;
      this.equal = options.equal || equal;
    }

    HashMap.prototype.set = function(key, val) {
      var j, kv, len, ref;
      hashCode = this.hashCode(key);
      this.buckets[hashCode] = this.buckets[hashCode] || [];
      ref = this.buckets[hashCode];
      for (j = 0, len = ref.length; j < len; j++) {
        kv = ref[j];
        if (this.equal(kv.key, key)) {
          kv.val = val;
          return this;
        }
      }
      return this.bucket[hashCode].push({
        key: key,
        val: val
      });
    };

    HashMap.prototype._get = function(key) {
      var j, kv, len, ref;
      hashCode = this.hashCode(key);
      ref = this.buckets[hashCode] || [];
      for (j = 0, len = ref.length; j < len; j++) {
        kv = ref[j];
        if (this.equal(kv.key, key)) {
          return kv;
        }
      }
      return void 0;
    };

    HashMap.prototype.get = function(key) {
      var res;
      res = this._get(key);
      if (res) {
        return res.val;
      } else {
        return res;
      }
    };

    HashMap.prototype.has = function(key) {
      var res;
      res = this._get(key);
      return res instanceof Object;
    };

    HashMap.prototype["delete"] = function(key) {
      var count, i, j, kv, len, ref;
      hashCode = this.hashCode(key);
      if (!this.buckets.hasOwnProperty(hashCode)) {
        return false;
      }
      count = -1;
      ref = this.buckets[hashCode];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        kv = ref[i];
        if (this.equal(kv.key, key)) {
          count = i;
        }
      }
      if (count !== -1) {
        this.buckets[hashCode].splice(count, 1);
        return true;
      } else {
        return false;
      }
    };

    HashMap.prototype.keys = function() {
      var bucket, j, key, len, ref, ref1, res, val;
      res = [];
      ref = this.buckets || [];
      for (hashCode in ref) {
        bucket = ref[hashCode];
        for (j = 0, len = bucket.length; j < len; j++) {
          ref1 = bucket[j], key = ref1.key, val = ref1.val;
          res.push(key);
        }
      }
      return res;
    };

    HashMap.prototype.values = function() {
      var bucket, j, key, len, ref, ref1, res, val;
      res = [];
      ref = this.buckets || [];
      for (hashCode in ref) {
        bucket = ref[hashCode];
        for (j = 0, len = bucket.length; j < len; j++) {
          ref1 = bucket[j], key = ref1.key, val = ref1.val;
          res.push(val);
        }
      }
      return res;
    };

    return HashMap;

  })();

  module.exports = HashMap;

}).call(this);