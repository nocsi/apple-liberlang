#!/usr/bin/env bash

# Copyright 2024 NOCSI
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restrictions, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# build.sh
#
# This program automated building liberlang to be linked into an iOS or macOS
# application, or to be used by other libraries that may be linked into
# applications.
#
# Usage: build.sh

ROOT_PATH=$PWD

XCODE_ROOT=$( xcode-select -print-path )

MACSYSROOT=$XCODE_ROOT/Platforms/MacOSX.platform/Developer
MIN_OSX_VERSION="12.0"
MIN_IOS_VERSION="15.0"

function arc()
{
    if [[ $1 == arm* ]]; then
		echo "arm"
	elif [[ $1 == x86* ]]; then
		echo "x86"
	else
		echo "unknown"
	fi
}


PLATFORMS="MAC MAC_ARM64 OS64 SIMULATOR64 SIMULATORARM64 MAC_CATALYST MAC_CATALYST_ARM64"
for PLATFORM in $PLATFORMS; do
    echo "Building liberlang for $PLATFORM"

    rm -rf /tmp/liberlang
    cp -R External/liberlang /tmp/

    pushd /tmp/liberlang > /dev/null

    LOG=/tmp/liberlang-$PLATFORM.log
    rm -rf $LOG

    OUTPUT_PATH=$ROOT_PATH/build/$PLATFORM
    rm -rf $OUTPUT_PATH

    case $PLATFORM in
        "MAC" )
            SDK="macosx"
            SDK_PATH=$MACSYSROOT/SDKs/MacOSX.sdk
            OPENSSL_ROOT_DIR=$ROOT_PATH/../openssl-apple/build/darwin64-x86_64
            CFLAGS="-fembed-bitcode -mmacos-version-min=12.0 -arch x86_64 -fno-common -Os -D__MACOS__=yes"
            CXXFLAGS=${CFLAGS}
            LDFLAGS=${CFLAGS}
            CC="$(xcrun --sdk ${SDK} -f clang) ${CFLAGS}"
            CXX="$(xcrun --sdk ${SDK} -f clang++) ${CFLAGS}"
            CCLD=$CC
            CXXLD=$CXX
            XCOMP="x86_64-darwin"
            ARCH="x86_64"
            NAME="x86_64-apple-macos"
            ;;

        "MAC_ARM64" )
            SDK="macosx"
            SDK_PATH=$MACSYSROOT/SDKs/MacOSX.sdk
            OPENSSL_ROOT_DIR=$ROOT_PATH/../openssl-apple/build/darwin64-arm64
            CFLAGS="-fembed-bitcode -mmacos-version-min=12.0 -arch arm64 -fno-common -Os -D__MACOS__=yes"
            CXXFLAGS=${CFLAGS}
            LDFLAGS=${CFLAGS}
            CC="$(xcrun --sdk ${SDK} -f clang) ${CFLAGS}"
            CXX="$(xcrun --sdk ${SDK} -f clang++) ${CFLAGS}"
            CCLD=$CC
            CXXLD=$CXX
            XCOMP="aarch64-darwin"
            ARCH="arm64"
            NAME="aarch64-apple-macos"
            ;;

        "OS64" )
            SDK="iphoneos"
            OPENSSL_ROOT_DIR=$ROOT_PATH/../openssl-apple/build/openssl-ios64
            CFLAGS="-fembed-bitcode -mios-version-min=7.0.0 -fno-common -Os -D__IOS__=yes"
            CXXFLAGS=${CFLAGS}
            LDFLAGS=${CFLAGS}
            CC="$(xcrun --sdk ${SDK} -f clang) ${CFLAGS}"
            CXX="$(xcrun --sdk ${SDK} -f clang++) ${CFLAGS}"
            CCLD=$CC
            CXXLD=$CXX
            XCOMP="arm64-ios"
            ARCH="arm64"
            NAME="aarch64-apple-ios"
            ;;

        "SIMULATOR64" )
            SDK="iphonesimulator"
            OPENSSL_ROOT_DIR=$ROOT_PATH/../openssl-apple/build/openssl-iossimulator
            CFLAGS="-mios-simulator-version-min=7.0.0 -arch x86_64 -fno-common -Os -D__IOS__=yes"
            CXXFLAGS=${CFLAGS}
            LDFLAGS=${CFLAGS}
            CC="$(xcrun --sdk ${SDK} -f clang) ${CFLAGS}"
            CXX="$(xcrun --sdk ${SDK} -f clang++) ${CFLAGS}"
            CCLD=$CC
            CXXLD=$CXX
            XCOMP="x86_64-iossimulator"
            ARCH="x86_64"
            NAME="x86_64-apple-iossimulator"
            ;;

        "SIMULATORARM64" )
            SDK="iphonesimulator"
            OPENSSL_ROOT_DIR=$ROOT_PATH/../openssl-apple/build/openssl-iossimulator-arm
            CFLAGS="-mios-simulator-version-min=7.0.0 -arch arm64 -fno-common -Os -D__IOS__=yes"
            CXXFLAGS=${CFLAGS}
            LDFLAGS=${CFLAGS}
            CC="$(xcrun --sdk ${SDK} -f clang) ${CFLAGS}"
            CXX="$(xcrun --sdk ${SDK} -f clang++) ${CFLAGS}"
            CCLD=$CC
            CXXLD=$CXX
            XCOMP="arm64-iossimulator"
            ARCH="arm64"
            NAME="aarch64-apple-iossimulator"
            ;;

        "MAC_CATALYST" )
            SDK="macosx"
            SDK_PATH=$MACSYSROOT/SDKs/MacOSX.sdk
            OPENSSL_ROOT_DIR=$ROOT_PATH/../openssl-apple/build/openssl-catalyst
            CFLAGS="-arch x86_64 -target x86_64-apple-ios-macabi -fembed-bitcode -mios-version-min=7.0.0 -fno-common -Os -D__IOS__=yes -isysroot $SDK_PATH -framework $SDK_PATH/System/IOSSupport/System/Library/Frameworks -mmacosx-version-min=${MIN_OSX_VERSION} -Wno-overriding-t-option"
            CXXFLAGS=${CFLAGS}
            LDFLAGS=${CFLAGS}
            CC="$(xcrun --sdk ${SDK} -f clang) ${CFLAGS}"
            CXX="$(xcrun --sdk ${SDK} -f clang++) ${CFLAGS}"
            CCLD=$CC
            CXXLD=$CXX
            XCOMP="x86_64-iossimulator"
            ARCH="x86_64"
            NAME="x86_64-apple-ios-macabi"
            ;;

        "MAC_CATALYST_ARM64" )
            SDK="macosx"
            SDK_PATH=$MACSYSROOT/SDKs/MacOSX.sdk
            OPENSSL_ROOT_DIR=$ROOT_PATH/../openssl-apple/build/openssl-catalyst-arm
            CFLAGS="-arch arm64 -target aarch64-apple-ios-macabi -fembed-bitcode -mios-version-min=7.0.0 -fno-common -Os -D__IOS__=yes -isysroot $SDK_PATH -framework $SDK_PATH/System/IOSSupport/System/Library/Frameworks -mmacosx-version-min=${MIN_OSX_VERSION} -Wno-overriding-t-option"
            CXXFLAGS=${CFLAGS}
            LDFLAGS=${CFLAGS}
            CC="$(xcrun --sdk ${SDK} -f clang) ${CFLAGS}"
            CXX="$(xcrun --sdk ${SDK} -f clang++) ${CFLAGS}"
            CCLD=$CC
            CXXLD=$CXX
            XCOMP="aarch64-darwin"
            ARCH="arm64"
            NAME="aarch64-apple-ios-macabi"
            ;;
    esac

    CFLAGS=$CFLAGS <> "-03 -g -fstack-protector-strong"
    LIBSSH2_ROOT_DIR=$ROOT_PATH/../libssh2-apple/build/$PLATFORM
    NIFS=("$OPENSSL_ROOT_DIR/lib/asn1/priv/lib/$NAME/asn1rt_nif.a", "$OPENSSL_ROOT_DIR/lib/crypto/priv/lib/$NAME/crypto.a")
    myarray=$(echo ${NIFS[*]} | tr ',' ,)

    export MAKEFLAGS="-j12"
    export RELEASE_LIBBEAM=yes
    # git clean -xdf && \
    ./otp_build configure \
        --with-ssl=$OPENSSL_ROOT_DIR \
        --with-ssl-incl=$OPENSSL_ROOT_DIR \
        --disable-debug \
        --disable-hipe \
        --disable-sctp \
        --disable-silent-rules \
        --enable-darwin-64bit \
        --enable-dynamic-ssl-lib \
        --enable-dirty-schedulers \
        --enable-kernel-poll \
        --enable-lock-counter \
        --disable-native-libs \
        --enable-shared-zlib \                         
        --disable-dynamic-ssl-lib \
        --xcomp-conf=xcomp/erl-xcomp-$XCOMP.conf \
        --enable-static-nifs=$myarray

    ./otp_build boot -a
    ./otp_build release -a


    # mkdir bin
    # cd bin
    # cmake \
    #     -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/External/ios-cmake/ios.toolchain.cmake \
    #     -DCMAKE_C_FLAGS=$CFLAGS \
    #     -DPLATFORM=$PLATFORM \
    #     -DCMAKE_INSTALL_PREFIX=$OUTPUT_PATH \
    #     -DOPENSSL_ROOT_DIR=$OPENSSL_ROOT_DIR \
    #     -DLIBSSH2_INCLUDE_DIR=$LIBSSH2_ROOT_DIR/include \
    #     -DLIBSSH2_LIBRARY=$LIBSSH2_ROOT_DIR/lib/libssh2.a \
    #     -DENABLE_BITCODE=FALSE \
    #     -DBUILD_SHARED_LIBS=OFF \
    #     -DBUILD_TESTS=OFF \
    #     -DUSE_SSH=ON \
    #     -DGIT_RAND_GETENTROPY=0 \
    #     -DBUILD_CLI=OFF \
    #     .. >> $LOG 2>&1
    # cmake --build . --target install >> $LOG 2>&1

    popd > /dev/null
done

echo "Creating the universal library for macOS"

OUTPUT_PATH=$ROOT_PATH/build/macos
rm -rf $OUTPUT_PATH
mkdir -p $OUTPUT_PATH
lipo -create \
    $ROOT_PATH/build/MAC/lib/liberlang.a \
    $ROOT_PATH/build/MAC_ARM64/lib/liberlang.a \
    -output $OUTPUT_PATH/liberlang.a

echo "Creating the universal library for iOS Simulator"

OUTPUT_PATH=$ROOT_PATH/build/iossimulator
rm -rf $OUTPUT_PATH
mkdir -p $OUTPUT_PATH
lipo -create \
    $ROOT_PATH/build/SIMULATOR64/lib/liberlang.a \
    $ROOT_PATH/build/SIMULATORARM64/lib/liberlang.a \
    -output $OUTPUT_PATH/liberlang.a

echo "Creating the universal library for Catalyst"

OUTPUT_PATH=$ROOT_PATH/build/catalyst
rm -rf $OUTPUT_PATH
mkdir -p $OUTPUT_PATH
lipo -create \
    $ROOT_PATH/build/MAC_CATALYST/lib/liberlang.a \
    $ROOT_PATH/build/MAC_CATALYST_ARM64/lib/liberlang.a \
    -output $OUTPUT_PATH/liberlang.a

echo "Creating the libssh2 XCFramework"

LIB_PATH=$ROOT_PATH
LIBERLANG_PATH=$LIB_PATH/liberlang.xcframework
rm -rf $LIBERLANG_PATH

xcodebuild -create-xcframework \
    -library $ROOT_PATH/build/macos/liberlang.a \
    -headers $ROOT_PATH/build/MAC/include \
    -library $ROOT_PATH/build/OS64/lib/liberlang.a \
    -headers $ROOT_PATH/build/OS64/include \
    -library $ROOT_PATH/build/iossimulator/liberlang.a \
    -headers $ROOT_PATH/build/SIMULATOR64/include \
    -library $ROOT_PATH/build/catalyst/liberlang.a \
    -headers $ROOT_PATH/build/MAC_CATALYST/include \
    -output $LIBERLANG_PATH

zip -r liberlang.zip liberlang.xcframework

echo "Done; cleaning up"
rm -rf $TEMP_PATH
