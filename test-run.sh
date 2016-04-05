#!/bin/bash

docker build . #>/dev/null
BUILDID="`docker build . | grep "." | tail -n 1 | sed 's/.* //'`"
echo $BUILDID
docker run -i -t "$BUILDID" "$@"
