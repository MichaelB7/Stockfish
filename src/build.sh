#!/bin/bash
###  modify as appropriate for you system
### all builds have added features, 4 opening books can be used, adaptive ply,
### play by FIDE Elo ratings or CCRL Elo ratings
###
export PATH=.:$PATH
### time the compile process
set echo on
#DATE=$(shell date +"%m/%d/%y")
start=`date +%s`

#ARCH="ARCH=general-32"
#ARCH="ARCH=x86-32-old"
#ARCH="ARCH=x86-32"
#ARCH="ARCH=general-64"
#ARCH="ARCH=x86-64"
#ARCH="ARCH=x86-64-modern"
#ARCH="ARCH=x86-64-amd"
#ARCH="ARCH=x86-64-bmi2"
#ARCH="ARCH=x86-64-avx2"
ARCH="ARCH=armv8"
#ARCH="ARCH=ppc-32"
#ARCH="ARCH=ppc-64comp"

#COMP="COMP=clang"
#COMP="COMP=mingw"
COMP="COMP=gcc"
#COMP="COMP=icc"
RASP="RASPBERRY=Pi"
#BUILD="build"
BUILD="profile-build"

#make function
function mke() {
CXXFLAGS='' make -j4 $BUILD $ARCH $COMP $RASP CPPFLAGS="-flto" "$@"
}
rm *bench
mke WEAK=yes && wait
mke NOIR=yes && wait
mke BLAU=yes && wait
mke HONEY=yes && wait
mke

### The script code belows computes the bench nodes for each version, and updates the Makefile
### with the bench nodes and the date this was run.
echo ""
mv benchnodes.txt benchnodes_old.txt
echo "$( date +'Based on commits through %m/%d/%Y:')">> benchnodes.txt
echo "======================================================">> benchnodes.txt
grep -E 'searched|Nodes/second' *.bench  /dev/null >> benchnodes.txt
echo "======================================================">> benchnodes.txt
sed -i -e  's/^/### /g' benchnodes.txt
#rm *.nodes benchnodes.txt-e
echo "$(<benchnodes.txt)"
sed -i.bak -e '1050,1172d' ../src/Makefile
sed '1049r benchnodes.txt' <../src/Makefile >../src/Makefile.tmp
mv ../src/Makefile.tmp ../src/Makefile
rm *.bench
#strip Black* Blue* Honey* Weak* Stock*

end=`date +%s`
runtime=$((end-start))
echo ""
echo Processing time $runtime seconds...
