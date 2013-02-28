// Generated by CoffeeScript 1.5.0
(function() {
  var FormJS,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  FormJS = (function() {

    FormJS.types = {};

    FormJS.used_ids = [];

    function FormJS(obj, target) {
      if (obj._method) {
        obj._type = 'form';
      }
      this.dom = this.render(obj);
      if (target) {
        this.dom.appendTo(target);
      }
    }

    FormJS.prototype._filter = function(obj, match) {
      var key, ret, val;
      ret = {};
      for (key in obj) {
        val = obj[key];
        if (key.match(match)) {
          ret[key] = val;
        }
      }
      return ret;
    };

    FormJS.prototype.getAttributes = function(obj) {
      return this._filter(obj, /^_/);
    };

    FormJS.prototype.getChildren = function(obj) {
      var child, children, name;
      children = this._filter(obj, /^[a-z0-9]/i);
      for (name in children) {
        child = children[name];
        children[name]._parent = obj;
        children[name]._name = child._name || name;
      }
      return children;
    };

    FormJS.prototype.render = function(obj) {
      var children, element, name, val;
      element = this._render(obj);
      if (!obj._nowrap) {
        element = this.label(this._wrap(element), obj);
      }
      children = this.getChildren(obj);
      for (name in children) {
        val = children[name];
        this.render(val).appendTo(element);
      }
      return element;
    };

    FormJS.prototype._render = function(obj, type_override) {
      var fn, type;
      if (type_override == null) {
        type_override = null;
      }
      type = type_override || obj._type;
      fn = FormJS.types[type] || FormJS.types["default"];
      return fn.call(this, obj);
    };

    FormJS.prototype._generate_id = function(obj) {
      var id, ids;
      if (!obj._id) {
        id = "form-" + obj._name;
        ids = FormJS.used_ids;
        while (__indexOf.call(FormJS.used_ids, id) >= 0) {
          id = "form-" + obj._name + "-" + (Math.random());
        }
        FormJS.used_ids.push(id);
        return obj._id = id;
      }
    };

    FormJS.prototype.label = function(ele, obj) {
      var method, o, _ref;
      if (obj._description) {
        ele.append(this._render({
          _type: 'description',
          _description: obj._description
        }));
      }
      if (obj._label) {
        method = (obj._label_position === 'after' ? 'append' : 'prepend');
        this._generate_id(obj);
        o = obj._label;
        if (typeof obj._label !== 'object') {
          o = {
            _label: obj._label
          };
        }
        o._type = 'label';
        if ((_ref = o._for) == null) {
          o._for = obj.id;
        }
        ele[method](this._render(o));
      }
      return ele;
    };

    FormJS.prototype.applyAttributes = function(ele, _attrs, skip) {
      var attrs, cb, ev, events, k, v, _ref;
      if (skip == null) {
        skip = [];
      }
      if (!_attrs) {
        throw 'No attrs';
      }
      ele.data('form-config', _attrs);
      attrs = ele._attributes || {};
      skip = skip.concat(['_nowrap', '_attributes', '_parent', '_events', '_description', '_text', '_label', '_options']);
      _ref = this.getAttributes(_attrs);
      for (k in _ref) {
        v = _ref[k];
        if (!(__indexOf.call(skip, k) < 0 && typeof v !== 'function')) {
          continue;
        }
        k = k.substr(1);
        if (attrs[k] == null) {
          attrs[k] = v;
        }
      }
      console.log('attrs', attrs);
      ele.attr(attrs);
      if (events = _attrs._events) {
        for (ev in events) {
          cb = events[ev];
          if (!(ev)) {
            continue;
          }
          if (cb.forEach == null) {
            cb = [cb];
          }
          if (ev === 'submit' && events.validate) {
            cb.unshift(events.validate);
          }
          if (ev === 'validate') {
            if (!events.submit) {
              ev = 'submit';
            } else {
              continue;
            }
          }
          ele[ev](function() {
            var _cb, _i, _len;
            for (_i = 0, _len = cb.length; _i < _len; _i++) {
              _cb = cb[_i];
              if (!_cb.apply(this, arguments)) {
                return false;
              }
            }
          });
        }
      }
      return ele;
    };

    FormJS.prototype._wrap = function(ele) {
      return jQuery(ele).wrap('<div />').parent().addClass('form-row');
    };

    FormJS.registerType = FormJS.prototype.registerType = function(type, callback) {
      return FormJS.types[type] = callback;
    };

    return FormJS;

  })();

  /*
  Type: form
  */


  FormJS.registerType('form', function(options) {
    options._nowrap = true;
    options._attributes = {
      type: false
    };
    return this.applyAttributes(jQuery('<form />'), options);
  });

  /*
  Type: fieldset
  Options:
  	legend: text to appear in a <legend> tag as the first child of the fieldset
  */


  FormJS.registerType('fieldset', function(options) {
    var tag;
    options._nowrap = true;
    tag = this.applyAttributes(jQuery('<fieldset>'), options);
    if (options._legend) {
      tag.removeAttr('legend');
      jQuery('<legend>').html(options._legend).appendTo(tag);
    }
    return tag;
  });

  /*
  Type: group
  Notes: wraps a set of elements without using a fieldset
  */


  FormJS.registerType('group', function(options) {
    options._nowrap = true;
    return this.applyAttributes(jQuery('<div />'), options);
  });

  /*
  Type: label
  Notes: Mostly used internally to add labels to existing elements
  Options:
  	label/text: The text in the label
  	for: the "for" attribute
  */


  FormJS.registerType('label', function(options) {
    var _ref;
    options._nowrap = true;
    if ((_ref = options._label) == null) {
      options._label = options._text;
    }
    return this.applyAttributes(jQuery('<label />').text(options._label), options);
  });

  /*
  Type: description
  Notes: Mostly used internally to add descriptions to an existing element
  Options:
  	description/text: text to appear in the description
  */


  FormJS.registerType('description', function(options) {
    var _ref;
    options._nowrap = true;
    if ((_ref = options._description) == null) {
      options._description = options._text;
    }
    return this.applyAttributes(jQuery('<span />').addClass('description').html(options._description), options);
  });

  /*
  Type: markup
  Notes: Used to display markup, ie white-space: pre
  Options:
  	markup/text: text to appear inside
  */


  FormJS.registerType('markup', function(options) {
    var _ref;
    if ((_ref = options._markup) == null) {
      options._markup = options._text;
    }
    return this.applyAttributes(jQuery('<div />').html(options._markup), options);
  });

  /*
  Type: hidden
  Notes: A type=hidden input
  */


  FormJS.registerType('hidden', function(options) {
    options._nowrap = true;
    return FormJS.types["default"].call(this, options);
  });

  /*
  Type: textarea
  Notes: A <textarea /> input
  Options: _cols, _rows
  */


  FormJS.registerType('textarea', function(options) {
    var tag;
    tag = jQuery('<textarea />').html(options._value);
    delete options._value;
    return this.applyAttributes(tag, options);
  });

  /*
  Type: select
  Notes: A dropdown <select> element
  Options:
  	_options: a hashmap of value and labels
  	_multiple: boolean wether the "multiple" attribute should be set
  */


  FormJS.registerType('select', function(options) {
    var label, opt, tag, val, _ref;
    if (options._multiple && (options._multiple === !!options._multiple)) {
      options._multiple = 'multiple';
    } else {
      delete options._multiple;
    }
    tag = jQuery('<select />');
    _ref = options._options;
    for (val in _ref) {
      label = _ref[val];
      opt = jQuery('<option />').attr('value', val).html(label);
      if (val === options._value) {
        opt.attr('selected', 'selected');
      }
      opt.appendTo(tag);
    }
    return this.applyAttributes(tag, options);
  });

  /*
  Type: button
  Notes: A <button> tag
  Options: _value
  */


  FormJS.registerType('button', function(options) {
    return this.applyAttributes(jQuery('<button />').html(options._value), options);
  });

  /*
  Type: radio, checkbox
  Notes: defined purely to add a default "label_position" to radio/checkbox elements
  */


  FormJS.registerType('radio', function(options) {
    var _ref;
    if ((_ref = options._label_position) == null) {
      options._label_position = 'after';
    }
    return FormJS.types["default"].call(this, options, ['_label_position']);
  });

  FormJS.registerType('checkbox', function(options) {
    var _ref;
    if ((_ref = options._label_position) == null) {
      options._label_position = 'after';
    }
    return FormJS.types["default"].call(this, options, ['_label_position']);
  });

  /*
  Type: radios, checkboxes
  Notes: a list of radio/checkbox elements
  Options:
  	_options: a hashmap of value/label
  */


  FormJS.registerType('radios', function(options) {
    options._type = 'radio';
    return FormJS.types.options.call(this, options);
  });

  FormJS.registerType('checkboxes', function(options) {
    options._type = 'checkbox';
    return FormJS.types.options.call(this, options);
  });

  FormJS.registerType('options', function(options) {
    var label, o, value, wrap, _ref;
    wrap = jQuery('<div />');
    _ref = options._options;
    for (value in _ref) {
      label = _ref[value];
      o = {
        _type: options._type,
        _name: options._name,
        _value: value,
        _label: label
      };
      wrap.append(this.render(o));
    }
    return this.applyAttributes(wrap, options);
  });

  /*
  Type: default
  Notes: fallback used to implement text/radio/submit etc <input type=".." without strictly defining them
  */


  FormJS.registerType('default', function(options) {
    return this.applyAttributes(jQuery('<input />'), options);
  });

  if (typeof module !== "undefined" && module !== null) {
    module.exports = FormJS;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.FormJS = FormJS;
  }

}).call(this);
