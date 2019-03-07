ZIP=zip
RM=rm
VERSION=1.1.3
MOD_BASE_NAME=Camera-san
MOD_VERSIONED_NAME=${MOD_BASE_NAME}_${VERSION}
OUTPUT=${MOD_VERSIONED_NAME}.zip

.PHONY: all
all: setup

.PHONY: setup
setup: ${OUTPUT}

${OUTPUT}:
	${ZIP} -r ${OUTPUT} info.json changelog.txt control.lua 

.PHONY: clean
clean:
	${RM} -f ${OUTPUT}
	${RM} -rf ${MOD_VERSIONED_NAME}
