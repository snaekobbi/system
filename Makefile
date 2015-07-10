DEBS := $(addprefix roles/test-server/files/debs/,org/daisy/pipeline/assembly/1.9.1/assembly-1.9.1-all.deb \
                                                  org/daisy/pipeline/assembly/1.9.1/assembly-1.9.1-webui_all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-celia/1.0.0/mod-celia-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-dedicon/1.0.0/mod-dedicon-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-mtm/1.0.0/mod-mtm-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-nlb/1.0.0/mod-nlb-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-nota/1.0.0/mod-nota-1.0.0-all.deb \
                                                  )

.PHONY : all vagrant_ssh_config clean

all : vagrant_ssh_config $(DEBS)

$(DEBS) :
	mkdir -p $(dir $@)
	wget -O - "$(subst roles/test-server/files/debs/,http://repo1.maven.org/maven2/,$@)" > $@

vagrant_ssh_config :
	vagrant ssh-config > $@

clean :
	rm -rf $(DEBS) vagrant_ssh_config
