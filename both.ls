coll.contacts = new Meteor.Collection \contacts
coll.contacts.allow do
	insert: -> true
	update: -> true
schema.contacts = new SimpleSchema do
	name: type: String, label: \Nama, autoform: afFormGroup: class: 'col m8'
	address: type: String
	mobile: type: Number, autoform: afFormGroup: class: 'col m4'
