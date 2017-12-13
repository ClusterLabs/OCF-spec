# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

inc-check-perl:
	@printf '%s' 'checking use of ${INC_FILE} from a script under Perl interpreter (${PERL})...'
	@printf '%s\n%s\n%s\n%s\n' \
	  'use warnings; use strict;' \
	  'require "${INC_FILE}";' \
	  'our $${${INC_CHECK_VAR_STR}};' \
	  'print $${${INC_CHECK_VAR_STR}};' \
	  | $(PERL) "-I$(CURDIR)" - | grep -Fq '${INC_CHECK_VAL_STR}' \
	&& printf '%s\n' ' OK'

$(call inc_get_dumpsrc,perl):
	@printf '%s\n%s\n%s\n' \
	  'use warnings; use strict;' \
	  'print "# $@\n";' \
	  'require "${INC_FILE}";' > $@-t
	@for var in ${INC_DUMPVARS_STR} ${INC_DUMPVARS_INT}; do \
	  printf '%s%s\n' "our \$${$${var}};" \
	    "print \"$${var}=\$${$${var}}\\n\";" >> $@-t; \
	  done
	@mv $@-t $@
inc-dump-perl:
	@$(PERL) "-I$(CURDIR)" $<
