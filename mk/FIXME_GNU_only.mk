PHONY += man
man: $(S)/doc/man/pf-apply.1

# read version from version.h, prereq for sed-editing doc files
$(O)/VERSION: $(SRC)/app/pf-apply/version.h | $(O)
	{ \
		set -e; \
		\
		unset -v PF_APPLY_VER_MAJOR; \
		unset -v PF_APPLY_VER_MINOR; \
		unset -v PF_APPLY_VER_SUFFIX; \
		\
		while read -r a b c; do \
			[ "$${a}" = '#define' ] || continue; \
			case "$${b}" in \
				PF_APPLY_VER_MAJOR) PF_APPLY_VER_MAJOR="$${c}" ;; \
				PF_APPLY_VER_MINOR) PF_APPLY_VER_MINOR="$${c}" ;; \
				PF_APPLY_VER_SUFFIX) \
					if [ "$${c}" = "NULL" ]; then \
						PF_APPLY_VER_SUFFIX=''; \
					else \
						c="$${c#\"}"; c="$${c%\"}"; \
						PF_APPLY_VER_SUFFIX="$${c}"; \
					fi; \
				;; \
			esac; \
		done < $(<); \
		\
		: "$${PF_APPLY_VER_MAJOR:?}"; \
		: "$${PF_APPLY_VER_MINOR:?}"; \
		: "$${PF_APPLY_VER_SUFFIX?}"; \
		\
		> $@ printf '%d.%d%s\n' \
			"$${PF_APPLY_VER_MAJOR}" \
			"$${PF_APPLY_VER_MINOR}" \
			"$${PF_APPLY_VER_SUFFIX}"; \
	}

# sed-edit expressions for doc files
$(O)/sed_edit_doc: $(O)/VERSION | $(O)
	{ set -e; \
		read ver < $(<); \
		\
		printf 's|@%s@|%s|g\n' VERSION "$${ver}"; \
	} > $@

$(S)/doc/man:
	$(MKDIRP) -- $(@)

$(S)/doc/man/%: $(S)/doc/src/man/%.md $(O)/sed_edit_doc | $(S)/doc/man
	sed -r -f $(O)/sed_edit_doc $(<) | pandoc -s -t man > $@
