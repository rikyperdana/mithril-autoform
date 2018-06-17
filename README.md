
## Quickstart
=============
```
git clone https://github.com/rikyperdana/mithril-autoform
cd mithril-autoform
meteor npm install
meteor
```
And head to http://localhost:3000

## Description
==============
This is a reverse-engineered version of aldeed:autoform, a meteor package that helps developers auto-create
form and it's functionality simply by defining a collection's schema. Most used features of aldeed:autoform
can be found in this repo. So, if you are already familiar with aldeed:autoform, you'll know how to use this repo


aldeed:autoform are built specifically for meteor and use blaze templating engine for front-end renderer. While
people are steadily moving to vdom turf, it's not easy to find a comparable auto form generator for latest
stacks such as react, vuejs, or other vdom libs. I've worked with mithriljs for couple of projects and decided
to create an aldeed:autoform alike library to help me deal with forms, and hope it helps you too.

## How to use
=============
You can remove (client, server, both).ls and replace it with your own `myCode.ls` like these:
```
myColl = new Meteor.Collection \myColl
mySchema = new SimpleSchema do
	name: type: String
	age: type: Number
	address: type: String

if Meteor.isClient
	m.mount document.body, view: ->
		m \.row, m autoForm do
			collection: myColl
			schema: mySchema
			type: \insert
			id: \myForm
```
On browser it will render a form that contains the specified fields with insert behavior and you can test it
right away. Once the values submited, you can check `meteor mongo` in your terminal to see the inserted data.

## APIs

## Known Issues
* Continuous m.redraw! makes the rendered input-field don't behave like the materializecss used to

## Further Development
* Inclusion of autoTable generator

## Contribution
You can freely fork this repo and get or make the best out of it.