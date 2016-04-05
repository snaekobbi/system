#!/bin/bash
set -e

REPOS=($MAVEN_CENTRAL $SONATYPE_STAGING $SONATYPE_SNAPSHOTS)

function get() {
    GROUP_DIR="`echo $1 | sed 's/:.*//' | sed 's/\./\//g'`"
    ARTIFACT="`echo $1 | sed 's/^[^:]\+://' | sed 's/:[^:]\+$//'`"
    VERSION="`echo $1 | sed 's/.*://'`"
    SHORT_VERSION="`echo $VERSION | sed 's/-.*$//g'`"
    SNAPSHOT_VERSION="`echo $VERSION | sed 's/-[0-9]\{8\}\.[0-9]\{6\}-[0-9][0-9]*$/-SNAPSHOT/g' | sed 's/\([0-9]\)$/\1-SNAPSHOT/'`"
    VERSIONS=($VERSION $SHORT_VERSION $SNAPSHOT_VERSION)
    DEB_URL=""
    for repo in ${REPOS[*]} ; do
        for version in ${VERSIONS[*]} ; do
            REPO_VERSION_URL="$repo/$GROUP_DIR/$ARTIFACT/$version/"
            DEB_URL="`curl -s $REPO_VERSION_URL | grep 'deb"' | head -n 1 | sed 's/.*href="//' | sed 's/".*//' | sed 's/.*\///'`"
            if [ "$DEB_URL" != "" ]; then
                DEB_URL="$REPO_VERSION_URL$DEB_URL"
                break
            fi
        done
        if [ "$DEB_URL" != "" ]; then
            break
        fi
    done
    wget --no-verbose "$DEB_URL"
}

cd $HOME
mkdir $HOME/debs && cd $HOME/debs
get org.daisy.pipeline:assembly:$ENGINE_VERSION
get org.daisy.pipeline:webui:$WEBUI_VERSION
get org.daisy.pipeline.modules.braille:mod-celia:$MOD_CELIA_VERSION
get org.daisy.pipeline.modules.braille:mod-dedicon:$MOD_DEDICON_VERSION
get org.daisy.pipeline.modules.braille:mod-mtm:$MOD_MTM_VERSION
get org.daisy.pipeline.modules.braille:mod-nlb:$MOD_NLB_VERSION
get org.daisy.pipeline.modules.braille:mod-nota:$MOD_NOTA_VERSION
get org.daisy.pipeline.modules.braille:mod-sbs:$MOD_SBS_VERSION

DEBIAN_FRONTEND=noninteractive dpkg -i *.deb
