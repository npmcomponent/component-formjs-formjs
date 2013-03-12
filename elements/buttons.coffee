module.exports = (FormJS) ->
	###
	Type: button
	Notes: A <button> tag
	Options: _value
	###
	FormJS.registerType 'button', (options) ->
		@applyAttributes jQuery('<button />').html(options._value), options

	###
	Type: cancel
	Notes: A <button> that, when clicked, fires the _cancel event or resets the form
	Options: _value
	###
	FormJS.registerType 'cancel', (options) ->
		button = @applyAttributes jQuery('<input />'), options
		button.addClass 'cancel'
		button.attr 'type', 'reset'

		button.click (e) ->
			$self = $ @
			form = $self.data 'form-config'
			item = $self.data 'item-config'

			if form._events and form._events.cancel
				form._events.cancel item
			else
				$self.parents('form').reset()

			e.stopPropagation()
			e.preventDefault()
			return false

		button

