module.exports = (FormJS) ->
	###
	Type: radio, checkbox
	Notes: defined purely to add a default "label_position" to radio/checkbox elements
	###
	FormJS.registerType 'radio', (options) ->
		options._label_position ?= 'after'
		FormJS.types.default.call this, options, ['_label_position']

	FormJS.registerType 'checkbox', (options) ->
		options._label_position ?= 'after'
		FormJS.types.default.call this, options, ['_label_position']

	###
	Type: radios, checkboxes
	Notes: a list of radio/checkbox elements
	Options:
		_options: a hashmap of value/label
	###
	FormJS.registerType 'radios', (options) ->
		options._type = 'radio'
		FormJS.types.options.call this, options

	FormJS.registerType 'checkboxes', (options) ->
		options._type = 'checkbox'
		FormJS.types.options.call this, options

	FormJS.registerType 'options', (options) ->
		wrap = jQuery('<div />')
		for value, label of options._options
			o =
				_type: options._type
				_name: options._name
				_value: value
				_label: label

			if options._required
				o._required = 'required'

			wrap.append @render o

		options._type = 'options'
		@applyAttributes wrap, options, ['type', 'required', 'target']
