all: index.html main.js

%.html: %.jade
	jade --pretty $<

%.js: %.coffee
	coffee -c $<

