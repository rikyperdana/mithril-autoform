@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril

	@autoForm = (opts) ->
		scope = opts.scope and new SimpleSchema _.reduce opts.schema._schema,
			(res, val, key) ->
				tester = new RegExp "^#{opts.scope}"
				res[key] = val if tester.test key
				res
		, {}
		opts.schema = scope or opts.schema
		theSchema = (name) -> opts.schema._schema[name]
		omitFields = if opts.omitFields
			_.pull (_.values opts.schema._firstLevelSchemaKeys), ...opts.omitFields
		usedFields = omitFields or opts.fields or opts.schema._firstLevelSchemaKeys
		optionList = (name) ->
			allows = theSchema(name)allowedValues?map (i) -> value: i, label: _.startCase i
			or theSchema(name)autoform?options
		state.arrLen ?= {}; state.form ?= {}; state.temp ?= {}
		state.form[opts.id] ?= {}; state.temp[opts.id] ?= []
		stateTempGet = (field) -> if state.temp[opts.id]
			_.findLast state.temp[opts.id], (i) -> i.name is field
		
		attr =
			form:
				onchange: ({target}) ->
					unless theSchema(target.name)?autoform?type in <[radio checkbox select]>
						state.form[opts.id][target.name] = target.value
				onsubmit: (e) ->
					e.preventDefault!
					temp = state.temp[opts.id]map (i) -> "#{i.name}": i.value
					filtered = _.filter e.target, (i) ->
						a = -> (i.value isnt \on) and i.name
						b = -> theSchema(i)?autoform?type in <[radio checkbox select]>
						a! and not b!
					obj = _.merge ... _.map (temp.concat filtered), ({name, value}) ->
						name and _.reduceRight name.split(\.),
							((res, inc) -> "#inc": res), do ->
								if value
									normed = name.replace /(\d+)/g, \$
									switch theSchema(normed)type
										when String then value
										when Number then +value
										when Date then new Date value
								else if theSchema(normed)?autoValue?
									theSchema(normed)?autoValue name, temp.concat filtered
					/*dataTest = do ->
						a = opts.schema.newContext!
						a.validate obj
						a._invalidKeys.map (i) ->
							Materialize.toast "#{i.name} - #{i.type}", 8000ms, \orange
						check obj, opts.schema */
					formTypes = (doc) ->
						insert: -> console.log \insert, obj
						# insert: -> opts.collection.insert (doc or obj)
						update: -> opts.collection.update do
							{_id: opts.doc._id}, {$set: (doc or obj)}
						method: -> Meteor.call opts.meteormethod, (doc or obj)
						'update-pushArray': -> opts.collection.update {_id: opts.doc._id},
							$push: "#{opts.scope}": $each: _.values obj[opts.scope]
					if opts.hooks?before
						opts.hooks.before obj, (moded) -> formTypes(moded)[opts.type]!
					else formTypes![opts.type]!
					opts.hooks?after? obj

			radio: (name, value) ->
				type: \radio, name: name, id: "#name#value"
				checked: value is (stateTempGet(name)?value or opts.doc?[name])
				oncreate: -> $("input:radio##name#value[name='#name']")on do
					\change, -> state.temp[opts.id]push {name, value}

			select: (name) ->
				name: name
				value: stateTempGet(name)?value or opts.doc?[name]
				oncreate: ->
					$ "select[name='#name']" .material_select!
					$ "select[name='#name']" .on \change -> state.temp[opts.id]push do
						name: name, value: $ "select[name='#name']" .val!

			checkbox: (name) ->
				oncreate: -> $ "input[name='#name']" .on \change ->
					state.temp[opts.id]push name: name, value:
						_.map $("input:checked[name='#name']"), (i) ->
							i.attributes.data.nodeValue

			arrLen: (name, type) -> onclick: ->
				state.arrLen[name] ?= 0
				num = inc: 1, dec: -1
				state.arrLen[name] += num[type]

		view: -> m \form, attr.form,
			m \.row, usedFields.map (i) ->

				defaultInput = (name, schema) ->
					defaultInputTypes =
						text: String, number: Number,
						radio: Boolean, date: Date
					defaultType = -> _.find (_.toPairs defaultInputTypes), (j) ->
						j.1 is schema.type
					maped = _.map opts.schema._schema, (val, key) ->
						val.name = key; val

					if defaultType!
						m \.input-field,
							class: schema.autoform?afFormGroup?class,
							m \label, for: i, _.startCase (schema?label or name)
							m \.row if defaultType!0 is \date
							m \input,
								name: name, id: name,
								type: schema.autoform?type or defaultType!0
								value: do ->
									date = if opts.doc?[i] then if defaultType!0 is \date
										moment(opts.doc[i])format \YYYY-MM-DD
									state.form[opts.id]?[name] or date or opts.doc?[i]

					else if schema.type is Object
						filtered = _.filter maped, (j) ->
							a = -> _.includes j.name, "#name."
							b = -> name.split(\.)length+1 is j.name.split(\.)length
							a! and b!
						m \.card, m \.card-content,
							m \.card-title, _.startCase name
							filtered.map (j) -> inputTypes(j.name, j)[j?autoform?type or \other]!

					else if schema.type is Array
						filtered = _.filter maped, (j) -> _.includes j.name, "#name.$"
						m \.card, m \.card-content,
							m \.card-title,
								m \p, _.startCase name
								m \.right.orange.btn.waves-effect, attr.arrLen(name, \dec), \-rem
								m \.right.btn.waves-effect, attr.arrLen(name, \inc), \+add
							filtered.map (j) -> [0 to (state.arrLen[name] or 0)]map (num) ->
								iter = "#{_.replace j.name, \$, ''}#num"
								inputTypes(iter, j)[j?autoform?type or \other]!

				inputTypes = (name, schema) ->

					textarea: -> m \.input-field,
						m \textarea.materialize-textarea,
							name: name, id: name, value: opts.doc?[name]
						m \label, for: name, _.startCase name

					range: -> m \.input-field,
						m \label, for: name, _.startCase name
						m \.row
						m \input,
							type: \range, id: name, name: name,
							value: state.form[opts.id][name] or opts.doc?[name]?toString!

					checkbox: -> m \div, attr.checkbox(name),
						m \h6.grey-text, _.startCase name
						optionList(name)map (j) -> m \.col,
							m \input,
								type: \checkbox, name: name,
								id: "#name#{j.value}", data: j.value
								checked:
									if stateTempGet(name)
										j.value.toString! in stateTempGet(name)value
									else if opts.doc?[name]
										j.value.toString! in opts.doc[name]
							m \label, for: "#name#{j.value}", _.startCase j.label
						m \.row

					select: -> m \.input-field,
						m \label, _.startCase name
						m \.row
						m \select, attr.select(name),
							m \option, value: '', _.startCase 'Select One'
							optionList(name)map (j) ->
								m \option, value: j.value, _.startCase j.label

					radio: -> m \div,
						m \.row
						m \h6.grey-text, _.startCase name
						m \.row, optionList(name)map (j) -> m \.col,
							m \input, attr.radio name, j.value
							m \label, for: "#name#{j.value}", _.startCase j.label

					other: -> defaultInput name, schema

				inputTypes(i, theSchema i)[theSchema(i)?autoform?type or \other]!

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
