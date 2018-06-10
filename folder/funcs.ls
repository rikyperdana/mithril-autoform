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
			state: []
			form: onsubmit: (e) ->
				e.preventDefault!
				states = attr.state.map (i) -> "#{i.name}": i.value
				filtered = _.filter e.target, (i) ->
					a = -> (i.value isnt \on) and i.name
					b = -> theSchema(i)?autoform?type in <[radio checkbox select]>
					a! and not b!
				obj = _.merge ... states.concat _.map filtered, (i) ->
					_.reduceRight i.name.split(\.),
						((res, inc) -> "#inc": res), do ->
							switch theSchema(i.name)type
								when String then i.value
								when Number then +i.value
								when Date then new Date i.value
				dataTest = do ->
					a = opts.schema.newContext!
					a.validate obj
					a._invalidKeys.map (i) ->
						Materialize.toast "#{i.name} - #{i.type}", 8000ms, \orange
					check obj, opts.schema
				formTypes = (doc) ->
					insert: -> console.log \insert, obj
					# insert: -> opts.collection.insert (doc or obj)
					update: -> opts.collection.update do
						{_id: opts.doc._id}, {$set: (doc or obj)}
					method: -> Meteor.call opts.meteormethod, (doc or obj)
				if opts.hooks?before then opts.hooks.before obj, (moded) ->
					formTypes(moded)[opts.type]!
				else formTypes![opts.type]!
				opts.hooks?after? obj
			radio: (name, value) ->
				type: \radio, name: name, id: "#name#value"
				checked: true if value is opts.doc?[name]
				oncreate: -> $("input:radio##name#value[name=#name]").on do
					\change, -> attr.state.push {name, value}
			select: (name) ->
				name: name
				value: opts.doc?[name]
				oncreate: ->
					$ "select[name=#name]" .material_select!
					$ "select[name=#name]" .on \change ->
						attr.state.push do
							name: name
							value: $ "select[name=#name]" .val!
			checkbox: (name) ->
				oncreate: -> $ "input[name=#name]" .on \change ->
					attr.state.push name: name, value:
						_.map $("input:checked[name=#name]"), (i) ->
							i.attributes.data.nodeValue

		view: -> m \form, attr.form,
			m \.row, usedFields.map (i) ->
				defaultInput = (name, schema) ->
					defaultInputTypes =
						text: String, number: Number,
						radio: Boolean, date: Date
					defaultType = -> _.find (_.toPairs defaultInputTypes),
						(j) -> j.1 is schema.type
					if defaultType!
						m \.input-field,
							class: schema.autoform?afFormGroup?class,
							m \label, for: i, _.startCase (schema?label or i)
							m \.row if defaultType!0 is \date
							m \input,
								name: name
								id: name
								type: schema.autoform?type or defaultType!0
								value: if opts.doc?[i]
									if defaultType!0 is \date
										moment(opts.doc[i])format \YYYY-MM-DD
									else opts.doc[i]
					else if schema.type is Object
						maped = _.map opts.schema._schema, (val, key) ->
							val.name = key; val
						filed = _.filter maped, (j) ->
							a = -> _.includes j.name, "#name."
							b = -> name.split(\.)length+1 is j.name.split(\.)length
							a! and b!
						m \.card, m \.card-content,
							m \.card-title, _.startCase name
							filed.map (j) ->
								defaultInput j.name, j
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
					other: -> defaultInput i, theSchema i
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
