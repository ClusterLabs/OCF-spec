# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

ifndef COMMON_INCLUDE_GUARD
COMMON_INCLUDE_GUARD = 1

ALL_PREREQS =
CLEAN_FILES =

all: ${ALL_PREREQS}

clean:
	rm -f -- ${CLEAN_FILES}

.PHONY: all clean

endif
