DEB_DIR := roles/test-server/files/debs
DEBS = $(addprefix $(DEB_DIR)/,engine-$(engine_version).deb \
                               webui-$(webui_version).deb \
                               mod-celia-$(mod_celia_version).deb \
                               mod-dedicon-$(mod_dedicon_version).deb \
                               mod-mtm-$(mod_mtm_version).deb \
                               mod-nlb-$(mod_nlb_version).deb \
                               mod-nota-$(mod_nota_version).deb \
                               mod-sbs-$(mod_sbs_version).deb)

M2_REPO := ~/.m2/repository

.PHONY : all
all : debs

-include roles/test-server/vars/versions.mk
roles/test-server/vars/versions.mk : %.mk : %.yml
	@sed -e '/^---/d;s/ *: */ := /g' $< >$@

as-snapshot = $(shell echo $(1) |sed 's/-[0-9]\{8\}\.[0-9]\{6\}-[0-9][0-9]*$$/-SNAPSHOT/g')

.PHONY : debs
debs: $(DEBS)

$(DEB_DIR)/engine-$(engine_version).deb : \
	maven/org/daisy/pipeline/assembly/$(call as-snapshot,$(engine_version))/assembly-$(engine_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

$(DEB_DIR)/webui-$(webui_version).deb : \
	maven/org/daisy/pipeline/webui/$(call as-snapshot,$(webui_version))/webui-$(webui_version).deb
	@mkdir -p $(dir $@)
	cp $< $@

$(DEB_DIR)/mod-celia-$(mod_celia_version).deb : \
	maven/org/daisy/pipeline/modules/braille/mod-celia/$(call as-snapshot,$(mod_celia_version))/mod-celia-$(mod_celia_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

$(DEB_DIR)/mod-dedicon-$(mod_dedicon_version).deb : \
	maven/org/daisy/pipeline/modules/braille/mod-dedicon/$(call as-snapshot,$(mod_dedicon_version))/mod-dedicon-$(mod_dedicon_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

$(DEB_DIR)/mod-mtm-$(mod_mtm_version).deb : \
	maven/org/daisy/pipeline/modules/braille/mod-mtm/$(call as-snapshot,$(mod_mtm_version))/mod-mtm-$(mod_mtm_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

$(DEB_DIR)/mod-nlb-$(mod_nlb_version).deb : \
	maven/org/daisy/pipeline/modules/braille/mod-nlb/$(call as-snapshot,$(mod_nlb_version))/mod-nlb-$(mod_nlb_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

$(DEB_DIR)/mod-nota-$(mod_nota_version).deb : \
	maven/org/daisy/pipeline/modules/braille/mod-nota/$(call as-snapshot,$(mod_nota_version))/mod-nota-$(mod_nota_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

$(DEB_DIR)/mod-sbs-$(mod_sbs_version).deb : \
	maven/org/daisy/pipeline/modules/braille/mod-sbs/$(call as-snapshot,$(mod_sbs_version))/mod-sbs-$(mod_sbs_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

maven/% : $(M2_REPO)/%
	@mkdir -p $(dir $@)
	cp $< $@

maven/% :
	mkdir -p $(dir $@)
	wget -O - "$(subst maven/,http://repo1.maven.org/maven2/,$@)" 2>/dev/null > $@ || \
	wget -O - "$(subst maven/,https://oss.sonatype.org/content/groups/staging/,$@)" 2>/dev/null > $@ || \
	wget -O - "$(subst maven/,https://oss.sonatype.org/content/repositories/snapshots/,$@)" 2>/dev/null > $@ || \
	( rm $@ && exit 1 )

.PHONY : vagrant
vagrant : vagrant-running ssh_config

.PHONY : vagrant-running
vagrant-running :
	@( which vagrant >/dev/null && vagrant status --machine-readable | grep "vagrant-test-server,state,running" >/dev/null ) \
		|| ( echo "vagrant-test-server not running" >&2 && exit 1 ) \

ssh_config : .vagrant/machines/vagrant-test-server/virtualbox/synced_folders
	@rm -f $@
	vagrant ssh-config > $@;

.PHONY : clean
clean :
	rm -rf maven ssh_config make-debs.mk roles/test-server/vars/versions.mk roles/test-server/files/debs
