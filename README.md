# Docker image for running Pipeline 2 with all the braille modules

## Building the image

```
docker build .
```

The last line will display the id of the image that was built. Something like:

```
Successfully built 72ca1a0390e8
```

`72ca1a0390e8` will be used in the following commands, replace with the id you get when building.


## Running the Web UI

```
docker run -it -p 9000:9000 72ca1a0390e8
```

Now, open [http://localhost:9000/](http://localhost:9000/) in a browser.


## Running an interactive shell

```
docker run -it 72ca1a0390e8 bash
```

In the shell you can use the `dp2` command to interact with Pipeline 2.


## Running the CLI directly

```
docker run -it 72ca1a0390e8 dp2 help
```


## Running multiple conversions as a batch job

There are several ways to do this of course, this is just an example.

Prepare a directory with the input books, let's say `$HOME/snaekobbi-docker/test/resources`.

Decide where to put the outputs, let's say `$HOME/snaekobbi-docker/target`

Prepare a bash script that creates jobs, waits for them to finish, and then copies
any files of interest to the output directory. Let's assume it's stored as `$HOME/snaekobbi-docker/batch.sh`.

To run this batch conversion, do something like this:

```
docker run -it \
        $HOME/snaekobbi-docker/test/resources:/mnt/output \
        $HOME/snaekobbi-docker/target:/mnt/input \
        $HOME/snaekobbi-docker/bash.sh:/mnt/script/bash.sh \
        72ca1a0390e8 /mnt/script/batch.sh
```

