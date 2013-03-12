class FormJS

	@types = {}
	@used_ids = []

	constructor: (obj, target) ->
		if obj._method
			obj._type = 'form'

		@config = obj

		@dom = @render obj
		@dom.addClass('formjs-root')
		@dom.find('*').data('form-config', obj)

		# rewrite config incase it changed during render
		@config = obj
		target and @dom.appendTo target

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
		if obj._nowrap isnt true
			element = @label (@_wrap element, obj), obj

		children = @getChildren obj
		for name, val of children
			@render(val).appendTo val._target or element

		element

	_render: (obj, type_override = null) ->
		type = type_override or obj._type
		fn = FormJS.types[type] or FormJS.types.default
		
		fn.call this, obj

	_generate_id: (obj) ->
		if not obj._id and obj._name
			id = "form-#{obj._name}"
			ids = FormJS.used_ids
			while id in FormJS.used_ids
				id = "form-#{obj._name}-#{Math.floor(Math.random() * 500)}"
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
			o._for ?= obj._id
			ele[method] @_render o

		return ele

	populate: (data, target = @dom) ->
		elements = {}
		elements[$(ele).attr('name')] = $(ele) for ele in target.find('[name]')

		get_names = (value, key = '', names = {}) ->
			if typeof value is 'object'
				for k,v of value
					names = get_names v, key + '[' + k + ']', names
			else
				names[key] = value
			return names

		for k,v of data
			names = get_names v, k
			for name, val of names when element = @dom.find '[name="' + name + '"]'
				config = element.data('item-config')

				if (multi = element.parents('.form-multiple')).length > 0
					conf = multi.data('item-config')
					if conf._populate_callback
						if conf._populate_callback name, val, element, conf, data
							continue

				if element.attr('type') is 'checkbox'
					checked = (val.toUpperCase and val.length) or (val.toFixed and !!(parseFloat(val))) or 1 # integer or string
					if checked
						element.attr 'checked', 'checked'
					else
						element.removeAttr 'checked'
				else if element.attr('type') is 'radio'
					@form.find('[name="' + name = '"][value=' + val + ']')
						.removeAttr('checked')
						.filter('[value=' + val + ']')
						.attr('checked', 'checked')
				else
					element?.val val

	getValues: (target, debug = false) ->
		values = {}
		target = $ target or @dom

		for ele in target.find('[name]')
			ele = jQuery(ele)
			name = ele.attr('name')
			type = ele.attr('type')

			if type in ['submit', 'reset', 'cancel']
				continue

			config = ele.parent().find('input, select, textarea').andSelf().data('item-config')

			val  = (config and config._value_callback?.call? and config._value_callback.call(ele, config)) or ele.attr('data-value') or ele.val()

			if not val
				continue

			if type in ['radio', 'checkbox']
				val = target.find('[name="' + name + '"]:checked').val()
				if val is 'undefined' or typeof val is 'undefined'
					val = false

			levels = ['^([^\\[]+)', '\\[([0-9]+|[^\\]]+)\\]', '\\[([0-9]+|[^\\]]+)\\]', '\\[([0-9]+|[^\\]]+)\\]']
			reg = ''
			i = 0
			tar = values
			for level in levels
				i++
				reg += level
				match = name.match(reg)
				if match and match[i]?
					k = match[i]
					type = (if isNaN(parseInt(match[i])) then {} else [])

					if i is 1
						find = 'values.' + k
						values[k] ?= type.constructor()
					else
						eval(find + ' = ' + find + ' && ' + find + '.constructor == type.constructor ? ' + find + ' : type.constructor()')
						find += '["' + k + '"]'

			eval(find + ' = ' + JSON.stringify(val))

		return values		

	applyAttributes: (ele, _attrs, skip = []) ->
		if not _attrs
			throw 'No attrs'

		@_generate_id _attrs
		ele.data('item-config', _attrs)

		# need to transform the attrs to remove the _
		attrs = ele._attributes or {}
		skip = skip.concat ['_nowrap', '_attributes', '_parent', '_events', '_description', '_text', '_label', '_options']
		for k,v of @getAttributes _attrs when k not in skip and typeof v isnt 'function'
			k = k.substr(1)
			if not attrs[k]?
				attrs[k] = v

		ele.attr(attrs)
		# bind all events.
		if events = _attrs._events
			for ev, cb of events when ev
				do (ev, cb) =>
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
							return
					if ele[ev]
						ele[ev] (e) =>
							for _cb in cb
								if not _cb.call this, @getValues(), e
									return false

		ele

	# takes an jQuery object / html
	# returns a wrapped jQuery object
	_wrap: (ele, obj) ->
		wrap = jQuery(ele)
		  .wrap('<div />')
		  .parent()
		  .addClass('form-row')
		  .addClass obj._type and 'form-' + obj._type
		@applyAttributes wrap, obj._wrap_options or {}

	@registerType = @::registerType = (type, callback) ->
		FormJS.types[type] = callback

require('./elements/base.js')(FormJS)
require('./elements/buttons.js')(FormJS)
require('./elements/options.js')(FormJS)
require('./elements/select.js')(FormJS)

if module?
	module.exports = FormJS
if window?
	window.FormJS = FormJS