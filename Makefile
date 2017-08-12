MANIFEST=manifest.xml
RESOURCES=res/resources.xml
SOURCES=$(wildcard src/*.mc)
KEY=signing-key.der

build: build/authenticator.prg

start: build/authenticator.prg
	connectiq &
	monkeydo build/authenticator.prg vivoactive_hr

%.prg: $(KEY) $(MANIFEST) $(RESOURCES) $(SOURCES)
	monkeyc -o $@ -y $(KEY) -m $(MANIFEST) -z $(RESOURCES) $(SOURCES)
