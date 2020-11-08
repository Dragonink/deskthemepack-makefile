override MAKEFLAGS += -rR --no-print-directory

# Program to build CAB files, invoked with $(MAKECAB_OPTIONS)
export MAKECAB ?= makecab.exe
# Options to invoke $(MAKECAB) with
# Directive file option MUST be the last option, without its argument
define MAKECAB_OPTIONS ?=
/D Cabinet=ON
/D MaxCabinetSize=0
/D MaxDiskSize=0
/D FolderSizeThreshold=0
/D CabinetFileCountThreshold=0
/D MaxDiskFileCount=0
/D FolderFileCountThreshold=0
/D Compress=ON
/D CompressionType=MSZIP
/D DiskDirectoryTemplate=.
/F
endef
override MAKECAB_OPTIONS := $(strip $(MAKECAB_OPTIONS))
export MAKECAB_OPTIONS
# Intermediate files to be cleaned up
define INTERMEDIATES ?=
setup.inf
setup.rpt
endef
override INTERMEDIATES := $(strip $(INTERMEDIATES))
export INTERMEDIATES

THEMES := $(sort $(patsubst %/Makefile,%,$(wildcard */Makefile)))
DRY-THEMES := $(addprefix dry?,$(THEMES))
CLEAN-THEMES := $(addprefix clean?,$(THEMES))
DISTCLEAN-THEMES := $(addprefix distclean?,$(THEMES))

$(THEMES) : % :
	@$(MAKE) -C $*

all : $(THEMES)

$(DRY-THEMES) : dry?% :
	@$(MAKE) -C $* dry

dry : $(DRY-THEMES)

$(CLEAN-THEMES) : clean?% :
	@$(MAKE) -C $* clean

clean : $(CLEAN-THEMES)

$(DISTCLEAN-THEMES) : distclean?% :
	@$(MAKE) -C $* distclean

distclean : $(DISTCLEAN-THEMES)

define help :=
[help] - Print this help message
dry - Print parameters and included resources for each themepack
all - Build all themepacks
clean - Delete intermediate artifacts
distclean - Delete generated artifacts (including themepacks)

--< THEMEPACKS >--
endef
help :
	$(info $(help))
	$(foreach theme,$(THEMES),$(info $(theme)))

.SILENT : $(DRY-THEMES) dry help
.PHONY : $(THEMES) all $(DRY-THEMES) dry $(CLEAN-THEMES) clean $(DISTCLEAN-THEMES) distclean help
.DEFAULT_GOAL := help
