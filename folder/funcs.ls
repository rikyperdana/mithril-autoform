@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril
	@autoForm = (opts) ->
		theSchema = new SimpleSchema opts.schema
		inputTypes =
			text: String
			number: Number
		attr =
			form: onsubmit: (e) ->
				e.preventDefault!
				obj = _.merge ... _.initial _.map e.target, (i) ->
					_.fromPairs [[ i.name, do ->
						if theSchema._schema[i.name]?type is Number
							parseInt i.value
						else i.value
					]]
				if opts.type is \insert
					opts.collection.insert obj
		omitFields = if opts.omitFields
			_.pull (_.values theSchema._firstLevelSchemaKeys), ...opts.omitFields
		usedFields = omitFields or opts.fields or theSchema._firstLevelSchemaKeys
		m \form, attr.form,
			usedFields.map (i) ->
				find = _.find (_.toPairs inputTypes), (j) ->
					j.1 is theSchema._schema[i]type
				m \input,
					name: i
					type: find.0
					placeholder: theSchema._schema[i]label or _.startCase i
			m \input.btn,
				type: \submit
				value: opts.buttonContent if opts.buttonContent
				class: opts.buttonClasses if opts.buttonClasses
