@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril

	@autoForm = (opts) ->
		theSchema = (name) -> opts.schema._schema[name]
		omitFields = if opts.omitFields
			_.pull (_.values opts.schema._firstLevelSchemaKeys), ...opts.omitFields
		usedFields = omitFields or opts.fields or opts.schema._firstLevelSchemaKeys
		optionList = (name) ->
			allows = theSchema(name)allowedValues?map (i) ->
				value: i, label: _.startCase i
			or theSchema(name)autoform?options
		attr =
			form: onsubmit: (e) ->
				e.preventDefault!
				additionals = _.flatMap attr.state
				obj = _.merge ...additionals, ... _.compact _.map e.target, (i) ->
					(i.name and i.value isnt \on) and "#{i.name}":
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
			state: radio: {}, select: {}, checkbox: {}
			radio: (name, value) ->
				type: \radio, name: name, id: "#name#value"
				checked: true if value is opts.doc?[name]
				oncreate: -> $("input:radio##name#value[name=#name]").on do
					\change, -> attr.state.radio[name] = value
			select: (name) ->
				name: name
				value: opts.doc?[name]
				oncreate: ->
					$ "select[name=#name]" .material_select!
					$ "select[name=#name]" .on \change ->
						attr.state.select[name] = $ "select[name=#name]" .val!
			checkbox: (name) ->
				oncreate: -> $ "input[name=#name]" .on \change ->
					attr.state.checkbox[name] =
						_.map $("input:checked[name=#name]"), (i) ->
							i.attributes.data.nodeValue

		view: -> m \form, attr.form,
			m \.row, usedFields.map (i) ->
				inputTypes =
					textarea: -> m \.input-field,
						m \textarea.materialize-textarea,
							name: i, id: i, value: opts.doc?[i]
						m \label, for: i, _.startCase i
					range: -> m \.input-field,
						m \label, for: i, _.startCase i
						m \.row
						m \input,
							type: \range, id: i, name: i,
							value: opts.doc?[i]?toString!
					checkbox: -> m \div, attr.checkbox(i),
						m \h6.grey-text, _.startCase i
						optionList(i)map (j) -> m \.col,
							m \input,
								type: \checkbox, name: i,
								id: "#i#{j.value}", data: j.value
								checked: if opts.doc?[i]
									true if j.value.toString! in opts.doc[i]
							m \label, for: "#i#{j.value}", _.startCase j.label
						m \.row
					select: -> m \.input-field,
						m \label, _.startCase i
						m \.row
						m \select, attr.select(i),
							m \option, value: '', _.startCase 'Select One'
							optionList(i)map (j) ->
								m \option, value: j.value, _.startCase j.label
					radio: -> m \div,
						m \.row
						m \h6.grey-text, _.startCase i
						m \.row, optionList(i)map (j) -> m \.col,
							m \input, attr.radio i, j.value
							m \label, for: "#i#{j.value}", _.startCase j.label
					other: ->
						defaultInputTypes =
							text: String, number: Number,
							radio: Boolean, date: Date
						defaultType = -> _.find (_.toPairs defaultInputTypes),
							(j) -> j.1 is theSchema(i)type
						m \.input-field, class: theSchema(i)autoform?afFormGroup?class,
							m \label, for: i, _.startCase (theSchema(i)?label or i)
							m \.row if defaultType!0 is \date
							m \input,
								name: i, id: i,
								type: theSchema(i)autoform?type or defaultType!0
								value: if opts.doc?[i]
									if defaultType!0 is \date
										moment(opts.doc[i])format \YYYY-MM-DD
									else opts.doc[i]
				inputTypes[theSchema(i)?autoform?type or \other]!
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
