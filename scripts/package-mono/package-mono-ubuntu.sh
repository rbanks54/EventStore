#!/usr/bin/env bash

set -e

version=$1
customMonoPrefix=$2

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function usage {
	echo "Usage:"
	echo "  $0 version monoprefix"
	echo ""
	echo "Note: By default, mono is assumed to be at the output of 'which mono'../lib"
    echo "      though it may be desirable to specify an actual location."
	exit
}

function writeLog {
	message=$1
	echo "[package-mono.sh] - $message"
}

if [[ "$version" == "" ]] ; then
	VERSIONSTRING="0.0.0.0"
	writeLog "Version defaulted to: 0.0.0.0"
else
	VERSIONSTRING=$version
	writeLog "Version set to: $VERSIONSTRING"
fi

OUTPUTDIR="$SCRIPTDIR/../../bin/packaged"
[[ -d $OUTPUTDIR ]] || mkdir -p $OUTPUTDIR

soext="so"
PACKAGENAME="EventStore-OSS-Mono-Ubuntu-v$VERSIONSTRING"

PACKAGEDIRECTORY="$OUTPUTDIR/$PACKAGENAME"

if [[ -d $PACKAGEDIRECTORY ]] ; then
    rm -rf $PACKAGEDIRECTORY
fi
mkdir $PACKAGEDIRECTORY

pushd $SCRIPTDIR/../../bin/clusternode/

cp -r clusternode-web $PACKAGEDIRECTORY/
cp -r Prelude $PACKAGEDIRECTORY/
cp -r projections $PACKAGEDIRECTORY/
cp libjs1.$soext $PACKAGEDIRECTORY/
cp *.dll $PACKAGEDIRECTORY/
cp *.exe $PACKAGEDIRECTORY/
cp log.config $PACKAGEDIRECTORY/
cp $SCRIPTDIR/run-mono-node.sh $PACKAGEDIRECTORY/run-node.sh

popd

pushd $SCRIPTDIR/../../bin/testclient

cp EventStore.ClientAPI.dll $PACKAGEDIRECTORY/
cp EventStore.TestClient.exe $PACKAGEDIRECTORY/

popd


pushd $OUTPUTDIR

tar -zcvf $PACKAGENAME.tar.gz $PACKAGENAME
rm -r $PACKAGEDIRECTORY

[[ -d ../../packages ]] || mkdir -p ../../packages
mv $PACKAGENAME.tar.gz ../../packages/

popd

rm -r $OUTPUTDIR
