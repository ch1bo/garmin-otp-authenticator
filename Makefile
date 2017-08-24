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

%_test.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES) $(TESTS)
	monkeyc -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) --unit-test $(SOURCES) $(TESTS)

%.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) $(SOURCES)
