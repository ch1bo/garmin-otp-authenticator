MANIFEST=manifest.xml
RESOURCES=res/resources.xml
SOURCES=$(wildcard src/*.mc)
TESTS=$(wildcard test/*.mc)
KEY=signing-key.der

.PHONY: build
build: build/authenticator.prg

start: build/authenticator.prg
	connectiq &
	monkeydo build/authenticator.prg vivoactive_hr

.PHONY: test
test: build/authenticator_test.prg
	connectiq &
	monkeydo build/authenticator_test.prg vivoactive_hr -t

%.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
ifeq (,$(findstring test,$@))
	monkeyc -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) --unit-test $(SOURCES) $(TESTS)
else
	monkeyc -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) $(SOURCES)
endif
