install: gumbo.h
	pwd

gumbo.h: lib
	echo '#include "gumbo-parser/src/gumbo.h"' | gcc -E - | grep -v '^#' > gumbo.h

lib: gumbo-parser
	cd gumbo-parser && chmod +x ./autogen.sh
	cd gumbo-parser && env -i ./autogen.sh
	cd gumbo-parser && env -i ./configure
	cd gumbo-parser && env -i make
	ln -s gumbo-parser/.libs lib

gumbo-parser:
	git clone https://github.com/google/gumbo-parser.git

clean:
	rm -rf gumbo-parser lib gumbo.h
