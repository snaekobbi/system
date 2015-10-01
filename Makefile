DEBS = $(addprefix roles/test-server/files/debs/, \
             org/daisy/pipeline/assembly/$(engine_version)/assembly-$(engine_version)-all.deb \
             org/daisy/pipeline/assembly/$(webui_version)/assembly-$(webui_version)-webui_all.deb \
             org/daisy/pipeline/modules/braille/mod-celia/$(mod_celia_version)/mod-celia-$(mod_celia_version)-all.deb \
             org/daisy/pipeline/modules/braille/mod-dedicon/$(mod_dedicon_version)/mod-dedicon-$(mod_dedicon_version)-all.deb \
             org/daisy/pipeline/modules/braille/mod-mtm/$(mod_mtm_version)/mod-mtm-$(mod_mtm_version)-all.deb \
             org/daisy/pipeline/modules/braille/mod-nlb/$(mod_nlb_version)/mod-nlb-$(mod_nlb_version)-all.deb \
             org/daisy/pipeline/modules/braille/mod-nota/$(mod_nota_version)/mod-nota-$(mod_nota_version)-all.deb \
             org/daisy/pipeline/modules/braille/mod-sbs/$(mod_sbs_version)/mod-sbs-$(mod_sbs_version)-all.deb)

STABLE_DEBS = $(filter-out %-SNAPSHOT-all.deb,$(DEBS))
SNAPSHOT_DEBS = $(filter %-SNAPSHOT-all.deb,$(DEBS))

M2_REPO := ~/.m2/repository

-include roles/test-server/vars/debs.mk

.PHONY : all ssh_config clean

all : ssh_config $(DEBS)

roles/test-server/vars/debs.mk : %.mk : %.yml
	sed -e '/^---/d;s/ *: */ := /g' $< >$@

$(STABLE_DEBS) :
	mkdir -p $(dir $@)
	wget -O - "$(subst roles/test-server/files/debs/,http://repo1.maven.org/maven2/,$@)" > $@

$(SNAPSHOT_DEBS) : roles/test-server/files/debs/% : $(M2_REPO)/%
	mkdir -p $(dir $@)
	cp $< $@

ssh_config :
	rm -f $@
	if which vagrant >/dev/null \
		&& vagrant status --machine-readable | grep "vagrant-test-server,state,running" >/dev/null; \
	then vagrant ssh-config > $@; \
	else touch $@; \
	fi

clean :
	rm -rf $(DEBS) ssh_config
