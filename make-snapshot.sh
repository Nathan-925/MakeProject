#!/bin/bash

#Creating archive, going into folder to avoid creating the parent directory in the archive.
cd snapshot
if tar -cf ../../snapshots/snapshot-$(date "+%Y-%m-%d-%H%M%S").tar *;
then
    echo "Snapshot archived successfully."
    exit 0
else
    echo "Snapshot archive failed."
    exit 1
fi