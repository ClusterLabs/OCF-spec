# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

inc-check-shell:
	@printf '%s' 'checking use of ${INC_FILE} from a script under shell interpreter (${SHELL})...'
	@printf '%s\n%s\n' \
	  '. "$(CURDIR)/${INC_FILE}"' \
	  'printf "%s\n" "$$${INC_CHECK_VAR_STR}"' \
	  | $(SHELL) | grep -Fq '${INC_CHECK_VAL_STR}' \
	&& printf '%s\n' ' OK'

$(call inc_get_dumpsrc,shell):
	@printf '%s\n%s\n' \
	  'printf "%s\n" "# $@"' \
	  '. "$(CURDIR)/${INC_FILE}"' > $@-t
	@for var in ${INC_DUMPVARS_STR} ${INC_DUMPVARS_INT}; do \
	  printf '%s\n' "printf '%s=%s\n' \"$${var}\" \"\$${$${var}}\"" >> $@-t; \
	  done
	@mv $@-t $@
inc-dump-shell:
	@$(SHELL) $<
