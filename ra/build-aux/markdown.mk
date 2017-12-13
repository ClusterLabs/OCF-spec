APIDOC_NAME = resource-agent-api

%.html: %.md
	pandoc -f markdown -o $@ $^

%.pdf: %.md
	pandoc -f markdown -o $@ $^

all: ${APIDOC_NAME}.pdf ${APIDOC_NAME}.html

clean:
	rm -f -- ${APIDOC_NAME}.pdf ${APIDOC_NAME}.html

.PHONY: all clean
