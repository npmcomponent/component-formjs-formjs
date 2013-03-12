module.exports = (FormJS) ->
	###
	Type: form
	###
	FormJS.registerType 'form', (options) ->
		options._nowrap = true
		options._attributes = {type: false}
		@applyAttributes jQuery('<form />'), options

	###
	Type: fieldset
	Options:
		legend: text to appear in a <legend> tag as the first child of the fieldset
	###
	FormJS.registerType 'fieldset', (options) ->
		options._nowrap = true

		tag = @applyAttributes jQuery('<fieldset>'), options
		if options._legend
			tag.removeAttr 'legend'
			jQuery('<legend>').html(options._legend).appendTo tag

		tag	

	###
	Type: group
	Notes: wraps a set of elements without using a fieldset
	###
	FormJS.registerType 'group', (options) ->
		options._nowrap = true
		@applyAttributes jQuery('<div />'), options

	###
	Type: label
	Notes: Mostly used internally to add labels to existing elements
	Options:
		label/text: The text in the label
		for: the "for" attribute
	###
	FormJS.registerType 'label', (options) ->
		options._nowrap = true
		options._label ?= options._text
		@applyAttributes jQuery('<label />').text(options._label), options

	###
	Type: description
	Notes: Mostly used internally to add descriptions to an existing element
	Options:
		description/text: text to appear in the description
	###
	FormJS.registerType 'description', (options) ->
		options._nowrap = true
		options._description ?= options._text
		@applyAttributes jQuery('<span />').addClass('description').html(options._description), options

	###
	Type: default
	Notes: fallback used to implement text/radio/submit etc <input type=".." without strictly defining them
	###
	FormJS.registerType 'default', (options, skip = []) ->
		@applyAttributes jQuery('<input />'), options, skip

	###
	Type: markup
	Notes: Used to display markup, ie white-space: pre
	Options:
		markup/text: text to appear inside
	###
	FormJS.registerType 'markup', (options) ->
		options._markup ?= options._text
		@applyAttributes jQuery('<div />').html(options._markup), options, ['markup', 'text']

	###
	Type: hidden
	Notes: A type=hidden input
	###
	FormJS.registerType 'hidden', (options) ->
		options._nowrap = true
		FormJS.types.default.call this, options

	###
	Type: textarea
	Notes: A <textarea /> input
	Options: _cols, _rows
	###
	FormJS.registerType 'textarea', (options) ->
		tag = jQuery('<textarea />').html options._value
		delete options._value
		@applyAttributes tag, options

