# Usage
# $ make all

ZIP=zip
RM=rm
CP=cp
MKDIR=mkdir
VERSION=1.2.3
MOD_BASE_NAME=Camera-san
MOD_VERSIONED_NAME=${MOD_BASE_NAME}_${VERSION}
OUTPUT=${MOD_VERSIONED_NAME}.zip

.PHONY: all
all: setup

.PHONY: setup
setup: ${OUTPUT}

${OUTPUT}:
	if [ -e ${MOD_VERSIONED_NAME} ]; then\
		${RM} -r ${MOD_VERSIONED_NAME};\
	fi
	if [ -e ${OUTPUT} ]; then\
		${RM} ${OUTPUT};\
	fi
	${MKDIR} ${MOD_VERSIONED_NAME}
	${CP} {info.json,changelog.txt,control.lua} ${MOD_VERSIONED_NAME}
	${ZIP} -r ${OUTPUT} ${MOD_VERSIONED_NAME}

.PHONY: clean
clean:
	${RM} -f ${OUTPUT}
	${RM} -rf ${MOD_VERSIONED_NAME}
