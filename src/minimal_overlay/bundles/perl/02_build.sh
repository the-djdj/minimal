#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Perl source directory which ls finds, e.g. 'perl.5.40.0'.
cd $(ls -d perl-*)

if [ -f Makefile ] ; then
  echo "Preparing '$BUNDLE_NAME' work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for '$BUNDLE_NAME' has been skipped."
fi

rm -rf $DEST_DIR

echo "Creating '/etc/hosts' file."
mkdir -p $DEST_DIR/etc/
echo "127.0.0.1 localhost $(hostname)" > $DEST_DIR/etc/hosts

echo "Exporting environment variables"
export BUILD_ZLIB=False
export BUILD_BZIP2=1

echo "Configuring '$BUNDLE_NAME'."
CFLAGS="$CFLAGS" ./Configure                  \
  -des -Dprefix=$DES_TDIR/usr                 \
       -Dvendorprefix=$DEST_DIR/usr           \
       -Dman1dir=$DEST_DIR/usr/share/man/man1 \
       -Dman3dir=$DEST_DIR/usr/share/man/man3 \
       -Dpager="$DEST_DIR/usr/bin/less -isR"  \
       -Duseshrplib                           \
       -Dusethreads

echo "Building '$BUNDLE_NAME'."
make -j $NUM_JOBS

echo "Installing '$BUNDLE_NAME'."
make -j $NUM_JOBS install DESTDIR=$DEST_DIR

echo "Reducing '$BUNDLE_NAME' size."
set +e
strip -g $DEST_DIR/usr/bin/*
set -e

# With '--remove-destination' all possibly existing soft links in
# '$OVERLAY_ROOTFS' will be overwritten correctly.
cp -r --remove-destination $DEST_DIR/* \
  $OVERLAY_ROOTFS

echo "Cleaning environment variables"
unset BUILD_ZLIB BUILD_BZIP2

echo "Bundle '$BUNDLE_NAME' has been installed."

cd $SRC_DIR
