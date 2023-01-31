############################################################################
# apps/Directory.mk
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#   http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
############################################################################

include $(APPDIR)/Make.defs

# Sub-directories that have been built or configured.

SUBDIRS       := $(dir $(wildcard *$(DELIM)Makefile))
# 含有makefile的目录
CONFIGSUBDIRS := $(filter-out $(dir $(wildcard *$(DELIM)Kconfig)),$(SUBDIRS))
# 含有makefile，但不含有Kconfig的目录
#$(warning CONFIGSUBDIRS=$(CONFIGSUBDIRS))
CLEANSUBDIRS  += $(dir $(wildcard *$(DELIM).depend))
CLEANSUBDIRS  += $(dir $(wildcard *$(DELIM).kconfig))
CLEANSUBDIRS  := $(sort $(CLEANSUBDIRS))
#$(warning CLEANSUBDIRS=$(CLEANSUBDIRS))
# 所有含有.depend,.kconfig的目录需要清理

all: nothing

.PHONY: nothing clean distclean

$(foreach SDIR, $(CONFIGSUBDIRS), $(eval $(call SDIR_template,$(SDIR),preconfig)))
# 对每个SDIR，执行make -c ${SDIR} ${SDIR}_preconfig
$(foreach SDIR, $(CLEANSUBDIRS), $(eval $(call SDIR_template,$(SDIR),clean)))
$(foreach SDIR, $(CLEANSUBDIRS), $(eval $(call SDIR_template,$(SDIR),distclean)))

nothing:

install:
# 此处是递归的写法，会进一步对满足条件的子目录进行preconfig
preconfig: $(foreach SDIR, $(CONFIGSUBDIRS), $(SDIR)_preconfig)
#	$(warning CONFIGSUBDIRS=$(CONFIGSUBDIRS))
ifneq ($(MENUDESC),)
	$(Q) $(MKKCONFIG) -m $(MENUDESC)
# tools/mkkconfig.sh -m $(MENUDESC)，例如生成audioutils下的Kconfig文件
	$(Q) touch .kconfig
# 例如创建audioutils/.kconfig
endif

clean: $(foreach SDIR, $(CLEANSUBDIRS), $(SDIR)_clean)

distclean: $(foreach SDIR, $(CLEANSUBDIRS), $(SDIR)_distclean)
	$(warning CLEANSUBDIRS=$(CLEANSUBDIRS))
ifneq ($(MENUDESC),)
	$(call DELFILE, Kconfig)
	$(call DELFILE, .kconfig)
endif

-include Make.dep
# -忽略退出状态，通常非0退出状态会停止当前build
