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
	rm -rf ssh_config
