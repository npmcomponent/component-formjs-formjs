module.exports = (FormJS) ->
	###
	Type: select
	Notes: A dropdown <select> element
	Options:
		_options: a hashmap of value and labels
		_multiple: boolean wether the "multiple" attribute should be set
	###
	FormJS.registerType 'select', (options) ->
		if options._multiple and (options._multiple is !!options._multiple)
			options._multiple = 'multiple'
		else
			delete options._multiple

		tag = jQuery('<select />')
		for val, label of options._options
			opt = jQuery('<option />').attr('value', val).html(label)
			if val is options._value
				opt.attr('selected', 'selected')
			opt.appendTo tag

		@applyAttributes tag, options
