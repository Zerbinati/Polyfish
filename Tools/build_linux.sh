#!/bin/bash

#Environment
export SDE_PATH="~/sde-external-9.0.0-2021-11-07-lin/sde"

#Little setup
DateString=$(date +'%y%m%d')
RootFolder=/mnt/hgfs/Polyfish
SourceFolder=${RootFolder}/src
BuildFolder=${RootFolder}/Build/Linux/${DateString}

build()
{
	pushd $SourceFolder
	make clean                                       || { echo clean failed; return 1; }
	make profile-build ARCH=$1 -j8                   || { echo profile-build failed; return 1; }	
	strip Polyfish                                   || { echo strip failed; return 1; }
	mv Polyfish ${BuildFolder}/Polyfish_${DateString}_$1 || { echo moving file failed; return 1; }
	make clean
	popd
	return 0
}

#Remove target build folder if it already exists
if [ -e $BuildFolder ]; then
    rm -rf $BuildFolder
fi

#Create target build folder
if [ ! -e $BuildFolder ]; then
    mkdir -p $BuildFolder
fi

echo DateString  : $DateString
echo RootFolder  : $RootFolder
echo SourceFolder: $SourceFolder
echo BuildFolder : $BuildFolder

build x86-64-sse41-popcnt || (echo ERROR & exit 1)
build x86-64-vnni512      || (echo ERROR & exit 1)
build x86-64-vnni256      || (echo ERROR & exit 1)
build x86-64-avx512       || (echo ERROR & exit 1)
build x86-64-bmi2         || (echo ERROR & exit 1)
build x86-64-avx2         || (echo ERROR & exit 1)


echo Build completed
exit 0