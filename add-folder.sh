#!/usr/bin/env bash

#Thanks to http://jpetazzo.github.io/2015/01/13/docker-mount-dynamic-volumes/

if [ $# -eq 0 ] || [ $# -eq 1 ]; then

  echo "Not correct arguments supplied. Usage: ./add-folder.sh <host-path> <container-path>" && \
  exit 1
fi

set -e
HOSTPATH=$1
CONTPATH=$2
TMPDIR='/tmpmnt'
REALPATH=$(readlink --canonicalize $HOSTPATH)
FILESYS=$(df -P $REALPATH | tail -n 1 | awk '{print $6}')

while read DEV MOUNT JUNK
do [ $MOUNT = $FILESYS ] && break
done < /proc/mounts
[ $MOUNT = $FILESYS ] # Sanity check!

while read A B C SUBROOT MOUNT JUNK
do [ $MOUNT = $FILESYS ] && break
done < /proc/self/mountinfo
[ $MOUNT = $FILESYS ] # Moar sanity check!

SUBPATH=$(echo $REALPATH | sed s,^$FILESYS,,)
DEVDEC=$(printf "%d %d" $(stat --format "0x%t 0x%T" $DEV))

if [[ $SUBROOT = '/' ]]; then

  BINDDIR="$TMPDIR$SUBPATH";
else

  echo "not supported by now...";
  exit 1
fi

docker exec -it nginx sh -c "[ -b $DEV ] || mknod --mode 0600 $DEV b $DEVDEC" && \
docker exec -it nginx mkdir $TMPDIR && \
docker exec -it nginx mount $DEV $TMPDIR && \
docker exec -it nginx mkdir -p $CONTPATH && \
docker exec -it nginx mount -o bind $TMPDIR/$SUBROOT/$SUBPATH $CONTPATH && \
docker exec -it nginx umount $TMPDIR && \
docker exec -it nginx rmdir $TMPDIR
