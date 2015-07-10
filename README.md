# [system][]

Assembly of the complete system in the form of an [Ansible][] script

## Testing the script with [Vagrant][]

    vagrant up
    make
    ansible-playbook test-server.yml

Now open the web UI at http://192.168.50.4:9000. When asked for the web API's address for the Pipeline 2
Engine, enter "http://localhost:8181/ws".


[system]: https://github.com/snaekobbi/system
[ansible]: http://www.ansible.com
[vagrant]: https://www.vagrantup.com/
