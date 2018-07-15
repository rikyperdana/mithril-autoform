@_ = lodash
@coll = {}; @schema = {}; @state = {};

if Meteor.isClient

	@m = require \mithril

	@autoForm = (opts) ->
		scope = opts.scope and new SimpleSchema do
			_.reduce opts.schema._schema, (res, val, key) ->
				test = (new RegExp "^#{opts.scope}")test key
				test and _.assign res, "#key": val
			, {}
		usedSchema = scope or opts.schema
		theSchema = (name) -> usedSchema._schema[name]

		omitFields = if opts.omitFields
			_.pull (_.values usedSchema._firstLevelSchemaKeys), ...opts.omitFields
		usedFields = omitFields or opts.fields or usedSchema._firstLevelSchemaKeys

		optionList = (name) ->
			theSchema(name)allowedValues?map (i) ->
				value: i, label: _.startCase i
			or theSchema(name)autoform?options

		state.arrLen ?= {}; state.form ?= {}
		state.temp ?= {}; state.errors ?= {}
		state.form[opts.id] ?= {}; state.temp[opts.id] ?= []
		stateTempGet = (field) -> if state.temp[opts.id]
			_.findLast state.temp[opts.id], (i) -> i.name is field

		abnormalize = (obj) ->
			recurse = (name, value) ->
				if value?getMonth then "#name": value
				else if _.isObject value then _.assign {},
					... _.map value, (val, key) ->
						recurse "#name.#key", val
				else "#name": value
			_.assign {}, ... _.map (recurse \obj, obj),
				(val, key) -> "#{key.substring 4}": val
		abnDoc = abnormalize opts.doc if opts.doc

		attr =
			form:
				id: opts.id
				onchange: ({target}) ->
					arr = <[ radio checkbox select ]>
					unless theSchema(target.name)?autoform?type in arr
						state.form[opts.id][target.name] = target.value
					opts.autosave and $ "form##{opts.id}" .submit!

				onsubmit: (e) ->
					e.preventDefault!
					temp = state.temp[opts.id]map (i) -> "#{i.name}": i.value
					filtered = _.filter e.target, (i) ->
						a = -> (i.value isnt \on) and i.name
						arr = <[radio checkbox select]>
						b = -> theSchema(i)?autoform?type in arr
						a! and not b!

					merged = _.merge ... temp.concat _.map filtered,
						({name, value}) -> name and _.reduceRight name.split(\.),
							((res, inc) -> "#inc": res), do ->
								if value
									normed = name.replace /(\d+)/g, \$
									switch theSchema(normed)type
										when String then value
										when Number then +value
										when Date then new Date value
								else if theSchema(normed)?autoValue?
									theSchema(normed)?autoValue do
										name, temp.concat filtered

					normalize = (obj) ->
						recurse = (value, name) ->
							if _.isObject value then "#name":
								if value.0 then _.map value, recurse
								else if value.getMonth then value
								else _.assign {}, ... _.map value, recurse
							else
								if +name >= 0 then value
								else "#name": value
						obj = recurse obj, \obj .obj
						for key, val of obj
							if key.split(\.)length > 1
								delete obj[key]
						obj

					obj = normalize merged

					dataTest = do ->
						context = usedSchema.newContext!
						context.validate _.merge {}, obj, (opts.doc or {})
						state.errors[opts.id] = _.assign {},
							... context._invalidKeys.map (i) -> "#{i.name}": i.type

					formTypes = (doc) ->
						insert: -> opts.collection.insert (doc or obj)
						update: -> opts.collection.update do
							{_id: abnDoc._id}, {$set: (doc or obj)}
						method: -> Meteor.call opts.meteormethod, (doc or obj)
						'update-pushArray': -> opts.collection.update do
							{_id: abnDoc._id}, $push: "#{opts.scope}":
								$each: _.values obj[opts.scope]

					if opts.hooks?before
						opts.hooks.before obj, (moded) ->
							formTypes(moded)[opts.type]!
					else formTypes![opts.type]!
					opts.hooks?after? obj

			radio: (name, value) ->
				type: \radio, name: name, id: "#name#value"
				checked: value is (stateTempGet(name)?value or abnDoc?[name])
				onchange: -> state.temp[opts.id]push {name, value}

			select: (name) ->
				name: name
				value: stateTempGet(name)?value or abnDoc?[name]
				onchange: ({target}) -> state.temp[opts.id]push do
					name: name, value: target.value

			checkbox: (name, value) ->
				type: \checkbox, name: name, id: "#name#value", data: value,
				onchange: -> state.temp[opts.id]push name: name, value:
					_.map $("input:checked[name='#name']"), ->
						theVal = (val) -> if +val then +val else val
						theVal it.attributes.data.nodeValue
				checked:
					if stateTempGet(name)
						value.toString! in _.map stateTempGet(name)value,
							(i) -> i.toString!
					else if abnDoc?["#name.0"]
						value.toString! in _.compact _.map abnDoc,
							(val, key) -> val.toString! if _.includes key, name

			arrLen: (name, type) -> onclick: ->
				state.arrLen[name] ?= 0
				num = inc: 1, dec: -1
				state.arrLen[name] += num[type]

		inputTypes = (name, schema) ->
			error = _.startCase _.find state.errors[opts.id],
				(val, key) -> key is name

			hidden: -> m \div

			textarea: -> m \div,
				m \textarea.textarea,
					name: name, id: name,
					class: \is-danger if error
					placeholder: _.startCase name
					value: state.form[opts.id][name] or abnDoc?[name]
				m \p.help.is-danger, error if error

			range: -> m \div,
				m \label.label, _.startCase name
				m \input,
					type: \range, id: name, name: name,
					class: \is-danger if error
					value: state.form[opts.id][name] or abnDoc?[name]?toString!
				m \p.help.is-danger, error if error

			checkbox: -> m \div,
				m \label.label, _.startCase name
				optionList(name)map (j) -> m \label.checkbox,
					m \input, attr.checkbox name, j.value
					m \span, _.startCase j.label
				m \p.help.is-danger, error if error

			select: -> m \div,
				m \label.label, _.startCase name
				m \.select, m \select, attr.select(name),
					m \option, value: '', _.startCase 'Select One'
					optionList(name)map (j) ->
						m \option, value: j.value, _.startCase j.label
				m \p.help.is-danger, error if error

			radio: -> m \.control,
				m \label.label, _.startCase name
				optionList(name)map (j) -> m \label.radio,
					m \input, attr.radio name, j.value
					m \span, _.startCase j.label

			other: ->
				defaultInputTypes =
					text: String, number: Number,
					radio: Boolean, date: Date
				defaultType = -> _.find (_.toPairs defaultInputTypes),
					(j) -> j.1 is schema.type
				maped = _.map usedSchema._schema, (val, key) ->
					_.merge val, name: key
				label =
					theSchema(name)?label
					or _.startCase _.last _.split name, \.

				if defaultType! then m \.field,
					m \label.label, label
					m \.control, m \input.input,
						class: \is-danger if error
						type: schema.autoform?type or defaultType!0
						name: name, id: name, value: do ->
							date = abnDoc?[name] and defaultType!0 is \date and
								moment abnDoc[name] .format \YYYY-MM-DD
							state.form[opts.id]?[name] or date or abnDoc?[name]
					m \p.help.is-danger, error if error

				else if schema.type is Object
					filtered = _.filter maped, (j) ->
						a = -> _.includes j.name, "#name."
						b = -> name.split(\.)length+1 is j.name.split(\.)length
						a! and b!
					m \.box,
						m \h5.subtitle, label
						filtered.map (j) ->
							type = j?autoform?type or \other
							inputTypes(j.name, j)[type]!

				else if schema.type is Array
					filtered = _.filter maped, (j) -> _.includes j.name, "#name.$"
					m \.box,
						m \h5.subtitle, label
						m \a.button.is-success, attr.arrLen(name, \inc), '+ Add'
						m \a.button.is-warning, attr.arrLen(name, \dec), '- Rem'
						filtered.map (j) ->
							docLen = (.length-1) _.filter abnDoc, (val, key) ->
								_.includes key, "#name."
							[0 to (state.arrLen[name] or docLen or 0)]map (num) ->
								iter = "#{_.replace j.name, \$, ''}#num"
								inputTypes(iter, j)[j?autoform?type or \other]!
						m \p.help.is-danger, error if error

		view: -> m \form, attr.form,
			m \.row, usedFields.map (i) ->
				type = theSchema(i)?autoform?type or \other
				inputTypes(i, theSchema i)[type]!

			m \.row,
				m \.col, m \input.button.is-primary,
					type: \submit
					value: opts?buttonContent
					class: opts?buttonClasses
				m \.col, m \input.button.is-warning,
					type: \reset
					value: opts?reset?content
					class: opts?reset?classes

	@autoTable = (opts) ->
		attr =
			rowEvent: (doc) ->
				onclick: -> opts.rowEvent.onclick doc
				ondblclick: -> opts.rowEvent.ondblclick doc

		view: -> m \table.table,
			m \thead,
				m \tr, opts.fields.map (i) ->
					m \th, _.startCase i
			m \tbody, opts.collection.find!fetch!map (i) ->
				m \tr, attr.rowEvent(i), opts.fields.map (j) ->
					m \td, i[j]
