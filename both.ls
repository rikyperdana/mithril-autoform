coll.contacts = new Meteor.Collection \contacts
coll.contacts.allow do
	insert: -> true
	update: -> true
schema.contacts = new SimpleSchema do
	name: type: String, label: \Nama, autoform: afFormGroup: class: 'col m6'
	address: type: String
	mobile: type: Number
	marital:
		type: Number
		optional: true
		autoform:
			type: \radio
			options: [
				value: 1, label: \Single
			,
				value: 2, label: \Engaged
			,
				value: 3, label: \Married
			]
	work:
		type: String
		optional: true
		allowedValues: <[ business government ]>
		autoform: type: \select
	date:
		type: Date
		label: 'Date of birth'
	hobbies:
		type: Array
		autoform: type: \checkbox, options: [
			value: 1, label: \coding
		,
			value: 2, label: \friends
		,
			value: 3, label: \praying
		]
	'hobbies.$': type: String
