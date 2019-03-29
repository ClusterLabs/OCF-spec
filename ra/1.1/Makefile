# Basic DocBook mangling makefile. 
#
# 

DOCUMENTS=resource-agent-api resource-agent-metadata

.PHONY: all clean

%.html: %.md
	pandoc -f markdown -o $@ $^

%.pdf: %.md
	pandoc -f markdown -o $@ $^

all: $(DOCUMENTS:%=%.pdf) $(DOCUMENTS:%=%.html)

clean:
	rm -f $(DOCUMENTS:%=%.pdf) $(DOCUMENTS:%=%.html)

