TARGETS=$(patsubst %.coffee,%.js,$(shell find . -name \*.coffee))
TARGETS+=$(patsubst %.jade,%.html,$(shell find . -name \*.jade))

all: $(TARGETS)

%.html: %.jade
	jade --pretty $<

%.js: %.coffee
	coffee -c $<

