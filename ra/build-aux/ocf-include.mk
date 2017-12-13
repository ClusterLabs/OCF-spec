# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

include ../build-aux/common.mk

INC_FILE = ocf.include


# CHECK/DUMP
#
# Following variables are expected to be delivered externally
# when this makefile is included, presumably from sibling directory:
# - LATEST_VER:
#   latest API version
# - INC_DUMPVARS_STR:
#   symbolic string constants defined in respective ocf.include
# - INC_DUMPVARS_INT:
#   symbolic integral constants defined in respective ocf.include
# - INC_CHECK_VAR_STR:
#   name of picked symbolic string constant from DUMPVARS_STR
# - INC_CHECK_VAL_STR:
#   respective value of CHECK_VAR_STR
# - INC_CHECK_VAR_INT:
#   name of picked symbolic integral constant from DUMPVARS_INT
# - INC_CHECK_VAL_INT:
#   respective value of CHECK_VAR_INT

# compilers/interpreters
GO ?= go
PERL ?= perl
PYTHON ?= python
RUBY ?= ruby
# checkers
SHELLCHECK ?= shellcheck

INC_CHECKFILES =
INC_DUMPFILES =

INC_LANGS =
INC_DUMPSRCS =
INC_CHECKS =
INC_DUMPS =
define INC_ADDLANG =
  INC_LANGS += ${1}
  INC_DUMPSRCS += inc_dump-${1}-${2}
  INC_CHECKS += inc-check-${1}
  INC_DUMPS += inc-dump-${1}
endef
# inc_add_lang(interpreter-holding-variable,lang-name,lang-ext)
inc_add_lang = $(if $(shell which ${${1}} 2>/dev/null),\
               $(eval $(call INC_ADDLANG,${2},${3})),\
	       $(warning skipping language ${2} for blind $$${1} (${${1}})))
$(eval $(call inc_add_lang,CC,c,c))
$(eval $(call inc_add_lang,CXX,cxx,cxx))
$(eval $(call inc_add_lang,GO,go,go))
$(eval $(call inc_add_lang,PERL,perl,pl))
$(eval $(call inc_add_lang,PYTHON,python,py))
$(eval $(call inc_add_lang,RUBY,ruby,rb))
$(eval $(call inc_add_lang,SHELL,shell,sh))

define INC_DUMPSRC =
  include ../build-aux/ocf-include-${1}.mk
  inc-dump-${1}: ${2} ../build-aux/ocf-include-${1}.mk
  ${2}: ../build-aux/ocf-include-${1}.mk
  INC_DUMPFILES += ${2}
endef
inc_get_dumpsrc = inc-dump-${1}.$(patsubst inc_dump-${1}-%,%,$(filter inc_dump-${1}-%, ${INC_DUMPSRCS}))
$(foreach lang,$(INC_LANGS),$(eval $(call INC_DUMPSRC,${lang},$(call inc_get_dumpsrc,${lang}))))

ifneq (,$(shell which ${SHELLCHECK} 2>/dev/null))
_null  :=
_space := $(_null) #
_comma := ,
inc_shellcheck_excl =
inc_shellcheck_excl += SC1001  # 2x This \= will be a regular '=' in this context.
inc_shellcheck_excl += SC1003  # 1x Want to escape a single quote? echo 'This is how it'\''s done'.
inc_shellcheck_excl += SC1078  # 1x Did you forget to close this single quoted string?
inc_shellcheck_excl += SC1079  # 1x This is actually an end quote, but due to next char it looks suspect.
inc_shellcheck_excl += SC2016  # 1x Expressions don't expand in single quotes, use double quotes for that
inc_shellcheck_excl += SC2162  # 2x read without -r will mangle backslashes
inc_shellcheck_excl += SC2182  # 1x This printf format string has no variables. Other arguments are ignored
inc-check-shellcheck:
	@printf '%s' 'checking ${INC_FILE} through ShellCheck ($(SHELLCHECK))...'
	@$(SHELLCHECK) -s sh \
	  -e $(subst ${_space},${_comma},$(strip ${inc_shellcheck_excl})) \
	  -- ${INC_FILE} \
	&& printf '%s\n' ' OK'
INC_CHECKS += inc-check-shellcheck
endif

inc-dump-shellenv: ${INC_FILE}
	@echo "# $@"
	@$(SHELL) $< env
INC_DUMPS += inc-dump-shellenv

inc-check:
	@for target in ${INC_CHECKS}; do \
	  $(MAKE) $${target} $(if $(value VERBOSE),,--no-print-directory) \
	    || exit 1; done
inc-dump:
	@for target in ${INC_DUMPS}; do \
	  $(MAKE) $${target} $(if $(value VERBOSE),,--no-print-directory) \
	    || exit 1; done


# MISCELLANEOUS

inc-README: Makefile
	@printf '%s\n\n' 'String constants defined:' > $@-t;
	@for var in ${INC_DUMPVARS_STR}; do \
	  printf '%s\n' "* $${var}" >> $@-t; \
	  done
	@printf '\n%s\n\n' 'Integral constants defined:' >> $@-t;
	@for var in ${INC_DUMPVARS_INT}; do \
	  printf '%s\n' "* $${var}" >> $@-t; \
	  done
	@mv $@-t $@

inc-mainpage.dox:
	@printf '%s\n%s\n\n%s\n%s\n' \
	  '/**' '@mainpage The @c ${INC_FILE} documentation' \
	  'Go to the detailed @ref ${INC_FILE} "page".' '*/' > $@;

inc-htmldoc: inc-README inc-mainpage.dox
	@printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
	  'EXAMPLE_PATH = .' \
	  'EXCLUDE_SYMBOLS = OCF_INCLUDE_GUARD _def.*_ __' \
	  'EXPAND_ONLY_PREDEF = YES' \
	  'EXTRACT_ALL = YES' \
	  'GENERATE_LATEX = NO' \
	  'INPUT = ${INC_FILE} inc-mainpage.dox' \
	  'MACRO_EXPANSION = YES' \
	  'OPTIMIZE_OUTPUT_FOR_C = YES' \
	  'OUTPUT_DIRECTORY = inc-doc' \
	  'PROJECT_NAME = ${INC_FILE}' \
	  'PROJECT_NUMBER = ${LATEST_VER}' \
	  'SORT_MEMBER_DOCS = NO' | doxygen -

CLEAN_FILES += ${INC_CHECKFILES} ${INC_DUMPFILES} inc-README inc-mainpage.dox
CLEAN_DIRS += inc-doc

.PHONY: inc-check ${INC_CHECKS} \
	inc-dump ${INC_DUMPS} \
	inc-htmldoc
