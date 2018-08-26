if Meteor.isClient

	front =
		view: -> m \.container,
			m \h5.title, 'Contact Form'
			m autoForm do
				schema: schema.contacts
				collection: coll.contacts
				type: \update # \insert or \update or \method or 'update-pushArray'
				id: \contactForm
				buttonContent: \Simpan
				buttonClasses: 'waves-effect blue'
				# fields: <[ name mobile ]>
				# omitFields: <[ address ]>
				meteormethod: \consolelog
				doc: state.contactForm
				# scope: \siblings
				# autosave: true
				hooks:
					before: (doc, cb) -> cb doc
					after: (doc) -> console.log \after, doc
			m autoTable do
				collection: coll.contacts
				fields: <[ name mobile address marital work ]>
				rowEvent:
					onclick: (doc) -> state.contactForm = doc
					ondblclick: (doc) -> alert JSON.stringify doc

	Meteor.subscribe \coll, \contacts, {}, {}, onReady: ->
		m.mount document.body, front
