# Basic DocBook mangling makefile. 
#
# 

BASENAME=resource-agent-api

.PHONY: all clean

%.html: %.md
	pandoc -f markdown -o $@ $^

%.pdf: %.md
	pandoc -f markdown -o $@ $^

all: $(BASENAME).pdf $(BASENAME).html

clean:
	rm $(BASENAME).pdf $(BASENAME).html||true

