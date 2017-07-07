out = console.log
cheerio = require 'cheerio'
request = require 'request'

getLinks = (url, callb)->
	# linksMap, linksFilter, etc...
	res = []
	await request url, defer err, resp, html
	return out err if err
	$ = cheerio.load html
	$('a').each (i, e)=>
		ref = $(e).attr 'href'
		res.push ref
	callb res

parseEmails = (url, callb)->
	await request url, defer err, resp, html
	return out err if err
	callb html.match(
		/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/ig)

bfs = ({ root, path, visit, linkP, done, running })->
	# Map function fn to all connected nodes.
	# linkP (optional) is tested against links to proceed.
	# running determines when to stop the crawler.
	queue = []
	visited = {}
	queue.push path
	while queue.length
		break if not running.run
		node = queue.shift()
		continue if visited[node]
		visited[node] = true
		visit root:root, path:node
		url = makeUrl root, node
		await getLinks url, defer links
		for link in links
			# out "Visited #{link}?", visited[link]
			continue if not link
			continue if link.startsWith 'http'
			continue if visited[link]
			if linkP
				# out "^^^ linkP #{link}?", linkP link
				continue if not linkP link
			queue.push link
	done()

dfsStack = ({ root, path, visit })->
	stack = []
	visited = {}
	stack.push path
	while stack.length
		node = stack[stack.length-1]
		visited[node] = true
		out 'stack peak', node
		await getLinks makeUrl(root, path), defer links
		if not links then stack.pop() # Pop to unvisited
		for link in links
			if link and not visited[link]
				stack.push link
				visited[link] = true

makeUrl = (root, node)->
	if node.startsWith '/' then node = node.slice 1
	if root.endsWith '/'
		root = root.substring 0, root.length-2
	"#{root}/#{node}"

bfsP = ({ root, path, visit, predicate })->
	# Map function fn to all connected nodes.
	# Stop search if predicate returns false.

# BFS that takes multi out of queue

dfs = ({root, path, visit, linkP, speed})->
	visited ={}
	i = 0

	dfsclj = ({ root, path, visit })->
		visit { root:root, path:path }
		url = "#{root}#{path}"
		await getLinks url, defer links
		# if linkP then links = links.filter linkP
		links.map (link)->
			return if not link
			return if visited[link]
			if linkP
				return if not linkP link
			visited[link] = true
			await sleep speed, defer()
			dfsclj {root:root, path:link, visit:visit}

	dfsclj {root:root, path:path, visit: visit}

sleep = (ms, callb)->
	setTimeout callb, ms

module.exports =
	getLinks: getLinks
	parseEmails: parseEmails
	bfs: bfs
	bfsP: bfsP
	dfs: dfs
	makeUrl: makeUrl
	sleep: sleep
