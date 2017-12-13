# Copyright 2017 Red Hat, Inc.
# Author: Jan Pokorny <jpokorny@redhat.com>
# SPDX-License-Identifier: MIT

LATEST_VER = $(lastword $(sort $(wildcard *[0-9].[0-9]*)))

include ../build-aux/markdown.mk


# ocf.include: check/dump
include ../build-aux/ocf-include.mk

INC_DUMPVARS_STR = \
	OCF_ROOT_SYS \
	OCF_ROOTDIR_RES
INC_DUMPVARS_INT = \
	OCF_SUCCESS \
	OCF_ERR_GENERIC \
	OCF_ERR_ARGS \
	OCF_ERR_UNIMPLEMENTED \
	OCF_ERR_PERM \
	OCF_ERR_INSTALLED \
	OCF_ERR_CONFIGURED \
	OCF_NOT_RUNNING
INC_CHECK_VAR_STR = OCF_ROOTDIR_RES
INC_CHECK_VAL_STR = resource.d
INC_CHECK_VAR_INT = OCF_NOT_RUNNING
INC_CHECK_VAL_INT = 7
