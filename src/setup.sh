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

# should merge with master and read these from versions.yml instead
ENGINE_VERSION="1.9.11-20160408.082142-7"
WEBUI_VERSION="2.1.3"
MOD_CELIA_VERSION="1.1.1-20160325.111013-1"
MOD_DEDICON_VERSION="1.4.0-20160325.110919-1"
MOD_MTM_VERSION="1.4.1-20160325.140047-5"
MOD_NLB_VERSION="1.6.1-20160325.133755-2"
MOD_NOTA_VERSION="1.1.1-20160407.181802-5"
MOD_SBS_VERSION="1.3.2-20160325.134355-1"

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
