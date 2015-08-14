DEBS := $(addprefix roles/test-server/files/debs/,org/daisy/pipeline/assembly/1.9.1/assembly-1.9.1-all.deb \
                                                  org/daisy/pipeline/assembly/1.9.1/assembly-1.9.1-webui_all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-celia/1.0.0/mod-celia-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-dedicon/1.0.0/mod-dedicon-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-mtm/1.0.0/mod-mtm-1.0.0-all.deb \
                                                  org/daisy/pipeline/modules/braille/mod-nlb/1.0.0/mod-nlb-1.0.0-all.deb \
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

roles/reprepro/files/reprepro-service :
	mkdir -p $(dir $@)
	cd $(dir $@) && wget -O- "http://github.com/snaekobbi/reprepro-service/tarball/cc7b3750c2f2367d4fe4af7543b11c1b58aa4329" | tar xf -
	mv roles/reprepro/files/snaekobbi-reprepro-service-cc7b375 $@

clean :
	rm -rf $(DEBS) ssh_config roles/reprepro/files/reprepro-service
