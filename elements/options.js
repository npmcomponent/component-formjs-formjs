// Generated by CoffeeScript 1.6.1
(function() {

  module.exports = function(FormJS) {
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
    return FormJS.registerType('options', function(options) {
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
        if (options._required) {
          o._required = 'required';
        }
        wrap.append(this.render(o));
      }
      options._type = 'options';
      return this.applyAttributes(wrap, options, ['type', 'required', 'target']);
    });
  };

}).call(this);