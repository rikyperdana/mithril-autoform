if Meteor.isClient

	m.render document.body, m \.container,
		m \h5, 'Contact Form'
		autoForm do
			schema: schema.contacts
			collection: coll.contacts
			type: \insert
			id: \contactForm
			buttonContent: \Simpan
			buttonClasses: 'waves-effect blue'
			# fields: <[ name address ]>
			omitFields: <[ address ]>
