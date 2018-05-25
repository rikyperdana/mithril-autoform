@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril
	defaultInputTypes =
		text: String
		number: Number
		radio: Boolean
	@autoForm = (opts) ->
		theSchema = (name) -> opts.schema._schema[name]
		omitFields = if opts.omitFields
			_.pull (_.values opts.schema._firstLevelSchemaKeys), ...opts.omitFields
		usedFields = omitFields or opts.fields or opts.schema._firstLevelSchemaKeys
		optionList = (name) ->
			allowed = theSchema(name)allowedValues?map (i) ->
				value: i, label: _.startCase i
			allowed or theSchema(name)autoform?options
		attr =
			form: onsubmit: (e) ->
				e.preventDefault!
				obj = _.merge attr.state.radio, ... _.compact _.map e.target, (i) ->
					a = -> i.name
					b = -> i.value isnt \on
					if a! and b! then "#{i.name}":
						if theSchema(i.name)type is Number then parseInt i.value
						else i.value
				check obj, opts.schema
				formTypes =
					insert: -> opts.collection.insert obj
					update: -> opts.collection.update do
						{_id: opts.doc._id}, {$set: obj}
					method: -> Meteor.call opts.meteormethod, obj
				formTypes[opts.type]!
			state: radio: {}
			radio: (name, value) ->
				type: \radio, name: name, id: value
				checked: true if value is opts.doc?[name]
				oncreate: -> $("input:radio##{value}[name=#{name}]").on \change, ->
					attr.state.radio[name] = value
		view: -> m \form, attr.form,
			m \.row, usedFields.map (i) ->
				find = _.find (_.toPairs defaultInputTypes), (j) ->
					j.1 is theSchema(i)type
				a = -> theSchema(i)allowedValues
				b = -> theSchema(i)autoform?type is \radio
				# if theSchema(i)autoform?type is \radio
				if a! or b!
					m \.card, m \.card-content,
						m \.h5.grey-text, _.startCase i
						m \.row, optionList(i)map (j) -> m \.col,
							m \input, attr.radio i, j.value
							m \label, for: j.value, _.startCase j.label
				else if find.0 in <[ text number ]> then m \input,
					name: i
					type: theSchema(i)autoform?type or find.0
					placeholder: theSchema(i)label or _.startCase i
					class: theSchema(i)autoform?afFormGroup?class
					value: opts.doc?[i]
			m \.row,
				m \.col, m \input.btn,
					type: \submit
					value: opts?buttonContent
					class: opts?buttonClasses
				m \.col, m \input.btn,
					type: \reset
					value: opts?reset?content
					class: opts?reset?classes

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
