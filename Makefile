INSTALL		:= install
DESTDIR		:=
SPECFILE	:= keyutils.spec
ETCDIR		:= /etc
BINDIR		:= /bin
SBINDIR		:= /sbin
SHAREDIR	:= /usr/share/keyutils

###############################################################################
#
# Current version
#
###############################################################################
MAJOR		:= 1
MINOR		:= 1
VERSION		:= $(MAJOR).$(MINOR)

TARBALL		:= mmc-password-utils-$(VERSION).tar
ZTARBALL	:= $(TARBALL).bz2

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

###############################################################################
#
# Generate a tarball
#
###############################################################################
$(ZTARBALL):
	git archive --prefix=mmc-password-utils-$(VERSION)/ --format tar -o $(TARBALL) HEAD
	bzip2 -9 $(TARBALL)

tarball: $(ZTARBALL)

###############################################################################
#
# Generate an RPM
#
###############################################################################
SRCBALL	:= rpmbuild/SOURCES/$(TARBALL)

BUILDID	:= .local
dist	:= $(word 2,$(shell grep "%dist" /etc/rpm/macros.dist))
release	:= $(word 2,$(shell grep ^Release: $(SPECFILE)))
release	:= $(subst %{?dist},$(dist),$(release))
release	:= $(subst %{?buildid},$(BUILDID),$(release))
rpmver	:= $(VERSION)-$(release)
SRPM	:= rpmbuild/SRPMS/keyutils-$(rpmver).src.rpm

RPMBUILDDIRS := \
		--define "_srcrpmdir $(CURDIR)/rpmbuild/SRPMS" \
		--define "_rpmdir $(CURDIR)/rpmbuild/RPMS" \
		--define "_sourcedir $(CURDIR)/rpmbuild/SOURCES" \
		--define "_specdir $(CURDIR)/rpmbuild/SPECS" \
		--define "_builddir $(CURDIR)/rpmbuild/BUILD" \
		--define "_buildrootdir $(CURDIR)/rpmbuild/BUILDROOT"

RPMFLAGS := \
	--define "buildid $(BUILDID)"

rpm:
	mkdir -p rpmbuild
	chmod ug-s rpmbuild
	mkdir -p rpmbuild/{SPECS,SOURCES,BUILD,BUILDROOT,RPMS,SRPMS}
	git archive --prefix=keyutils-$(VERSION)/ --format tar -o $(SRCBALL) HEAD
	bzip2 -9f $(SRCBALL)
	rpmbuild -ts $(SRCBALL).bz2 --define "_srcrpmdir rpmbuild/SRPMS" $(RPMFLAGS)
	rpmbuild --rebuild $(SRPM) $(RPMBUILDDIRS) $(RPMFLAGS)

rpmlint: rpm
	rpmlint $(SRPM) $(CURDIR)/rpmbuild/RPMS/*/keyutils-{,libs-,libs-devel-,debuginfo-}$(rpmver).*.rpm

