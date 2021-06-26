S := $(CURDIR)

SRC = $(S)/src
MK_INCLUDE = $(S)/mk

O := $(S)/obj
O_OBJ = $(O)/src

PHONY =

PHONY += all
all: pf-apply

USE_OPENBSD ?= 0

include $(MK_INCLUDE)/install_vars.mk
include $(MK_INCLUDE)/prj.mk

include $(MK_INCLUDE)/compile_c_opts.mk

include $(MK_INCLUDE)/warnflags_base.mk

ifneq ($(NO_WERROR),1)
include $(MK_INCLUDE)/warnflags_werror.mk
endif

ifeq ($(STATIC),1)
include $(MK_INCLUDE)/static.mk
endif

ifeq ($(HARDEN),1)
include $(MK_INCLUDE)/c_harden.mk
endif

include $(MK_INCLUDE)/compile_c.mk
include $(MK_INCLUDE)/obj_defs.mk

include $(MK_INCLUDE)/common_targets.mk

include $(MK_INCLUDE)/FIXME_GNU_only.mk


FLATTENED_TARGETS := pf-apply

PHONY += $(FLATTENED_TARGETS)
$(FLATTENED_TARGETS): %: $(O)/%

$(O):
	$(MKDIRP) -- $@

$(O_OBJ):
	$(MKDIRP) -- $@

$(O_OBJ)/%.o: $(SRC)/%.c $(wildcard $(SRC)/%.h) | $(O_OBJ)
	$(MKDIRP) -- $(@D)
	$(COMPILE_C) $< -o $@

$(O)/pf-apply: \
	$(foreach f,$(OBUNDLE_APP_PF_APPLY),$(O_OBJ)/$(f).o $(wildcard $(SRC)/$(f).h)) | $(O)

	$(LINK_O) $(filter-out %.h,$^) -o $@

FORCE:

.PHONY: $(PHONY)
