if Meteor.isClient

	m.render document.body, m \.container, autoForm do
		schema: schema.contacts
		collection: coll.contacts
		type: \insert
		buttonContent: \Simpan
		buttonClasses: 'waves-effect blue'
		# fields: <[ name address ]>
		omitFields: <[ address ]>
