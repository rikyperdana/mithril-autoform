if Meteor.isClient

	front = ->
		view: -> m \.container,
			m \h5, 'Contact Form'
			m \.row, m autoForm do
				schema: schema.contacts
				collection: coll.contacts
				type: \insert
				id: \contactForm
				buttonContent: \Simpan
				buttonClasses: 'waves-effect blue'
				# fields: <[ name address ]>
				omitFields: <[ address ]>
			m \.row, m autoTable do
				collection: coll.contacts
				fields: <[ name mobile ]>
				rowEvent: onclick: (e) -> console.log e

	Meteor.subscribe \coll, \contacts, {}, {}, onReady: ->
		m.mount document.body, front!
