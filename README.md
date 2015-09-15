# [system][]

Assembly of the complete system in the form of an [Ansible][] script

## Testing the script with [Vagrant][]

    vagrant up
    make
    ansible-playbook test-server.yml -l test

Now open the web UI at http://192.168.50.4:9000. When asked for the web API's address for the Pipeline 2
Engine, enter "http://localhost:8181/ws".

## Release procedure
- Create a release branch.

  ```sh
  git checkout -b release/${VERSION}
  ```
  
- Resolve snapshot versions in `roles/test-server/vars/debs.yml` and commit.
- Make release notes and commit.
- Tag

  ```sh
  git tag -s -a v${VERSION} -m "Version ${VERSION}"
  ```
    
- Push the tag.

  ```sh
  git push origin v${VERSION}
  ```
  
- Add the release notes to http://github.com/snaekobbi/system/releases/v${VERSION}.


[system]: https://github.com/snaekobbi/system
[ansible]: http://www.ansible.com
[vagrant]: https://www.vagrantup.com/
