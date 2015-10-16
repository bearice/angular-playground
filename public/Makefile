COFFEE=../node_modules/coffee-script/bin/coffee
JADE=../node_modules/jade/bin/jade.js
BOWER=../node_modules/bower/bin/bower

TARGETS=$(patsubst %.coffee,%.js,$(shell find . -name \*.coffee))
TARGETS+=$(patsubst %.jade,%.html,$(shell find . -name \*.jade))

all: bower_components $(TARGETS)

bower_components: bower.json
	$(BOWER) install --verbose --allow-root
	touch bower_components

clean:
	rm -rf $(TARGETS)

%.html: %.jade
	$(JADE) --pretty $<

%.js: %.coffee
	$(COFFEE) -c $<

