install: gumbo.h lib
	rm -rf build
	mkdir -p build/lib
	cp gumbo.lua build/init.lua
	cp gumbo.h build
	cp lib/* build/lib/
	rm -rf /usr/local/share/lua/5.1/gumbo
	mv build /usr/local/share/lua/5.1/gumbo

gumbo.h: lib
	echo '#include "gumbo-parser/src/gumbo.h"' | gcc -E - | grep -v '^#' > gumbo.h

lib: gumbo-parser/Makefile
	cd gumbo-parser && env -i make
	ln -s gumbo-parser/.libs lib

gumbo-parser/Makefile: gumbo-parser/configure
	cd gumbo-parser && ./configure

gumbo-parser/configure: gumbo-parser/autogen.sh
	cd gumbo-parser && sh ./autogen.sh

gumbo-parser/autogen.sh:
	git submodule init
	git submodule update

clean:
	rm -rf gumbo-parser lib gumbo.h
