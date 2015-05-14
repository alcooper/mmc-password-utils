INSTALL		:= install
DESTDIR		:=
ETCDIR		:= /etc

###############################################################################
#
# Normal build rule
#
###############################################################################
all:

###############################################################################
#
# Install everything
#
###############################################################################
install: all
	$(INSTALL) -D mmc-setpw $(DESTDIR)$(ETCDIR)/mmc-setpw
	$(INSTALL) -D -m 0600 mmc-password.db $(DESTDIR)$(ETCDIR)/mmc-password.db
	mkdir -p $(DESTDIR)$(ETCDIR)/request-key.d
	$(INSTALL) -D -m 0644 mmc.conf $(DESTDIR)$(ETCDIR)/request-key.d/mmc.conf
###############################################################################
#
# Clean up
#
###############################################################################
clean:

distclean: clean
