MANIFEST ?= manifest.xml
RESOURCES ?= $(wildcard resources/**/*)
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
	monkeyc -o $@ -w -y $(KEY) -f $(PWD)/monkey.jungle --unit-test

%_release.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -w -r -y $(KEY) -f $(PWD)/monkey.jungle

%.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -w -y $(KEY) -f $(PWD)/monkey.jungle

%.iq: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -e -w -r -y $(KEY) -f $(PWD)/monkey.jungle

clean:
	rm -rf build/
