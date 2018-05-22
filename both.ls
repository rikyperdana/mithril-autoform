coll.contacts = new Meteor.Collection \contacts
coll.contacts.allow insert: -> true
schema.contacts =
	name: type: String, label: \Nama
	address: type: String
	mobile: type: Number
