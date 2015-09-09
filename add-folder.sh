#!/usr/bin/env bash

#Thanks to http://jpetazzo.github.io/2015/01/13/docker-mount-dynamic-volumes/

if [ $# -eq 0 ] || [ $# -eq 1 ]; then

  echo "Not correct arguments supplied. Usage: ./add-folder.sh <host-path> <container-path>" && \
  exit 1
fi

set -e
HOSTPATH=$1
CONTPATH=$2
REALPATH=$(readlink --canonicalize $HOSTPATH)
FILESYS=$(df -P $REALPATH | tail -n 1 | awk '{print $6}')

while read DEV MOUNT JUNK
do [ $MOUNT = $FILESYS ] && break
done </proc/mounts
echo $DEV
[ $MOUNT = $FILESYS ] # Sanity check!

while read A B C SUBROOT MOUNT JUNK
do [ $MOUNT = $FILESYS ] && break
done < /proc/self/mountinfo
echo $SUBROOT
[ $MOUNT = $FILESYS ] # Moar sanity check!

SUBPATH=$(echo $REALPATH | sed s,^$FILESYS,,)
DEVDEC=$(printf "%d %d" $(stat --format "0x%t 0x%T" $DEV))

#echo "$DEV - $DEVDEC - $DEV - /tmpmnt/$SUBROOT/$SUBPATH - $CONTPATH"
# docker-enter nginx -- sh -c \
#   "[ -b $DEV ] || mknod --mode 0600 $DEV b $DEVDEC"
# docker-enter nginx -- mkdir /tmpmnt
# docker-enter nginx -- mount $DEV /tmpmnt
# docker-enter nginx -- mkdir -p $CONTPATH
# docker-enter nginx -- mount -o bind /tmpmnt/$SUBROOT/$SUBPATH $CONTPATH
# docker-enter nginx -- umount /tmpmnt
# docker-enter nginx -- rmdir /tmpmnt
