# [system][]

Assembly of the complete system in the form of both an [Ansible][] script and as a Docker image


## Ansible


### Testing the script with [Vagrant][]

    vagrant up
    make vagrant
    make
    ansible-playbook test-server.yml -l test

Now open the web UI at http://192.168.50.4:9000. When asked for the web API's address for the Pipeline 2
Engine, enter "http://localhost:8181/ws".


### Release procedure

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


## Docker image


### Building the image

If you want to build the image yourself, you can run this command:

```
docker build .
```

The last line will display the id of the image that was built. Something like:

```
Successfully built 72ca1a0390e8
```

In this case, `72ca1a0390e8` is the image ID.

@josteinaj has uploaded pre-built images to https://hub.docker.com/r/josteinaj/snaekobbi/ which
means you can use those instead by simply referring to `josteinaj/snaekobbi` instead of
building your own image. That image will be used in the following commands.

**TODO**: set up automatic building of `snaekobbi/system` images instead.


### Basic usage with both Web UI and Engine

```
docker run -it -p 9000:9000 -p 8181:8181 josteinaj/snaekobbi
```

Now, open [http://localhost:9000/](http://localhost:9000/) in a browser.

If you are not running Linux, you will have to use the IP address of your VM,
which you can find by running `docker-machine ls`.

You can also query the engine directly at the endpoint
[http://localhost:8181/ws/](http://localhost:8181/ws/). For instance, try the following
URLs in a browser (refer to the
[Web API docs](https://code.google.com/archive/p/daisy-pipeline/wikis/WebServiceAPI.wiki)
for more information):

- [http://localhost:8181/ws/alive](http://localhost:8181/ws/alive)
- [http://localhost:8181/ws/scripts](http://localhost:8181/ws/scripts)
- [http://localhost:8181/ws/jobs](http://localhost:8181/ws/jobs)


### Running an interactive shell

Appending `bash` to the end will start an interactive shell
instead of starting the engine+webui:

```
docker run -it-p 9000:9000 -p 8181:8181 josteinaj/snaekobbi bash
```

In the shell you can use the `dp2` command to interact with Pipeline 2.
The `dp2` command will start the engine if it's not running already.

To start the engine and webui manually:

```
service pipeline2d start
service daisy-pipeline2-webui start
```


### Running multiple conversions as a batch job

There are several ways to do this of course, this is just an example.

- Create a directory with the input books: `$HOME/snaekobbi-docker/target/input`
- Put all your DTBooks there (`551848.xml`, `554569.xml`, etc.)
- Create an empty directory for the output books: `$HOME/snaekobbi/system/target/output`
- Create a bash script that creates jobs, waits for them to finish, and optionally creates logs: `$HOME/snaekobbi/system/target/batch.sh`
  - Here's an example: https://gist.github.com/josteinaj/efa1ca9be1ebce5517d8a91b1911e682

To run this batch conversion, do something like this:

```
docker run -it \
        -v $HOME/snaekobbi/system/target/input:/mnt/input:ro \
        -v $HOME/snaekobbi/system/target/output:/mnt/output \
        -v $HOME/snaekobbi/system/target/batch.sh:/mnt/script/batch.sh \
        josteinaj/snaekobbi /mnt/script/batch.sh
```
