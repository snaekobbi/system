DEBS := $(addprefix roles/test-server/files/debs/,org/daisy/pipeline/assembly/1.9.2/assembly-1.9.2_all.deb \
                                                  org/daisy/pipeline/assembly/1.9.1/assembly-1.9.1-webui_all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-celia/1.0.0/mod-celia-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-dedicon/1.0.0/mod-dedicon-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-mtm/1.0.0/mod-mtm-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-nlb/1.1.0/mod-nlb-1.1.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-nota/1.0.0/mod-nota-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-sbs/1.0.0/mod-sbs-1.0.0-all.deb \
                                                  )

.PHONY : all ssh_config clean

all : ssh_config $(DEBS)

$(DEBS) :
	mkdir -p $(dir $@)
	wget -O - "$(subst roles/test-server/files/debs/,http://repo1.maven.org/maven2/,$@)" > $@

ssh_config :
	rm -f $@
	if which vagrant >/dev/null \
		&& vagrant status --machine-readable | grep "vagrant-test-server,state,running" >/dev/null; \
	then vagrant ssh-config > $@; \
	else touch $@; \
	fi

clean :
	rm -rf $(DEBS) ssh_config
