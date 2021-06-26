SED_EXPRV =
RUN_SED_EXPRV = sed -r $(SED_EXPRV)

PHONY += clean
clean:
	test ! -d '$(O_OBJ)' || find '$(O_OBJ)' -type f -name '*.o' -delete
	test ! -d '$(O_OBJ)' || find '$(O_OBJ)' -depth -type d -empty -delete
	test ! -f '$(O)/pf-apply' || rm -- '$(O)/pf-apply'

PHONY += install
install: install-bin install-man

PHONY += install-bin
install-bin:
	$(DOEXE) -- $(O)/pf-apply $(DESTDIR)$(BINDIR)/pf-apply

PHONY += install-scripts
install-scripts:
#	$(DOEXE) -- $(S_SCRIPTS)/pf-edit $(DESTDIR)$(BINDIR)/pf-edit

PHONY += install-man
install-man:
	$(DOINS) -- $(S)/doc/man/pf-apply.1 $(DESTDIR)$(MANDIR)/man1/pf-apply.1
