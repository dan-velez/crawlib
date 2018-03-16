# Breadth first search web crawler that renders pages with JS.
# Fork of bfsJS. Handles cross origin links.

requestz = require '../requestz.iced'
parseLinks = require '../crawlib/parse-links.iced'
sleep = require '../crawlib/sleep.iced'
makeUrl = require './make-url.iced'

bfs = ({ root, path, filter, parse,
	delay, control, header })->

	queue = []
	visited = {}
	queue.push path

	while queue.length
		return if not control.running
		if delay then await sleep delay, defer()
		node = queue.shift()

		# Construct the url. If it is a crossorigin, follow it.
		if node.startsWith 'http' then url = node
		else url = makeUrl root, node

		await requestz url, defer html
		if parse and html then parse { html, url, node }

		# Retrieve links only if this site is from the same domain.
		# I.e., crawler will only go 1 level deep for cross origin
		# visits.

		if url.includes root
			links = parseLinks html

			links = links.filter (l)-> not visited[l]

			if filter then links = links.filter filter

			for link in links
				if not visited[link]
					queue.push link
					visited[link] = true

module.exports = bfs
# test program ------------------------------------------------#
###
parseEmails = require './parse-emails.iced'

extractName = (path)->
	path.split('/')[3]

visited = {}

bfsJS
	root: 'http://google.com'
	path: '/search?q=miami+software+email'
	control: running:true

	parse: ({ html, url })->
		console.log 'visiting', url
		emails = parseEmails html
		if emails
			for email in emails
				console.log '\n'
				console.log 'lead found'
				console.log { email }

	filter: (l)->
		true
###
