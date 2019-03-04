ZIP=zip
RM=rm
VERSION=1.1.2
MOD_BASE_NAME=Camera-san
MOD_VERSIONED_NAME=${MOD_BASE_NAME}_${VERSION}
OUTPUT=${MOD_VERSIONED_NAME}.zip

.PHONY: all
all: setup

.PHONY: setup
setup: ${OUTPUT}

${OUTPUT}: ${MOD_VERSIONED_NAME}
	${ZIP} -r $@ $<
	${RM} -r $<

${MOD_VERSIONED_NAME}:
	cp -r ${MOD_BASE_NAME} $@

.PHONY: clean
clean:
	${RM} -f ${OUTPUT}
	${RM} -rf ${MOD_VERSIONED_NAME}
