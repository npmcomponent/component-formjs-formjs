*This repository is a mirror of the [component](http://component.io) module [component-formjs/formjs](http://github.com/component-formjs/formjs). It has been modified to work with NPM+Browserify. You can install it using the command `npm install npmcomponent/component-formjs-formjs`. Please do not open issues or send pull requests against this repo. If you have issues with this repo, report it to [npmcomponent](https://github.com/airportyh/npmcomponent).*

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
