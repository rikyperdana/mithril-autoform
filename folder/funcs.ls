@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril
	@autoForm = (obj, opts) ->
		theSchema = new SimpleSchema obj
		inputTypes =
			text: String
			number: Number
		attr =
			form: onsubmit: (e) ->
				e.preventDefault!
				console.log _.merge ... _.initial _.map e.target, ->
					_.fromPairs [[it.name, it.value]]
		m \form, attr.form,
			theSchema._firstLevelSchemaKeys.map (i) ->
				find = _.find (_.toPairs inputTypes), (j) ->
					j.1 is theSchema._schema[i]type
				m \input, name: i, type: find.0, placeholder: _.startCase i
			m \input.btn, type: \submit
