#!/bin/bash

usage="Usage: $(basename "$0") [OPTIONS]

Compile all 10 flavors of the Honey chess engine. If invoked without
arguments binaries for the x86-64 architecture are compiled and saved
in the folder ./build_x86-64.

Options:
  -h, --help         Show this help message.
  -a, --arch         Architecture to comile for.
  -c, --comp         Compiler to be used.
  -n, --ndk          Path to NDK (if ndk is set as compiler).
  -o, --out          Output folder for the binaries.

For details regarding the architectures and compiler refer to the
Makefile in the /src folder (make help).

Example:

  $(basename "$0") --arch armv8-a --comp ndk --ndk ~/android-ndk-r21 --out ./build_armv8"

# Default values
ARCH="x86-64"
OUT=$(readlink -m "./build_x86-64")


# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    
    key="$1"
    
    case $key in
        -h|--help)
            echo "${usage}"
            exit 0
            ;;
        -a|--arch)
            ARCH="$2"
            shift
            ;;
        -c|--comp)
            COMP="$2"
            shift
            ;;
        -n|--ndk)
            NDK=$(readlink -m "$2")
            shift
            ;;
        -o|-out)
            OUT=$(readlink -m "$2")
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Print build configuration
echo
echo "Build configuration:"
echo "--------------------"
echo "ARCH:" ${ARCH}
if [ ${COMP} ]; then
    echo "COMP:" ${COMP}
fi
if [ ${NDK} ]; then
    echo "NDK:"  ${NDK}
fi
if [ ${OUT} ]; then
    echo "OUT:"  ${OUT}
fi
echo "--------------------"
echo

# Generate makefile flags
CFLAGS="ARCH=${ARCH}"
if [ ${COMP} ]; then
    CFLAGS="${CFLAGS} COMP=${COMP}"
fi
if [ ${NDK} ]; then
    CFLAGS="${CFLAGS} NDK=${NDK}"
fi
if [ ${OUT} ]; then
    CFLAGS="${CFLAGS} OUT_DIR=${OUT}"
fi

# Create output folder
mkdir -p ${OUT}
# Enter source directory
cd ./src

# Iterate over Honey flavors
for FLAVOR in Stockfish Honey Blue-Honey Bluefish Black-Diamond Weakfish; do
    FLAGS="${CFLAGS}"
    # Append flags for the different flavors
    if [[ "${FLAVOR}" == *"Honey"* ]]; then
        FLAGS="${FLAGS} HONEY=yes"
    fi
    if [[ "${FLAVOR}" == *"Blue"* ]]; then
        FLAGS="${FLAGS} BLUEFISH=yes"
    fi
    if [ "${FLAVOR}" = "Black-Diamond" ]; then
        FLAGS="${FLAGS} NOIR=yes"
    fi
    if [ "${FLAVOR}" = "Weakfish" ]; then
        FLAGS="${FLAGS} WEAKFISH=yes"
    fi
    # Compile engine
    echo "Building ${FLAVOR}"
    {
    make build ${FLAGS}
    make clean ${FLAGS}
    } > /dev/null
    # Compile engines with Fortress Detection
    case ${FLAVOR} in
        Black-Diamond|Weakfish)
        # No FD versions for Black-Diamond and Weakfish
        ;;
        *)
            # Other flavors get FD version
            echo "Building ${FLAVOR}-FD"
            FLAGS="${FLAGS} FORTRESS_DETECT=yes"
            {
            make build ${FLAGS}
            make clean ${FLAGS}
            } > /dev/null
    esac
done
