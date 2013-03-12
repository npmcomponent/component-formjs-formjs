// Generated by CoffeeScript 1.6.1
(function() {

  module.exports = function(FormJS) {
    /*
    	Type: button
    	Notes: A <button> tag
    	Options: _value
    */
    FormJS.registerType('button', function(options) {
      return this.applyAttributes(jQuery('<button />').html(options._value), options);
    });
    /*
    	Type: cancel
    	Notes: A <button> that, when clicked, fires the _cancel event or resets the form
    	Options: _value
    */

    return FormJS.registerType('cancel', function(options) {
      var button;
      button = this.applyAttributes(jQuery('<input />'), options);
      button.addClass('cancel');
      button.attr('type', 'reset');
      button.click(function(e) {
        var $self, form, item;
        $self = $(this);
        form = $self.data('form-config');
        item = $self.data('item-config');
        if (form._events && form._events.cancel) {
          form._events.cancel(item);
        } else {
          $self.parents('form').reset();
        }
        e.stopPropagation();
        e.preventDefault();
        return false;
      });
      return button;
    });
  };

}).call(this);
