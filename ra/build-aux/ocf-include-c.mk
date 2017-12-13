# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

#XXX: pragma message foo

inc-check-c:
	@printf '%s' 'checking use of ${INC_FILE} from a C program...'
	@printf '%s\n%s\n%s\n' \
	  '#include <stdio.h>' \
	  '#include <${INC_FILE}>' \
	  'int main(void){printf("%s\n",${INC_CHECK_VAR_STR});return 0;}' \
	  | $(CC) -I. -oc.test -xc - \
	&& ./c.test | grep -Fq '${INC_CHECK_VAL_STR}' \
	&& printf '%s\n' ' OK'
INC_CHECKFILES += c.test

$(call inc_get_dumpsrc,c):
	@printf '%s\n%s\n%s\n%s\n' \
	  '#include <stdio.h>' \
	  '#include <${INC_FILE}>' \
	  'int main(void){' \
	  '    printf("# $@\n");' > $@-t
	@for var in ${INC_DUMPVARS_STR}; do \
	  printf '%s\n' "    printf(\"%s=%s\n\", \"$${var}\", $${var});" >> $@-t; \
	  done
	@for var in ${INC_DUMPVARS_INT}; do \
	  printf '%s\n' "    printf(\"%s=%d\n\", \"$${var}\", $${var});" >> $@-t; \
	  done
	@printf '%s\n%s\n' \
	  'return 0;' \
	  '}' >> $@-t
	@mv $@-t $@
inc-dump-c:
	@$(CC) -I. -oc.dump $<
	@./c.dump
INC_DUMPFILES += c.dump
