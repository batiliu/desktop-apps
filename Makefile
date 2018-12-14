PWD := $(shell pwd)
CURL := curl -L -o

COPY_FILE		= cp -f
COPY_DIR		= cp -f -R
INSTALL_FILE	= $(COPY_FILE) -av
INSTALL_DIR		= $(COPY_DIR)
INSTALL_PROGRAM	= install -m 755 -p

PRODUCT_VERSION ?= 0.0.0
BUILD_NUMBER ?= 0

QT_PATH ?= /opt/qt5
QT_PLUGINS ?= $(QT_PATH)/plugins

END2END_ENCRYPT ?= false

ifeq ($(OS),Windows_NT)
	PLATFORM := win
	EXEC_EXT := .exe
	SHELL_EXT := .bat
	SHARED_EXT := .dll
	LIB_EXT := .lib
	MAKE := nmake
	DEST_DIR ?= ONLYOFFICE/DesktopEditors
	QT_LIBS ?= $(QT_PATH)/bin
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		PLATFORM := linux
		SHARED_EXT := .so*
		SHARED_PREFIX := lib
		SHELL_EXT := .sh
		LIB_EXT := .a
		MAKE := make
		DEST_DIR ?= /opt/onlyoffice/desktopeditors
		QT_LIBS ?= $(QT_PATH)/lib
	endif
endif

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	ARCHITECTURE := 64
endif
ifneq ($(filter %86,$(UNAME_M)),)
	ARCHITECTURE := 32
endif

include win-linux/package/windows/Makefile.mk

QT_ICU ?= $(QT_LIBS)

DEST_CONV_DIR = $(DEST_DIR)/converter
DEST_EDITOR_DIR = $(DEST_DIR)/editors
DEST_PLUGINS_DIR = $(DEST_EDITOR_DIR)/sdkjs-plugins

TARGET := $(PLATFORM)_$(ARCHITECTURE)

CORE_DIR := ../core/build
CORE_BIN_DIR := $(CORE_DIR)/bin/$(TARGET)
CORE_LIB_DIR := $(CORE_DIR)/lib/$(TARGET)

DICT_DIR := ../dictionaries
WEBAPPS_DIR := ../web-apps-pro/deploy
UI_PLUGINS_DIR := ../desktop-sdk/ChromiumBasedEditors/plugins
SDKJS_PLUGINS_DIR := ../sdkjs-plugins

DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/cl?part
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/m?cros
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/oc?
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/ph?toeditor
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/s?mboltable
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/tr?nslate
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/y?utube
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/pluginBase.js
DE_PLUGINS += $(SDKJS_PLUGINS_DIR)/plugins.css

ASCDOCUMENTEDITOR := win-linux/ASCDocumentEditor.build/DesktopEditors$(EXEC_EXT)

TARGETS += $(ASCDOCUMENTEDITOR)

ASCDOCUMENTEDITOR_PRO := $(abspath win-linux/ASCDocumentEditor.pro)

QT_PROJ += ASCDOCUMENTEDITOR

#Template for next statment:
#FOO_MAKE := $(basename $(FOO_PRO)).build/Makefile
#$(FOO): $(FOO_MAKE)
#  cd $(dir $(FOO_MAKE)) && make

define build_proj_tmpl
PROS += $$(basename $$(value $(1)_PRO)).build
$(1)_MAKE := $$(basename $$(value $(1)_PRO)).build/Makefile
$$(value $(1)): $$(value $(1)_MAKE)
	cd $$(dir $$(value $(1)_MAKE)) && $(MAKE);
endef

.PHONY : all bin clean

all: bin

bin: $(ASCDOCUMENTEDITOR)

$(foreach proj, $(QT_PROJ), $(eval $(call build_proj_tmpl, $(proj))))


%.build/Makefile: %.pro
	mkdir -p $(dir $@) && cd $(dir $@) && PRODUCT_VERSION=$(PRODUCT_VERSION) BUILD_NUMBER=$(BUILD_NUMBER) qmake -r $< DEFINES+=_QTVER_DOWNGRADE

clean:
	rm -rf $(TARGETS)
	for i in $(PROS); do \
		if [ -d $$i -a -f $$i/Makefile ]; then \
			cd $$i && $(MAKE) distclean; \
		fi \
	done

install: $(TARGETS)
	mkdir -p $(DEST_DIR)

	$(INSTALL_PROGRAM) $(TARGETS) $(DEST_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/HtmlFileInternal$(EXEC_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)ascdocumentscore$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)ooxmlsignature$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)hunspell$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) ./LICENSE.txt $(DEST_DIR)
	$(INSTALL_FILE) common/package/license/3dparty/3DPARTYLICENSE $(DEST_DIR)

	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5Core$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5Gui$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5Multimedia$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5MultimediaWidgets$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5Network$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5OpenGL$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5PrintSupport$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5Svg$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5Widgets$(SHARED_EXT) $(DEST_DIR)

ifeq ($(PLATFORM),linux)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5DBus$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5X11Extras$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_LIBS)/$(SHARED_PREFIX)Qt5XcbQpa$(SHARED_EXT) $(DEST_DIR)

	$(INSTALL_FILE) $(QT_ICU)/$(SHARED_PREFIX)icuuc$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_ICU)/$(SHARED_PREFIX)icudata$(SHARED_EXT) $(DEST_DIR)
	$(INSTALL_FILE) $(QT_ICU)/$(SHARED_PREFIX)icui18n$(SHARED_EXT) $(DEST_DIR)
endif

	$(INSTALL_DIR) $(QT_PLUGINS)/bearer $(DEST_DIR)
	$(INSTALL_DIR) $(QT_PLUGINS)/imageformats $(DEST_DIR)
	$(INSTALL_DIR) $(QT_PLUGINS)/mediaservice $(DEST_DIR)
	$(INSTALL_DIR) $(QT_PLUGINS)/platforms $(DEST_DIR)
	$(INSTALL_DIR) $(QT_PLUGINS)/playlistformats $(DEST_DIR)
	$(INSTALL_DIR) $(QT_PLUGINS)/printsupport $(DEST_DIR)

ifeq ($(PLATFORM),win)
	rm -f $(DEST_DIR)/**/*.pdb
endif

	mkdir -p $(DEST_DIR)/dictionaries
	$(INSTALL_DIR) $(DICT_DIR)/* $(DEST_DIR)/dictionaries
	$(INSTALL_DIR) common/package/fonts $(DEST_DIR)

	$(INSTALL_FILE) ../core/Common/3dParty/cef/$(TARGET)/build/* $(DEST_DIR)
	$(INSTALL_FILE) common/loginpage/deploy/index.html $(DEST_DIR)
	
	mkdir -p $(DEST_EDITOR_DIR)
	$(INSTALL_FILE) $(WEBAPPS_DIR)/* $(DEST_EDITOR_DIR)
	$(INSTALL_FILE) common/loginpage/addon/externalcloud.json $(DEST_EDITOR_DIR)

	mkdir -p $(DEST_PLUGINS_DIR)

	$(INSTALL_FILE) $(DE_PLUGINS) $(DEST_PLUGINS_DIR)

	mv $(DEST_PLUGINS_DIR)/clipart		$(DEST_PLUGINS_DIR)/{F5BACB61-64C5-4711-AC8A-D01EC3B2B6F1}
	mv $(DEST_PLUGINS_DIR)/macros		$(DEST_PLUGINS_DIR)/{E6978D28-0441-4BD7-8346-82FAD68BCA3B}
	mv $(DEST_PLUGINS_DIR)/ocr			$(DEST_PLUGINS_DIR)/{440EBF13-9B19-4BD8-8621-05200E58140B}
	mv $(DEST_PLUGINS_DIR)/photoeditor	$(DEST_PLUGINS_DIR)/{DA2BB87B-9F03-4160-8411-3AB4A5C71C39}
	mv $(DEST_PLUGINS_DIR)/symboltable	$(DEST_PLUGINS_DIR)/{03C18A8D-8E01-444A-86EB-EDDFA7773157}
	mv $(DEST_PLUGINS_DIR)/translate	$(DEST_PLUGINS_DIR)/{7327FC95-16DA-41D9-9AF2-0E7F449F687D}
	mv $(DEST_PLUGINS_DIR)/youtube		$(DEST_PLUGINS_DIR)/{38E022EA-AD92-45FC-B22B-49DF39746DB4}

	$(INSTALL_DIR) \
		$(UI_PLUGINS_DIR)/{8D67F3C5-7736-4BAE-A0F2-8C7127DC4BB8} \
		$(DEST_PLUGINS_DIR)

ifeq ($(END2END_ENCRYPT),true)
	$(INSTALL_DIR) \
		$(UI_PLUGINS_DIR)/encrypt/ui/common/{14A8FC87-8E26-4216-B34E-F27F053B2EC4} \
		$(DEST_PLUGINS_DIR)

	$(INSTALL_DIR) \
		$(UI_PLUGINS_DIR)/encrypt/ui/engine/blockchain/{B17BDC61-59FC-41A7-A471-CD2C415A665E} \
		$(DEST_PLUGINS_DIR)
endif

	$(INSTALL_DIR) common/converter $(DEST_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)graphics$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)kernel$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)DjVuFile$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)doctrenderer$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)HtmlFile$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)HtmlRenderer$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)PdfReader$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)PdfWriter$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)XpsFile$(SHARED_EXT) $(DEST_CONV_DIR)
	$(INSTALL_FILE) $(CORE_LIB_DIR)/$(SHARED_PREFIX)UnicodeConverter$(SHARED_EXT) $(DEST_CONV_DIR)

	$(INSTALL_FILE) ../core/Common/3dParty/icu/$(TARGET)/build/$(SHARED_PREFIX)*$(SHARED_EXT) $(DEST_CONV_DIR)

	$(INSTALL_FILE) $(CORE_BIN_DIR)/x2t$(EXEC_EXT) $(DEST_CONV_DIR)

uninstall:
	rm -fr $(DEST_DIR)
