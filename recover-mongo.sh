#!/bin/bash
# This script is salvage your wired tiger mongo collection and after that you be able to repair and use your corrupted mongo database again
apt-get update && apt-get install libsnappy-dev build-essential wget -y
wget http://source.wiredtiger.com/releases/wiredtiger-2.7.0.tar.bz2
tar xvf wiredtiger-2.7.0.tar.bz2
cd wiredtiger-2.7.0

./configure --enable-snappy
make

collections=( $( ls /tempdata/*.wt | sed 's/\/tempdata\///' ) )

for collection in "${collections[@]}"
do
    ./wt -v -h ../tempdata -C "extensions=[./ext/compressors/snappy/.libs/libwiredtiger_snappy.so]" -R salvage $collection
done

mongod --repair --dbpath "/tempdata"
