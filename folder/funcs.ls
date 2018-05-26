@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril
	@funConds = (arr) -> (?expr!) _.find arr, -> it.cond!

	defaultInputTypes =
		text: String
		number: Number
		radio: Boolean
		date: Date

	@autoForm = (opts) ->
		theSchema = (name) -> opts.schema._schema[name]
		omitFields = if opts.omitFields
			_.pull (_.values opts.schema._firstLevelSchemaKeys), ...opts.omitFields
		usedFields = omitFields or opts.fields or opts.schema._firstLevelSchemaKeys
		optionList = (name) ->
			allows = theSchema(name)allowedValues?map (i) ->
				value: i, label: _.startCase i
			allows or theSchema(name)autoform?options
		attr =
			form: onsubmit: (e) ->
				e.preventDefault!
				additionals = _.flatMap attr.state
				obj = _.merge ...additionals, ... _.compact _.map e.target, (i) ->
					a = -> i.name and i.value isnt \on
					if a! then "#{i.name}":
						if theSchema(i.name)type is Number then parseInt i.value
						else if theSchema(i.name)type is Date then new Date i.value
						else i.value
				check obj, opts.schema
				formTypes =
					insert: -> opts.collection.insert obj
					update: -> opts.collection.update do
						{_id: opts.doc._id}, {$set: obj}
					method: -> Meteor.call opts.meteormethod, obj
				formTypes[opts.type]!
			state: radio: {}, select: {}
			radio: (name, value) ->
				type: \radio, name: name, id: value
				checked: true if value is opts.doc?[name]
				oncreate: -> $("input:radio##{value}[name=#{name}]").on \change, ->
					attr.state.radio[name] = value
			select: (name) ->
				oncreate: ->
					$ \select .material_select!
					$ \select .on \change ->
						attr.state.select[name] = $ \select .val!
		view: -> m \form, attr.form,
			m \.row, usedFields.map (i) ->
				defaultType = _.find (_.toPairs defaultInputTypes), (j) ->
					j.1 is theSchema(i)type
				funConds [
					cond: -> theSchema(i)autoform?type is \select
					expr: -> m \select, attr.select(i),
						m \option, value: '', _.startCase 'Select One'
						optionList(i)map (j) ->
							m \option, value: j.value, _.startCase j.label
				,
					cond: -> theSchema(i)autoform?type is \radio
					expr: -> m \.card, m \.card-content,
						m \.h5.grey-text, _.startCase i
						m \.row, optionList(i)map (j) -> m \.col,
							m \input, attr.radio i, j.value
							m \label, for: j.value, _.startCase j.label
				,
					cond: -> defaultType.0 in <[ text number date ]>
					expr: -> m \input,
						name: i, id: i,
						type: theSchema(i)autoform?type or defaultType.0
						class: theSchema(i)autoform?afFormGroup?class
						placeholder: theSchema(i)label or _.startCase i
						value: if opts.doc?[i]
							if defaultType.0 is \date
								moment(opts.doc[i])format \YYYY-MM-DD
							else opts.doc[i]
				]
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
