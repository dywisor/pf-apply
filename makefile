# compat bits for combined GNU/BSD make targets, do not use them in this file
S    := ${.CURDIR}
O     = .
O_OBJ = $(O)/src
# ---

PHONY =

PHONY += all
all: pf-apply

USE_OPENBSD ?= 1

.include "mk/install_vars.mk"
.include "mk/prj.mk"

.include "mk/compile_c_opts.mk"

.include "mk/warnflags_base.mk"

.if ${NO_WERROR} != 1
.include "mk/warnflags_werror.mk"
.endif

.if ${STATIC} == 1
.include "mk/static.mk"
.endif

.if ${HARDEN} == 1
.include "mk/c_harden.mk"
.endif

.include "mk/compile_c.mk"
.include "mk/obj_defs.mk"

.include "mk/common_targets.mk"


ODEP_PF_APPLY := ${OBUNDLE_APP_PF_APPLY:%=src/%.o}

.SUFFIXES: .c .o
.c.o:
	${MKDIRP} -- ${@D}
	${COMPILE_C} ${.IMPSRC} -o ${@}

pf-apply: ${ODEP_PF_APPLY}
	$(LINK_O) ${.ALLSRC} -o ${@}

.PHONY: ${PHONY}
