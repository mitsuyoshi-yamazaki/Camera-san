ZIP=zip
RM=rm
VERSION=1.1.2
MOD_BASE_NAME=Camera-san
MOD_VERSIONED_NAME=${MOD_BASE_NAME}_${VERSION}
OUTPUT=${MOD_VERSIONED_NAME}.zip

LUACHECK_CMD=docker run --rm -v=${PWD}:/lua:ro tei1988/luacheck:0.23.0-alpine3.9 luacheck

.PHONY: all
all: setup

.PHONY: setup
setup: ${OUTPUT}

.PHONY: check
check:
	${LUACHECK_CMD} ${MOD_BASE_NAME}

${OUTPUT}: ${MOD_VERSIONED_NAME}
	${ZIP} -r $@ $<
	${RM} -r $<

${MOD_VERSIONED_NAME}:
	cp -r ${MOD_BASE_NAME} $@

.PHONY: clean
clean:
	${RM} -f ${OUTPUT}
	${RM} -rf ${MOD_VERSIONED_NAME}

.PHONY: install
install:
	cp -f ${OUTPUT} ~/Library/Application\ Support/factorio/mods/
