class FormJS

	@types = {}
	@used_ids = []

	constructor: (obj, target) ->
		if obj._method
			obj._type = 'form'

		@dom = @render obj

		if target
			@dom.appendTo target

	_filter: (obj, match) ->
		ret = {}
		for key, val of obj when key.match match
			ret[key] = val
		ret

	getAttributes: (obj) ->
		@_filter obj, /^_/

	getChildren: (obj) ->
		children = @_filter obj, /^[a-z0-9]/i
		for name, child of children
			children[name]._parent = obj
			children[name]._name = child._name or name 
		children

	render: (obj) ->
		element = @_render obj
		if not obj._nowrap
			element = @label (@_wrap element), obj

		children = @getChildren obj
		for name, val of children
			@render(val).appendTo element

		element

	_render: (obj, type_override = null) ->
		type = type_override or obj._type
		fn = FormJS.types[type] or FormJS.types.default
		
		fn.call this, obj

	_generate_id: (obj) ->
		if not obj._id
			id = "form-#{obj._name}"
			ids = FormJS.used_ids
			while id in FormJS.used_ids
				id = "form-#{obj._name}-#{Math.random()}"
			FormJS.used_ids.push id
			obj._id = id

	label: (ele, obj) ->
		if obj._description
			ele.append @_render({_type: 'description', _description: obj._description})

		if obj._label
			method = (if obj._label_position is 'after' then 'append' else 'prepend')
			@_generate_id obj
			o = obj._label
			if typeof obj._label isnt 'object'
				o = {_label: obj._label}
			o._type = 'label'
			o._for ?= obj.id
			ele[method] @_render o

		return ele

	applyAttributes: (ele, _attrs, skip = []) ->
		if not _attrs
			throw 'No attrs'

		ele.data('form-config', _attrs)

		# need to transform the attrs to remove the _
		attrs = ele._attributes or {}
		skip = skip.concat ['_nowrap', '_attributes', '_parent', '_events', '_description', '_text', '_label', '_options']
		for k,v of @getAttributes _attrs when k not in skip and typeof v isnt 'function'
			k = k.substr(1)
			if not attrs[k]?
				attrs[k] = v
		console.log 'attrs', attrs
		ele.attr(attrs)
		# bind all events.
		if events = _attrs._events
			for ev, cb of events when ev
				# ensure callback list is an (ordered) array
				if not cb.forEach?
					cb = [cb]
				# add validation before submission
				if ev is 'submit' and events.validate
					cb.unshift events.validate
				# if there is a validate but no submit, make sure it is called.
				if ev is 'validate'
					if not events.submit
						ev = 'submit'
					else
						continue

				ele[ev] () ->
					for _cb in cb
						if not _cb.apply this, arguments
							return false

		ele

	# takes an jQuery object / html
	# returns a wrapped jQuery object
	_wrap: (ele) ->
		jQuery(ele).wrap('<div />').parent().addClass('form-row')

	@registerType = @::registerType = (type, callback) ->
		FormJS.types[type] = callback

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
Type: markup
Notes: Used to display markup, ie white-space: pre
Options:
	markup/text: text to appear inside
###
FormJS.registerType 'markup', (options) ->
	options._markup ?= options._text
	@applyAttributes jQuery('<div />').html(options._markup), options

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

###
Type: button
Notes: A <button> tag
Options: _value
###
FormJS.registerType 'button', (options) ->
	@applyAttributes jQuery('<button />').html(options._value), options

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
		wrap.append @render o

	@applyAttributes wrap, options

###
Type: select2
Notes: uses the select2 plugin
Options:
	_config: these options will be passed directly to the select2 constructor
	_options: (optional) a value/label map, that gets written into _config.data
	* any other options that 
###
FormJS.registerType 'select2', (options) ->
	config_keys = ["width", "minimumInputLength", "maximumInputLength", "minimumResultsForSearch", "maximumSelectionSize", "placeholder", "separator", "allowClear", "multiple", "closeOnSelect", "openOnEnter", "id", "matcher", "sortResults", "formatSelection", "formatResult", "formatResultCssClass", "formatNoMatches", "formatSearching", "formatInputTooShort", "formatSelectionTooBig", "createSearchChoice", "initSelection", "tokenizer", "tokenSeparators", "query", "ajax", "data", "tags", "containerCss", "containerCssClass", "dropdownCss", "dropdownCssClass", "escapeMarkup", "selectOnBlur", "loadMorePadding"]
	config = options._config or {}

	for key in config_keys when options['_' + key]?
		config[key] ?= options['_' + key]
		delete options[key]

	target = (config.tags and 'tags') or 'data'
	options._options[datum.id] = datum.text for datum in config[target] or []
	config[target] = ({id: id, text: text} for id, text of options._options)

	options._config = config

	ele = jQuery('<input type="hidden" />')

	# need to delay the init until after it's in the dom
	setTimeout (() -> ele.select2 config), 10
	return @applyAttributes ele, options, config_keys.concat ['_type', '_config']

###
Type: default
Notes: fallback used to implement text/radio/submit etc <input type=".." without strictly defining them
###
FormJS.registerType 'default', (options) ->
	@applyAttributes jQuery('<input />'), options

if module?
	module.exports = FormJS
if window?
	window.FormJS = FormJS