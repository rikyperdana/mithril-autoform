@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril
	inputTypes =
		text: String
		number: Number
	@autoForm = (opts) ->
		attr =
			form: onsubmit: (e) ->
				e.preventDefault!
				obj = _.merge ... _.initial _.map e.target, (i) ->
					_.fromPairs [[ i.name, do ->
						if opts.schema._schema[i.name]?type is Number
							parseInt i.value
						else i.value
					]]
				formTypes =
					insert: -> Meteor.isClient and opts.collection.insert obj
					update: -> if Meteor.isClient
						sel = _id: opts.doc._id
						mod = $set: opts.doc
						opts.collection.update sel, mod
					method: -> Meteor.call opts.meteormethod, obj
				formTypes[opts.type]!
		omitFields = if opts.omitFields
			_.pull (_.values opts.schema._firstLevelSchemaKeys), ...opts.omitFields
		usedFields = omitFields or opts.fields or opts.schema._firstLevelSchemaKeys
		view: -> m \form, attr.form, m \.row,
			usedFields.map (i) ->
				find = _.find (_.toPairs inputTypes), (j) ->
					j.1 is opts.schema._schema[i]type
				m \input,
					name: i
					type: find.0
					placeholder: opts.schema._schema[i]label or _.startCase i
					class: opts.schema._schema[i]autoform?afFormGroup.class
					value: opts.doc?[i]
			m \input.btn,
				type: \submit
				value: opts?buttonContent
				class: opts?buttonClasses

	@autoTable = (opts) ->
		attr =
			rowEvent: (doc) ->
				onclick: -> opts.rowEvent.onclick doc
				ondblclick: -> opts.rowEvent.ondblclick doc
		view: -> m \table,
			m \thead,
				m \tr, opts.fields.map (i) ->
					m \th, _.startCase i
			m \tbody, opts.collection.find!fetch!map (i) ->
				m \tr, attr.rowEvent(i), opts.fields.map (j) ->
					m \td, i[j]
