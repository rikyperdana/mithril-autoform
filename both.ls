coll.contacts = new Meteor.Collection \contacts
coll.contacts.allow do
	insert: -> true
	update: -> true
schema.contacts = new SimpleSchema do
	name: type: String, label: 'Full Name'
	address: type: String, autoform: afFormGroup: class: 'col m6'
	mobile: type: Number, autoform: afFormGroup: class: 'col m6'
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
		autoValue: (name, allFields) -> new Date!
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
	mood:
		type: Number
		autoform: type: \range
	biography:
		type: String
		autoform: type: \textarea
	family: type: Object
	'family.father': type: String, label: "Father's Name"
	'family.mother': type: String, label: "Mother's Name"
	firstLevel: type: Object
	'firstLevel.secondLevel': type: Object
	'firstLevel.secondLevel.thirdLevel': type: String
	'firstLevel.secondLevel.otherLevel':
		type: String
		allowedValues: <[ love hate ]>
		autoform: type: \select
