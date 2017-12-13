# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

inc-check-go:
	@printf '%s' 'checking use of ${INC_FILE} from a (C)Go program...'
	@printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
	  'package main' \
	  'import "fmt"' \
	  '// #cgo  CPPFLAGS: -I$${SRCDIR} -DOCF_CGO' \
	  '// /* https://github.com/golang/go/issues/18720' \
	  '//    The workaround is to assign the macro into a C variable or const' \
	  '//    and then use them in Go.' \
	  '//    -- we can come up with something better relying on OCF_CGO macro */' \
	  '// #include <${INC_FILE}>' \
	  '// const char const * ocf_str = ${INC_CHECK_VAR_STR};' \
	  'import "C"' \
	  'func main() {' \
	  '    fmt.Println(C.GoString(C.ocf_str))' \
	  '}' > go.test.go \
	  && $(GO) build go.test.go \
	&& ./go.test | grep -Fq '${INC_CHECK_VAL_STR}' \
	&& printf '%s\n' ' OK'
INC_CHECKFILES += go.test.go go.test

$(call inc_get_dumpsrc,go):
	@printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
	  'package main' \
	  'import "fmt"' \
	  '// #cgo  CPPFLAGS: -I -DOCF_CGO' \
	  '// /* https://github.com/golang/go/issues/18720' \
	  '//    The workaround is to assign the macro into a C variable or const' \
	  '//    and then use them in Go.' \
	  '//    -- we can come up with something better relying on OCF_CGO macro */' \
	  '// #include <${INC_FILE}>' > $@-t
	@for var in ${INC_DUMPVARS_STR}; do \
		printf '%s%s\n' "// const char const * " \
		  "$$(echo "$${var}" | tr '[:upper:]' '[:lower:]') = $${var};" \
	          >> $@-t; \
	  done
	@for var in ${INC_DUMPVARS_INT}; do \
		printf '%s%s\n' "// const int " \
		  "$$(echo "$${var}" | tr '[:upper:]' '[:lower:]') = $${var};" \
	          >> $@-t; \
	  done
	@printf '%s\n%s\n%s\n' \
	  'import "C"' \
	  'func main() {' \
	  'fmt.Println("# $@")' >> $@-t
	@for var in ${INC_DUMPVARS_STR}; do \
		printf '%s%s\n' "    fmt.Printf(\"%s=%s\n\", \"$${var}\"," \
		  " C.GoString(C.$$(echo "$${var}" | tr '[:upper:]' '[:lower:]')))" \
		  >> $@-t; \
	  done
	@for var in ${INC_DUMPVARS_INT}; do \
		printf '%s%s\n' "    fmt.Printf(\"%s=%d\n\", \"$${var}\"," \
		  " C.$$(echo "$${var}" | tr '[:upper:]' '[:lower:]'))" \
		  >> $@-t; \
	  done
	@printf '%s\n' '}' >> $@-t
	@mv $@-t $@
inc-dump-go:
	@$(GO) build -o go.dump $<
	@./go.dump
INC_DUMPFILES += go.dump
