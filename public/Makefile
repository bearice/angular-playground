COFFEE=../node_modules/coffee-script/bin/coffee
JADE=../node_modules/jade/bin/jade.js
BOWER=../node_modules/bower/bin/bower
GULP=../node_modules/gulp/bin/gulp.js

SCRIPTS=$(shell find . -name \*.coffee)
TEMPLATES=$(patsubst %.jade,%.html,$(shell find . -name \*.jade))

all: bower_components app.js $(TEMPLATES)

app.js: $(TARGETS) gulpfile.coffee
	$(GULP) app.js

bower_components: bower.json
	$(BOWER) install --verbose --allow-root
	touch bower_components

clean:
	rm -rf $(TEMPLATES) app.js

dist-clean: clean
	rm -rf bower_components

%.html: %.jade
	$(JADE) --pretty $<

%.js: %.coffee
	$(COFFEE) -c -m $<

