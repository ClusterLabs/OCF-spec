# Basic DocBook mangling makefile. 
#
# 

BASENAME=resource-agent-api
GRAMMAR=ra-api.rng
TEST_FILES=ra-metadata-example.xml

.PHONY: all clean

%.html: %.md
	pandoc -f markdown -o $@ $^

%.pdf: %.md
	pandoc -f markdown -o $@ $^

all: $(BASENAME).pdf $(BASENAME).html

clean:
	rm -f $(BASENAME).pdf $(BASENAME).html

check: $(GRAMMAR) $(TEST_FILES)
	xmllint --relaxng $(GRAMMAR) --noout $(TEST_FILES)
