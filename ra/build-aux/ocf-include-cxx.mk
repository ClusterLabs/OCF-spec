# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

inc-check-cxx:
	@printf '%s' 'checking use of ${INC_FILE} from a C++ program...'
	@printf '%s\n%s\n%s\n%s\n' \
	  '#include <iostream>' \
	  '#include <string>' \
	  '#include <${INC_FILE}>' \
	  'int main(void){std::cout << ${INC_CHECK_VAR_STR} << std::endl;return 0;}' \
	  | $(CXX) -I. -ocxx.test -xc++ - \
	&& ./cxx.test | grep -Fq '${INC_CHECK_VAL_STR}' \
	&& printf '%s\n' ' OK'
INC_CHECKFILES += cxx.test

$(call inc_get_dumpsrc,cxx):
	@printf '%s\n%s\n%s\n%s\n%s\n' \
	  '#include <iostream>' \
	  '#include <string>' \
	  '#include <${INC_FILE}>' \
	  'int main(void){' \
	  '    printf("# $@\n");' > $@-t
	@for var in ${INC_DUMPVARS_STR} ${INC_DUMPVARS_INT}; do \
	  printf '%s%s\n' "    std::cout << \"$${var}\" << '=' << $${var}" \
	    " << std::endl;" >> $@-t; \
	  done
	@printf '%s\n%s\n' \
	  'return 0;' \
	  '}' >> $@-t
	@mv $@-t $@
inc-dump-cxx:
	@$(CXX) -I. -ocxx.dump $<
	@./cxx.dump
INC_DUMPFILES += cxx.dump
