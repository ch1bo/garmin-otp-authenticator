MANIFEST ?= manifest.xml
RESOURCES ?= $(wildcard resources/**/*)
SOURCES ?= $(wildcard src/*.mc)
TESTS ?= $(wildcard test/*.mc)
KEY ?= signing-key.der

# Test using oldest, supported device (connectiq 2.x)
DEVICE ?= vivoactive_hr

.PHONY: build
build: build/authenticator_$(DEVICE).prg

start: build/authenticator_$(DEVICE).prg
	connectiq &
	monkeydo build/authenticator_$(DEVICE).prg $(DEVICE)

.PHONY: test
test: build/authenticator_$(DEVICE)_test.prg
	connectiq &
	monkeydo build/authenticator_$(DEVICE)_test.prg $(DEVICE) -t $(TEST_ARGS)

GIT_VERSION=$(shell git describe HEAD --always)
release: build/authenticator-$(GIT_VERSION).iq build/authenticator_$(DEVICE)_release.prg

%.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -w -y $(KEY) -f $(PWD)/monkey.jungle -d $(DEVICE)

%_test.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES) $(TESTS)
	monkeyc -o $@ -w -y $(KEY) -f $(PWD)/monkey.jungle --unit-test -d $(DEVICE)

%_release.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -w -r -y $(KEY) -f $(PWD)/monkey.jungle -d $(DEVICE)

%.iq: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -e -w -r -y $(KEY) -f $(PWD)/monkey.jungle

clean:
	rm -rf build/
