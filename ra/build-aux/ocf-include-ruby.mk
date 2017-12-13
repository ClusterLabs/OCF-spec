# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

inc-check-ruby:
	@printf '%s' 'checking use of ${INC_FILE} from a script under Ruby interpreter (${RUBY})...'
	@printf '%s\n%s\n' \
	  'load "${INC_FILE}"' \
	  'puts @${INC_CHECK_VAR_STR}' \
	  | $(RUBY) | grep -Fq '${INC_CHECK_VAL_STR}' \
	&& printf '%s\n' ' OK'

$(call inc_get_dumpsrc,ruby):
	@printf '%s\n%s\n' \
	  'load "${INC_FILE}"' \
	  'puts "# $@"' > $@-t;
	@for var in ${INC_DUMPVARS_STR} ${INC_DUMPVARS_INT}; do \
	  printf '%s\n' "printf \"$${var}=%s\n\", @$${var}" >> $@-t; \
	  done
	@mv $@-t $@
inc-dump-ruby:
	@$(RUBY) $<

