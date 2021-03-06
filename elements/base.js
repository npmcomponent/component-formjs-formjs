// Generated by CoffeeScript 1.6.1
(function() {

  module.exports = function(FormJS) {
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
    	Type: default
    	Notes: fallback used to implement text/radio/submit etc <input type=".." without strictly defining them
    */

    FormJS.registerType('default', function(options, skip) {
      if (skip == null) {
        skip = [];
      }
      return this.applyAttributes(jQuery('<input />'), options, skip);
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
      return this.applyAttributes(jQuery('<div />').html(options._markup), options, ['markup', 'text']);
    });
    /*
    	Type: tag
    	Notes: Render a generic HTML tag
    	Options:
    		tag: the tag type
    		html/content: inserted as html
    		text: inserted as stripped text
    */

    FormJS.registerType('tag', function(options) {
      var tag;
      tag = jQuery("<" + options._tag + " />");
      if (options._html || options._content) {
        tag.html(options._html || options._content);
      }
      if (options._text) {
        tag.text(options._text);
      }
      return this.applyAttributes(tag, options, ['html', 'text', 'tag']);
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

    return FormJS.registerType('textarea', function(options) {
      var tag;
      tag = jQuery('<textarea />').html(options._value);
      delete options._value;
      return this.applyAttributes(tag, options);
    });
  };

}).call(this);
