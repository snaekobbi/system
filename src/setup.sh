#!/bin/bash
set -e

REPOS=("http://repo1.maven.org/maven2" "https://oss.sonatype.org/content/groups/staging" "https://oss.sonatype.org/content/repositories/snapshots")

function get() {
    GROUP_DIR="`echo $1 | sed 's/:.*//' | sed 's/\./\//g'`"
    ARTIFACT="`echo $1 | sed 's/^[^:]\+://' | sed 's/:[^:]\+$//'`"
    VERSION="`echo $1 | sed 's/.*://'`"
    SHORT_VERSION="`echo $VERSION | sed 's/-.*$//g'`"
    SNAPSHOT_VERSION="`echo $VERSION | sed 's/-[0-9]\{8\}\.[0-9]\{6\}-[0-9][0-9]*$/-SNAPSHOT/g' | sed 's/\([0-9]\)$/\1-SNAPSHOT/'`"
    VERSIONS=($VERSION $SHORT_VERSION $SNAPSHOT_VERSION)
    DEB_URL=""
    for version in ${VERSIONS[*]} ; do
        for repo in ${REPOS[*]} ; do
            REPO_VERSION_URL="$repo/$GROUP_DIR/$ARTIFACT/$version/"
            for ver in ${VERSIONS[*]} ; do
                echo "checking: $REPO_VERSION_URL for $ver"
                DEB_URL="`curl -s $REPO_VERSION_URL | grep 'deb"' | sed 's/.*href="//' | sed 's/".*//' | sed 's/.*\///' | sort | grep $ver | head -n 1`"
                if [ "$DEB_URL" != "" ]; then
                    DEB_URL="$REPO_VERSION_URL$DEB_URL"
                    break
                fi
            done
            if [ "$DEB_URL" != "" ]; then
                break
            fi
        done
        if [ "$DEB_URL" != "" ]; then
            break
        fi
    done
    wget --no-verbose "$DEB_URL"
}

function read_version() {
    cat $HOME/versions.yml | grep "$1_version" | sed 's/.*: *//'
}

cd $HOME
mkdir $HOME/debs && cd $HOME/debs
get "org.daisy.pipeline:assembly:`read_version engine`"
get "org.daisy.pipeline:webui:`read_version webui`"
get "org.daisy.pipeline.modules.braille:mod-celia:`read_version mod_celia`"
get "org.daisy.pipeline.modules.braille:mod-dedicon:`read_version mod_dedicon`"
get "org.daisy.pipeline.modules.braille:mod-mtm:`read_version mod_mtm`"
get "org.daisy.pipeline.modules.braille:mod-nlb:`read_version mod_nlb`"
get "org.daisy.pipeline.modules.braille:mod-nota:`read_version mod_nota`"
get "org.daisy.pipeline.modules.braille:mod-sbs:`read_version mod_sbs`"

DEBIAN_FRONTEND=noninteractive dpkg -i *.deb
