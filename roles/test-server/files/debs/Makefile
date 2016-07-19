DEBS = engine-$(engine_version).deb \
       webui-$(webui_version).deb \
       mod-celia-$(mod_celia_version).deb \
       mod-dedicon-$(mod_dedicon_version).deb \
       mod-mtm-$(mod_mtm_version).deb \
       mod-nlb-$(mod_nlb_version).deb \
       mod-nota-$(mod_nota_version).deb \
       mod-sbs-$(mod_sbs_version).deb

M2_REPO := ~/.m2/repository

.PHONY : all
all : debs

-include ../../vars/versions.mk
../../vars/versions.mk : %.mk : %.yml
	@sed -e '/^---/d;s/ *: */ := /g' $< >$@

as-snapshot = $(shell echo $(1) |sed 's/-[0-9]\{8\}\.[0-9]\{6\}-[0-9][0-9]*$$/-SNAPSHOT/g')

.PHONY : debs
debs: $(DEBS)

engine-$(engine_version).deb : \
	cache/org/daisy/pipeline/assembly/$(call as-snapshot,$(engine_version))/assembly-$(engine_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

webui-$(webui_version).deb : \
	cache/org/daisy/pipeline/webui/$(call as-snapshot,$(webui_version))/webui-$(webui_version).deb
	@mkdir -p $(dir $@)
	cp $< $@

mod-celia-$(mod_celia_version).deb : \
	cache/org/daisy/pipeline/modules/braille/mod-celia/$(call as-snapshot,$(mod_celia_version))/mod-celia-$(mod_celia_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

mod-dedicon-$(mod_dedicon_version).deb : \
	cache/org/daisy/pipeline/modules/braille/mod-dedicon/$(call as-snapshot,$(mod_dedicon_version))/mod-dedicon-$(mod_dedicon_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

mod-mtm-$(mod_mtm_version).deb : \
	cache/org/daisy/pipeline/modules/braille/mod-mtm/$(call as-snapshot,$(mod_mtm_version))/mod-mtm-$(mod_mtm_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

mod-nlb-$(mod_nlb_version).deb : \
	cache/org/daisy/pipeline/modules/braille/mod-nlb/$(call as-snapshot,$(mod_nlb_version))/mod-nlb-$(mod_nlb_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

mod-nota-$(mod_nota_version).deb : \
	cache/org/daisy/pipeline/modules/braille/mod-nota/$(call as-snapshot,$(mod_nota_version))/mod-nota-$(mod_nota_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

mod-sbs-$(mod_sbs_version).deb : \
	cache/org/daisy/pipeline/modules/braille/mod-sbs/$(call as-snapshot,$(mod_sbs_version))/mod-sbs-$(mod_sbs_version)-all.deb
	@mkdir -p $(dir $@)
	cp $< $@

cache/% : $(M2_REPO)/%
	@mkdir -p $(dir $@)
	cp $< $@

# TODO: for releases, also check SHA (and redownload if cached artifact doesn't match)
cache/% :
	mkdir -p $(dir $@)
	wget -O - "$(subst cache/,http://repo1.cache.org/cache2/,$@)" 2>/dev/null > $@ || \
	wget -O - "$(subst cache/,https://oss.sonatype.org/content/groups/staging/,$@)" 2>/dev/null > $@ || \
	wget -O - "$(subst cache/,https://oss.sonatype.org/content/repositories/snapshots/,$@)" 2>/dev/null > $@ || \
	( rm $@ && exit 1 )

.PHONY : clean
clean :
	rm -rf cache ../../vars/versions.mk *.deb
