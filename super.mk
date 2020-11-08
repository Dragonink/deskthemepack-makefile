#NOTE: This file SHOULD only be included in */Makefile. As such, all paths here are relative to these files.

NOOP := $(if $(findstring $(OS),Windows_NT),rem,:)
CHAR_comma := ,

THEMEPACK := $(notdir $(CURDIR))
WALLPAPERS_EXT := jpg jpeg bmp dib tif png
WALLPAPERS := $(sort $(foreach ext,$(WALLPAPERS_EXT),\
	$(wildcard wallpapers/*.$(ext))\
))
ifeq ($(WALLPAPERS),)
$(error No wallpaper included)
endif
DEFAULT_WALLPAPER ?= $(notdir $(firstword $(WALLPAPERS)))
define ICONS_CONFIG :=
user/123
computer/109
network/25
empty_bin/55
full_bin/54
endef
ICONS := $(wildcard icons/*.ico)
$(foreach config,$(ICONS_CONFIG),\
	$(eval icon := $(patsubst %/,%,$(dir $(config))))\
	$(eval ICON-$(icon) := $(if $(findstring icons/$(icon).ico,$(ICONS)),\
		$(icon).ico,\
		%SystemRoot%\System32\imageres.dll$(CHAR_comma)-$(notdir $(config))\
	))\
	$(eval undefine icon)\
)
define CURSORS_SET :=
working.ani
arrow.cur
cross
link.cur
helpsel.cur
beam
unavail.cur
pen.cur
move.cur
nesw.cur
ns.cur
nwse.cur
ew.cur
up.cur
busy.ani
endef
CURSORS := $(strip $(wildcard cursors/*.ani) $(wildcard cursors/*.cur))
$(foreach item,$(CURSORS_SET),\
	$(eval cursor := $(basename $(item)))\
	$(eval cursorfile := $(firstword $(filter cursors/$(cursor).%,$(CURSORS))))\
	$(eval CURSOR-$(cursor) := $(if $(cursorfile),\
		$(cursorfile),\
		$(if $(findstring $(item),$(cursor)),,\
			%SystemRoot%\cursors\aero_$(item)\
		)\
	))\
	$(eval undefine cursor)\
)

#STUB[epic=Makefile] $(call sed-template,<template>,<contents>)
# Replace `{template}` in `$@` by `contents`
define sed-template =
sed -i 's/{$(1)}/$(strip $(subst \,\\,$(2)))/g' $@
endef
$(THEMEPACK).theme :
ifneq ($(OS),Windows_NT)
	cp -u ../template.theme $@
else
	copy /y ..\template.theme $@ 1>NUL
endif
ifdef THEME
	$(call sed-template,name,$(THEME))
else
	$(error Required variable THEME is missing)
endif
ifdef COLORIZATION
	$(call sed-template,colorization,$(COLORIZATION))
else
	$(error Required variable COLORIZATION is missing)
endif
	$(call sed-template,wallpaper,$(DEFAULT_WALLPAPER))
	$(foreach config,$(ICONS_CONFIG),\
		$(eval icon := $(patsubst %/,%,$(dir $(config))))\
		$(call sed-template,icon-$(icon),$(ICON-$(icon))) &&\
		$(eval undefine icon)\
	) $(NOOP)
	$(foreach item,$(CURSORS_SET),\
		$(eval cursor := $(basename $(item)))\
		$(call sed-template,cursor-$(cursor),$(notdir $(CURSOR-$(cursor)))) &&\
		$(eval undefine cursor)\
	) $(NOOP)
	$(call sed-template,cursor_theme,$(if $(CURSORS),$(THEME),Windows default))
	$(call sed-template,cursor_theme_mui,$(if $(CURSORS),$(THEME),@main.cpl$(CHAR_comma)-1020))

directives.ddf :
	$(file > $@)
	$(file >> $@,.Set CabinetNameTemplate=$(THEMEPACK).deskthemepack)
	$(file >> $@,$(THEMEPACK).theme)
	$(foreach config,$(ICONS_CONFIG),\
		$(eval icon := $(patsubst %/,%,$(dir $(config))))\
		$(if $(filter %.ico,$(ICON-$(icon))),\
			$(file >> $@,icons\$(ICON-$(icon)))\
		)\
		$(eval undefine icon)\
	)
	$(foreach item,$(CURSORS_SET),\
		$(eval cursor := $(basename $(item)))\
		$(if $(filter cursors/%.cur cursors/%.ani,$(CURSOR-$(cursor))),\
			$(file >> $@,$(subst /,\,$(CURSOR-$(cursor))))\
		)\
		$(eval undefine cursor)\
	)
	$(file >> $@,.Set DestinationDir=DesktopBackground)
	$(foreach wallpaper,$(WALLPAPERS),\
		$(file >> $@,$(subst /,\,$(wallpaper)))\
	)

$(THEMEPACK).deskthemepack : directives.ddf $(THEMEPACK).theme $(BANNER) $(WALLPAPERS) $(ICONS) $(CURSORS)
	$(MAKECAB) $(MAKECAB_OPTIONS) directives.ddf

dry :
	$(info > $(THEMEPACK))
	$(info w/ COLORIZATION $(COLORIZATION))
	$(info w/ DEFAULT WALLPAPER $(DEFAULT_WALLPAPER))
	$(foreach wallpaper,$(filter-out wallpapers/$(DEFAULT_WALLPAPER),$(WALLPAPERS)),\
		$(info w/ WALLPAPER $(notdir $(wallpaper)))\
	)
	$(foreach config,$(ICONS_CONFIG),\
		$(eval icon := $(patsubst %/,%,$(dir $(config))))\
		$(if $(filter %.ico,$(ICON-$(icon))),\
			$(info w/ ICON $(icon)),\
			$(info w/o ICON $(icon))\
		)\
		$(eval undefine icon)\
	)
	$(foreach cursor,$(CURSORS_SET),\
		$(if $(filter %.cur %.ani,$(CURSOR-$(cursor))),\
			$(info w/ CURSOR $(cursor)),\
			$(info w/o CURSOR $(cursor))\
		)\
	)

clean :
ifneq ($(OS),Windows_NT)
	rm -f directives.ddf $(THEMEPACK).theme $(INTERMEDIATES)
else
	if exist directives.ddf del /s /q directives.ddf
	if exist $(THEMEPACK).theme del /s /q $(THEMEPACK).theme
	$(foreach file,$(INTERMEDIATES),\
		if exist $(file) del /s /q $(file) &&\
	) $(NOOP)
endif

distclean : | clean
ifneq ($(OS),Windows_NT)
	rm -f $(THEMEPACK).deskthemepack
else
	if exist $(THEMEPACK).deskthemepack del /s /q $(THEMEPACK).deskthemepack
endif

.SILENT : dry clean distclean
.PHONY : dry clean distclean
.INTERMEDIATE : $(INTERMEDIATES) directives.ddf $(THEMEPACK).theme
.DEFAULT_GOAL := $(THEMEPACK).deskthemepack
