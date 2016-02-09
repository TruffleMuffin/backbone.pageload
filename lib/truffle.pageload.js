(function() {
  'use strict';

  var globals = typeof window === 'undefined' ? global : window;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = ({}).hasOwnProperty;

  var endsWith = function(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
  };

  var _cmp = 'components/';
  var unalias = function(alias, loaderPath) {
    var start = 0;
    if (loaderPath) {
      if (loaderPath.indexOf(_cmp) === 0) {
        start = _cmp.length;
      }
      if (loaderPath.indexOf('/', start) > 0) {
        loaderPath = loaderPath.substring(start, loaderPath.indexOf('/', start));
      }
    }
    var result = aliases[alias + '/index.js'] || aliases[loaderPath + '/deps/' + alias + '/index.js'];
    if (result) {
      return _cmp + result.substring(0, result.length - '.js'.length);
    }
    return alias;
  };

  var _reg = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (_reg.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';
    path = unalias(name, loaderPath);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has.call(cache, dirIndex)) return cache[dirIndex].exports;
    if (has.call(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  require.register = require.define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  require.list = function() {
    var result = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  require.brunch = true;
  require._cache = cache;
  globals.require = require;
})();
require.register("truffle.pageload/application", function(exports, require, module) {
var Application;

module.exports = Application = (function() {
  function Application() {}

  Application.prototype._defaultConfiguration = function() {
    return {
      callList: [],
      done: function() {},
      progress: function() {}
    };
  };

  Application.prototype.initialize = function(options) {
    var name, property;
    if (options == null) {
      options = {};
    }
    this.configuration = this._defaultConfiguration();
    for (name in options) {
      property = options[name];
      this.configuration[name] = property;
    }
    if (!this.supportedFeatures()) {
      this.configuration.done();
      return;
    }
    this.events = new (require('./events'))(this);
    this.tracking = {
      totalRequests: this.configuration.callList.length,
      completedRequests: 0,
      startedRequests: 0
    };
    this.events.on('request:start', this.requestStart);
    this.events.on('request:complete', this.requestComplete);
    this.interceptor = new (require('./interceptor'))({
      events: this.events
    });
    return this.interceptor.attach();
  };

  Application.prototype.supportedFeatures = function() {
    if (typeof XMLHttpRequest === "undefined" || XMLHttpRequest === null) {
      return false;
    }
    if (XMLHttpRequest.prototype.addEventListener == null) {
      return false;
    }
    if (XMLHttpRequest.prototype.removeEventListener == null) {
      return false;
    }
    return true;
  };

  Application.prototype.requestStart = function(options) {
    if (this.matchCall(options.url)) {
      return this.open();
    }
  };

  Application.prototype.requestComplete = function(options) {
    if (this.matchCall(options.url)) {
      return this.complete();
    }
  };

  Application.prototype.open = function() {
    this.tracking.startedRequests += 1;
    return this.updateTracking();
  };

  Application.prototype.complete = function() {
    this.tracking.completedRequests += 1;
    return this.updateTracking();
  };

  Application.prototype.updateTracking = function() {
    var progress;
    progress = 0;
    if (this.tracking.startedRequests > this.tracking.totalRequests) {
      this.tracking.totalRequests = this.tracking.startedRequests;
    }
    if (this.tracking.startedRequests > 0) {
      progress += Math.round(((this.tracking.startedRequests / this.tracking.totalRequests) * 100) / 2);
    }
    if (this.tracking.completedRequests > 0) {
      progress += Math.round(((this.tracking.completedRequests / this.tracking.totalRequests) * 100) / 2);
    }
    if (progress > 0) {
      this.configuration.progress(progress);
    }
    if (this.tracking.totalRequests === this.tracking.completedRequests) {
      return this.done();
    }
  };

  Application.prototype.done = function() {
    this.interceptor.detach();
    this.events.off('request:complete');
    return this.configuration.done();
  };

  Application.prototype.matchCall = function(url) {
    var item, match, _i, _len, _ref;
    match = false;
    _ref = this.configuration.callList;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (url.toLowerCase().match(item) != null) {
        match = true;
        break;
      }
    }
    return match;
  };

  return Application;

})();

});

require.register("truffle.pageload/events", function(exports, require, module) {
var Events;

module.exports = Events = (function() {
  function Events(context) {
    this.listeners = {};
    this.context = context != null ? context : this;
  }

  Events.prototype.trigger = function(name, args) {
    var callback, _i, _len, _ref, _results;
    if (this.listeners[name] != null) {
      _ref = this.listeners[name];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.call(this.context, args));
      }
      return _results;
    }
  };

  Events.prototype.off = function(name, callback) {
    var fn, index, listeners, _i, _len, _ref;
    if (this.listeners[name] == null) {
      return;
    }
    if (callback != null) {
      listeners = [];
      _ref = this.listeners[name];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        fn = _ref[index];
        if (fn !== callback) {
          listeners.push(fn);
        }
      }
      return this.listeners[name] = listeners;
    } else {
      return delete this.listeners[name];
    }
  };

  Events.prototype.on = function(name, callback) {
    var _base;
    if ((_base = this.listeners)[name] == null) {
      _base[name] = [];
    }
    return this.listeners[name].push(callback);
  };

  return Events;

})();

});

require.register("truffle.pageload/interceptor", function(exports, require, module) {
var Interceptor,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = Interceptor = (function() {
  var Request, Wrapper;

  Request = XMLHttpRequest;

  function Interceptor(options) {
    var _ref,
      _this = this;
    if (options == null) {
      options = {};
    }
    this.events = (_ref = options.events) != null ? _ref : new (require('./events'))();
    this.requests = {};
    this.events.on('request:complete', function(options) {
      if (_this.requests) {
        return delete _this.requests[options.id];
      }
    });
  }

  Interceptor.prototype.attach = function() {
    var _this = this;
    return window.XMLHttpRequest = function(options) {
      var request;
      request = new Request(options);
      _this.replaceOpen(request);
      return request;
    };
  };

  Interceptor.prototype.detach = function() {
    var wrapper;
    for (wrapper in this.requests) {
      this.requests[wrapper].destroy();
    }
    delete this.requests;
    return window.XMLHttpRequest = Request;
  };

  Interceptor.prototype.replaceOpen = function(request) {
    var open,
      _this = this;
    open = request.open;
    return request.open = function(method, url) {
      var id;
      if (method == null) {
        method = '';
      }
      if (url == null) {
        url = '';
      }
      id = method + url + '@' + (new Date()).getTime();
      _this.requests[id] = new Wrapper({
        id: id,
        url: url,
        events: _this.events,
        request: request
      });
      _this.events.trigger('request:start', {
        url: url,
        id: id
      });
      return open.apply(request, arguments);
    };
  };

  Wrapper = (function() {
    function Wrapper(options) {
      var name, _i, _len, _ref;
      if (options == null) {
        options = {};
      }
      this.requestComplete = __bind(this.requestComplete, this);
      this.request = options.request;
      this.events = options.events;
      this.id = options.id;
      this.url = options.url;
      _ref = ['load', 'abort', 'timeout', 'error'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this.request.addEventListener(name, this.requestComplete);
      }
    }

    Wrapper.prototype.destroy = function() {
      var name, _i, _len, _ref, _results;
      _ref = ['load', 'abort', 'timeout', 'error'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        _results.push(this.request.removeEventListener(name, this.requestComplete));
      }
      return _results;
    };

    Wrapper.prototype.requestComplete = function() {
      return this.events.trigger('request:complete', {
        id: this.id,
        url: this.url
      });
    };

    return Wrapper;

  })();

  return Interceptor;

}).call(this);

});

