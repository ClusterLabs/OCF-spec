# Basic DocBook mangling makefile. 
#
# 

BASENAME=resource-agent-api

DOCBOOK2HTML=docbook2html -u -d ../docbook-utils.dsl\#html

DOCBOOK2PS=docbook2ps -u -d ../docbook-utils.dsl\#print

%.html: %.xml
	$(DOCBOOK2HTML) $^

%.ps: %.xml
	$(DOCBOOK2PS) $^

%.pdf: %.ps
	ps2pdf $^

clean:
	rm $(BASENAME).pdf $(BASENAME).ps $(BASENAME).html||true