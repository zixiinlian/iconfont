PATH          := ./node_modules/.bin:$(PATH)

# Add local versions of ttf2eot nd ttfautohint to the PATH
PATH := $(PATH):./support/font-builder/support/ttf2eot
PATH := $(PATH):./support/font-builder/support/ttfautohint/frontend
PATH := $(PATH):./support/font-builder/bin


FONTS         += hjicon.font
FONTS					+= hjeditor.font
FONTS         += fontelico.font
FONTS         += awesome-uni.font
FONTS         += entypo
FONTS         += typicons.font
FONTS         += iconic-uni.font
FONTS         += modernpics.font
FONTS         += meteocons.font
FONTS         += mfglabs.font
FONTS         += maki.font
FONTS         += zocial.font
FONTS         += brandico.font
FONTS         += elusive.font
FONTS         += linecons.font
FONTS         += websymbols-uni.font

FONT_CONFIGS   = $(foreach f,$(FONTS),src/${f}/config.yml)

FONT_DIR 			= ./assets/embedded_fonts

help:
	echo "make help           - Print this help"
	echo "make dev-server     - Run dev server with autoreleat on files change"
	echo "make rebuild        - Rebuild embedded fonts"
	echo "make lint           - Lint sources with JSHint"
	echo "make gh-pages       - Build and push the project into gh-pages branch"


rebuild:
	mkdir -p assets/embedded_fonts
	# build single font
	./build_embedded_fonts.js \
		-i $(foreach f,$(FONTS), ./src/${f}) \
		-o $(FONT_DIR)/fontello.svg \
		-c lib/embedded_fonts/client_config.js \
		-s lib/embedded_fonts/server_config.js

	# convert to other formats
	./node_modules/.bin/svg2ttf "$(FONT_DIR)/fontello.svg" "$(FONT_DIR)/fontello.ttf"
	./node_modules/.bin/ttf2eot "$(FONT_DIR)/fontello.ttf" "$(FONT_DIR)/fontello.eot"
	./node_modules/.bin/ttf2woff "$(FONT_DIR)/fontello.ttf" "$(FONT_DIR)/fontello.woff"


dev-server:
	if test ! `which inotifywait` ; then \
		echo "You need 'inotifywait' installed in order to run dev-server." >&2 ; \
		echo "   sudo apt-get install inotify-tools" >&2 ; \
		exit 128 ; \
		fi
	./support/forever.sh


repl:
	if test ! `which socat` ; then \
		echo "You need `socat` installed in order to run repl." >&2 ; \
		echo "   sudo apt-get install socat" >&2 ; \
		exit 128 ; \
		fi
	if test ! -e ./tmp/fontello-repl.sock ; then \
		echo "You need to start fontello server with --repl." >&2 ; \
		echo "   ./fontello server --repl" >&2 ; \
		exit 128 ; \
		fi
	socat - UNIX:./tmp/fontello-repl.sock


lint:
	if test ! `which jshint` ; then \
		echo "You need 'jshint' installed in order to run lint." >&2 ; \
		exit 128 ; \
		fi
	jshint . --show-non-errors


cleanup:
	# cleanup assets
	rm -rf public/assets
	rm -rf .cache

# needed for travis
setup:
	if test ! -e ./config/application.yml ; then \
		cp ./config/application.yml.example ./config/application.yml ; \
		fi


test: cleanup lint
	@NODECA_ENV=test node ./fontello.js migrate --all
	@NODECA_ENV=test NODECA_NOMINIFY=1 ./fontello.js test


todo:
	grep 'TODO' -n -r ./lib 2>/dev/null || test true




#FONTELLO_HOST ?= http://fontello.com
FONTELLO_HOST ?= http://localhost:3000
FONTELLO_DIR  ?= ./assets/icons/src


fontopen:
	@if test ! `which curl` ; then \
		echo 'Install curl first.' >&2 ; \
		exit 128 ; \
		fi
	curl --silent --show-error --fail --output .fontello \
		--form "config=@${FONTELLO_DIR}/config.json" \
		${FONTELLO_HOST}
	x-www-browser ${FONTELLO_HOST}/`cat .fontello`


fontsave:
	@if test ! `which unzip` ; then \
		echo 'Install unzip first.' >&2 ; \
		exit 128 ; \
		fi
	@if test ! -e .fontello ; then \
		echo 'Run `make fontopen` first.' >&2 ; \
		exit 128 ; \
		fi
	rm -rf .fontello.src .fontello.zip
	curl --silent --show-error --fail --output .fontello.zip \
		${FONTELLO_HOST}/`cat .fontello`/get
	unzip .fontello.zip -d .fontello.src
	rm -rf ${FONTELLO_DIR}
	mv `find ./.fontello.src -maxdepth 1 -name 'fontello-*'` ${FONTELLO_DIR}
	rm -rf .fontello.src .fontello.zip



.PHONY: help rebuild dev-setup lint gh-pages todo dev-server repl fontopen
.SILENT: help rebuild dev-setup lint todo
