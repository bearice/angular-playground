COFFEE=../node_modules/coffee-script/bin/coffee
JADE=../node_modules/jade/bin/jade.js
TARGETS=$(patsubst %.coffee,%.js,$(shell find . -name \*.coffee))
TARGETS+=$(patsubst %.jade,%.html,$(shell find . -name \*.jade))

all: $(TARGETS)

clean:
	rm -rf $(TARGETS)

%.html: %.jade
	$(JADE) --pretty $<

%.js: %.coffee
	$(COFFEE) -c $<

