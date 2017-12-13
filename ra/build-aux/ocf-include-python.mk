# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

inc-check-python:
	@printf '%s' 'checking use of ${INC_FILE} from a script under Python interpreter (${PYTHON})...'
	@printf '%s\n%s\n%s\n' \
	  'from imp import load_module as lm, PY_SOURCE as PS' \
	  'm = lm("ocf", open("${INC_FILE}"), "${INC_FILE}", ("py", "r", PS))' \
	  'print(m.${INC_CHECK_VAR_STR})' \
	  | env PYTHONDONTWRITEBYTECODE=1 $(PYTHON) | grep -Fq '${INC_CHECK_VAL_STR}' \
	&& printf '%s\n' ' OK'

$(call inc_get_dumpsrc,python):
	@printf '%s\n%s\n%s\n' \
	  'print ("# $@")' \
	  'from imp import load_module as lm, PY_SOURCE as PS' \
	  'm = lm("ocf", open("${INC_FILE}"), "${INC_FILE}", ("py", "r", PS))' > $@-t
	@for var in ${INC_DUMPVARS_STR} ${INC_DUMPVARS_INT}; do \
	  printf '%s\n' "print (\"$${var}={0}\".format(m.$${var}))" >> $@-t; \
	  done
	@mv $@-t $@
inc-dump-python:
	@env PYTHONDONTWRITEBYTECODE=1 $(PYTHON) $<
