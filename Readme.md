
# formjs

  Generate forms from a JSON description

## Installation

    $ component install richthegeek/formjs

## API

	form = new Form({
		_method: 'POST',
		_action: 'foo',
		_events: {
			validate: function() {
				alert('Validate')
				return false
			}
		},
		wrap: {
			_type: 'fieldset',
			_legend: 'Test legend',
			text: {
				_type: 'text',
				_label: 'Basic field',
				_placeholder: 'I have a placeholder'
			},
			submit: {
				_type: 'submit',
				_value: 'Submit'
			}
		}
	})
	form.dom.appendTo('body')
   

## License

  MIT
