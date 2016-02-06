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
      callList: []
    };
  };

  Application.prototype.initialize = function(options) {
    var name, property;
    if (options == null) {
      options = {};
    }
    this.configuration = this._defaultConfiguration();
    for (property in options) {
      name = options[property];
      this.configuration[name] = property;
    }
    this.events = new (require('./events'))();
    this.events.on('request:start', this.requestStart);
    this.events.on('request:complete', this.requestComplete);
    this.interceptor = new (require('./interceptor'))({
      events: this.events
    });
    return this.interceptor.attach();
  };

  Application.prototype.requestStart = function(options) {
    return console.log(options);
  };

  Application.prototype.requestComplete = function(options) {
    return console.log(options);
  };

  return Application;

})();

});

require.register("truffle.pageload/events", function(exports, require, module) {
var Events;

module.exports = Events = (function() {
  function Events() {
    this.listeners = {};
  }

  Events.prototype.trigger = function(name, args) {
    var callback, _i, _len, _ref, _results;
    if (this.listeners[name] != null) {
      _ref = this.listeners[name];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.call(this, args));
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
      return delete _this.requests[options.id];
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
    var XMLHttpRequest;
    return XMLHttpRequest = Request;
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
        events: _this.events,
        request: request
      });
      _this.events.trigger('request:start', {
        url: url,
        method: method,
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
      _ref = ['load', 'abort', 'timeout', 'error'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this.request.addEventListener(name, this.requestComplete);
      }
    }

    Wrapper.prototype.requestComplete = function() {
      return this.events.trigger('request:complete', {
        id: this.id
      });
    };

    return Wrapper;

  })();

  return Interceptor;

}).call(this);

});

