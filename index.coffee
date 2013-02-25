class Form

	@types = {}
	@used_ids = []

	constructor: (obj) ->
		if obj._method
			obj._type = 'form'


		@dom = @render obj

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
		fn = Form.types[type] or Form.types.default
		
		fn.call this, obj

	_generate_id: (obj) ->
		if not obj._id
			id = "form-#{obj._name}"
			ids = Form.used_ids
			while id in Form.used_ids
				id = "form-#{obj._name}-#{Math.random()}"
			Form.used_ids.push id
			obj._id = id

	label: (ele, obj) ->
		if obj._label
			@_generate_id obj
			jQuery('<label />').attr({'for': obj._id}).text(obj._label).prependTo ele
		return ele

	applyAttributes: (ele, _attrs) ->
		# need to transform the attrs to remove the _
		attrs = ele._attributes or {}
		for k,v of @getAttributes _attrs when k not in ['_nowrap', '_attributes', '_parent', '_events']
			k = k.substr(1)
			if not attrs[k]?
				attrs[k] = v
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
		Form.types[type] = callback

###
Type: form
###
Form.registerType 'form', (options) ->
	options._nowrap = true
	options._attributes = {type: false}
	@applyAttributes jQuery('<form />'), options

###
Type: fieldset
Options:
	legend: text to appear in a <legend> tag as the first child of the fieldset
###
Form.registerType 'fieldset', (options) ->
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
Form.registerType 'group', (options) ->
	options._nowrap = true
	@applyAttributes jQuery('<div />'), options

###
Type: description
Notes: Mostly used internally to add descriptions to an existing element
Options:
	description/text: text to appear in the description
###
Form.registerType 'description', (options) ->
	options._nowrap = true
	@applyAttributes jQuery('<span />').addClass('description').html options._description or options._text

###
Type: markup
Notes: Used to display markup, ie white-space: pre
Options:
	markup/text: text to appear inside
###
Form.registerType 'markup', (options) ->
	@applyAttributes jQuery('<div />').html options._markup or options.text

###
Type: hidden
Notes: A type=hidden input
###
Form.registerType 'hidden', (options) ->
	options._nowrap = true
	Form.types.default options

###
Type: textarea
Notes: A <textarea /> input
Options: _cols, _rows
###
Form.registerType 'textarea', (options) ->
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
Form.registerType 'select', (options) ->
	if options._multiple and (options._multiple is !!options._multiple)
		options._multiple = 'multiple'
	else
		delete options._multiple

	tag = jQuery('<select />')
	for val, label of options
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
Form.registerType 'button', (options) ->
	@applyAttributes jQuery('<button />').html(options._value)

###
Type: default
Notes: fallback used to implement text/radio/submit etc <input type=".." without strictly defining them
###
Form.registerType 'default', (options) ->
	@applyAttributes jQuery('<input />'), options

module.exports = Form