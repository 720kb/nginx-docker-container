#!/usr/bin/env bash

#Thanks to http://jpetazzo.github.io/2015/01/13/docker-mount-dynamic-volumes/
if [ $# -eq 0 ] || [ $# -eq 1 ]; then

  echo "Not correct arguments supplied. Usage: ./add-folder.sh <host-path> <container-path> <stop-nginx>" && \
  exit 1
fi

set -e
HOSTPATH=$1
CONTPATH=$2
TO_STOP=$3
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

if [[ $TO_STOP ]]; then

  echo "Stopping nginx inside the container" && \
  docker exec -it nginx nginx -s stop
fi

docker exec -it nginx bash -c "[ -b $DEV ] || mknod --mode 0600 $DEV b $DEVDEC"
docker exec -it nginx bash -c "mkdir -p $TMPDIR"
docker exec -it nginx bash -c "mount $DEV $TMPDIR"
docker exec -it nginx bash -c "mkdir -p /tmp/swap_folder"

if [[ $(find $REALPATH -maxdepth 0 -type d -empty 2>/dev/null) ]]; then

  #empty
  docker exec -it nginx bash -c "[ $(find $CONTPATH -maxdepth 0 -type d -empty 2>/dev/null) ] && mkdir -p $CONTPATH || mv $CONTPATH/* /tmp/swap_folder"
else

  #not empty
  docker exec -it nginx bash -c "[ $(find $CONTPATH -maxdepth 0 -type d -empty 2>/dev/null) ] && mkdir -p $CONTPATH || rm -Rf $CONTPATH/*"
fi

docker exec -it nginx bash -c "mount -o bind $TMPDIR/$SUBROOT/$SUBPATH $CONTPATH"
docker exec -it nginx bash -c "[ $(find /tmp/swap_folder -maxdepth 0 -type d -empty 2>/dev/null) ] || mv /tmp/swap_folder/* $CONTPATH 2>/dev/null"

docker exec -it nginx bash -c "rm -Rf /tmp/swap_folder && umount $TMPDIR && rmdir $TMPDIR"

if [[ $TO_STOP ]]; then

  echo "Restarting nginx inside the container" && \
  docker exec -it nginx nginx
fi
