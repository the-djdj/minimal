#!/bin/sh

set -e

. ../../common.sh

# Read the common configuration properties.
DOWNLOAD_URL=`read_property M4_SOURCE_URL`
USE_LOCAL_SOURCE=`read_property USE_LOCAL_SOURCE`

# Grab everything after the last '/' character.
ARCHIVE_FILE=${DOWNLOAD_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd $MAIN_SRC_DIR/source/overlay

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Downloading m4 source bundle file. The '-c' option allows the download to resume.
  echo "Downloading m4 source bundle from $DOWNLOAD_URL"
  wget -c $DOWNLOAD_URL
else
  echo "Using local m4 source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted autoconf.
echo "Removing m4 work area. This may take a while."
rm -rf $WORK_DIR/overlay/$BUNDLE_NAME
mkdir $WORK_DIR/overlay/$BUNDLE_NAME

# Extract m4 to folder 'work/overlay/m4'.
# Full path will be something like 'work/overlay/m4/m4-latest'.
tar -xvf $ARCHIVE_FILE -C $WORK_DIR/overlay/$BUNDLE_NAME

cd $SRC_DIR
