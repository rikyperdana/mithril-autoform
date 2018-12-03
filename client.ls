if Meteor.isClient

	front =
		view: -> m \.container,
			m \h5.title, 'Contact Form'
			m autoForm do
				schema: schema.contacts
				collection: coll.contacts
				type: \insert # \insert or \update or \method or 'update-pushArray'
				id: \contactForm
				buttonContent: \Save
				buttonClasses: 'waves-effect blue'
				# fields: <[ name mobile ]>
				# omitFields: <[ address ]>
				meteormethod: \consolelog
				doc: state.contactForm
				# scope: \siblings
				# autosave: true
				columns: 3
				hooks:
					before: (doc, cb) -> cb doc
					after: (doc) -> console.log \after, doc
			m \table.table,
				m \thead, m \tr, <[name address mobile work]>map (i) -> m \th, _.startCase i
				m \tbody, coll.contacts.find!fetch!map (i) -> m \tr,
					onclick: -> state.contactForm = i
					ondblclick: -> console.log \doubleClicked, i
					<[name address mobile work]>map (j) -> m \td, _.startCase i[j]

	Meteor.subscribe \coll, \contacts, onReady: ->
		m.mount document.body, front
