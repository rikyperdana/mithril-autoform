if Meteor.isClient

	front =
		view: -> m \.container,
			m \h5, 'Contact Form'
			m \.row, m autoForm do
				schema: schema.contacts
				collection: coll.contacts
				type: \insert # \insert or \update or \method
				id: \contactForm
				buttonContent: \Simpan
				buttonClasses: 'waves-effect blue'
				# fields: <[ name mobile ]>
				# omitFields: <[ address ]>
				meteormethod: \consolelog
				doc: state.contactForm
				hooks:
					before: (doc, cb) -> cb doc
					after: (doc) -> console.log \after, doc
			m \.row, m autoTable do
				collection: coll.contacts
				fields: <[ name mobile address marital work ]>
				rowEvent:
					onclick: (doc) -> state.contactForm = doc
					ondblclick: (doc) -> alert JSON.stringify doc

	Meteor.subscribe \coll, \contacts, {}, {}, onReady: ->
		m.mount document.body, front
