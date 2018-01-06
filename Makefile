MANIFEST ?= manifest.xml
RESOURCES ?= res/resources.xml
SOURCES ?= $(wildcard src/*.mc)
TESTS ?= $(wildcard test/*.mc)
KEY ?= signing-key.der

.PHONY: build
build: build/authenticator.prg

start: build/authenticator.prg
	connectiq &
	monkeydo build/authenticator.prg vivoactive_hr

.PHONY: test
test: build/authenticator_test.prg
	connectiq &
	monkeydo build/authenticator_test.prg vivoactive_hr -t $(TEST_ARGS)

GIT_VERSION=$(shell git describe HEAD --always)
release: build/authenticator-$(GIT_VERSION).iq build/authenticator_release.prg

%_test.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES) $(TESTS)
	monkeyc -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) --unit-test $(SOURCES) $(TESTS)

%_release.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -r -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) $(SOURCES)

%.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) $(SOURCES)

%.iq: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -e -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) $(SOURCES)

clean:
	rm -rf build/
