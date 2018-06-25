# Basic DocBook mangling makefile. 
#
# 

BASENAME=resource-agent-api
GRAMMAR=ra-api.rng
TEST_FILES=ra-metadata-example-1.0.xml ra-metadata-example.xml

.PHONY: all clean

%.html: %.md
	pandoc -f markdown -o $@ $^

%.pdf: %.md
	pandoc -f markdown -o $@ $^

all: $(BASENAME).pdf $(BASENAME).html

clean:
	rm $(BASENAME).pdf $(BASENAME).html||true

check: $(GRAMMAR) $(TEST_FILES)
	xmllint --relaxng $(GRAMMAR) --noout $(TEST_FILES)
