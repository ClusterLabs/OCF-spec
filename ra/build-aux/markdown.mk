include ../build-aux/common.mk

APIDOC_NAME = resource-agent-api

%.html: %.md
	pandoc -f markdown -o $@ $^

%.pdf: %.md
	pandoc -f markdown -o $@ $^

ALL_PREREQS += ${APIDOC_NAME}.pdf ${APIDOC_NAME}.html
CLEAN_FILES += ${APIDOC_NAME}.pdf ${APIDOC_NAME}.html
