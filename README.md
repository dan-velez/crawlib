## About
`crawlib` exports useful search functions for web crawling, including a breadth first search and depth first search implementation.
## Installation
```
npm i --save crawlib
```
## Usage
```coffeescript
crawler = require 'crawlib'

runner = # Controls the flow of the crawler.
	run: false
    
crawlib.bfs
	root: 'http://twitter.com'
    path: '/'
    visit: ({ root, path })-> console.log 'visiting', path
    running: runner.run # Switch off to stop crawling.
    linkP: (link)-> link? and link.includes 'tweet'
    done: ->
```
## API
```coffeescript
crawler.bfs({ root, path, visit, running, done, linkP })
# root    - the domain to crawl. 
# path    - the starting point in the domain to crawl.
# visit   - a function to run on each visited link.
# running - a structure to control the flow of the function.
# done    - a callback to run after search is exhausted.
# linkP   - link predicate. Run on each link and return true to follow.
