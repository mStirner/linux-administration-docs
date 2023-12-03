#!/bin/bash

# Copyright Douglas J Hunley 2013

event=$1
md_device=$2
device=$3

# Based on the event, construct our notify message
case $event in
    DegradedArray)
        msg="$md_device is running in DEGRADED MODE"
        ;;
    DeviceDisappeared)
        msg="$md_device has DISAPPEARED"
        ;;
    Fail)
        msg="$md_device had an ACTIVE component FAIL ($device)"
        ;;
    FailSpare)
        msg="$md_device had a SPARE component FAIL during rebuild ($device)"
        ;;
    MoveSpare)
        msg="SPARE device $device has been MOVED to a new array ($md_device)"
        ;;
    NewArray)
        msg="$md_device has APPEARED"
        ;;
    Rebuild??)
        msg="$md_device REBUILD is now `echo $event|sed 's/Rebuild//'`% complete"
        ;;
    RebuildFinished)
        msg="REBUILD of $md_device is COMPLETE or ABORTED"
        ;;
    RebuildStarted)
        msg="RECONSTRUCTION of $md_device has STARTED"
        ;;
    SpareActive)
        msg="$device has become an ACTIVE COMPONENT of $md_device"
        ;;
    SparesMissing)
        msg="$md_device is MISSING one or more SPARE devices"
        ;;
    TestMessage)
        msg="TEST MESSAGE generated for $md_device"
        ;;
esac

# Now that we have our message, send it to the sys admin.
# (in this example, we send it as an SMS to a Verizon phone)
#echo "$msg" | mail 5555551212@vtext.com
curl "http://example.com/message?token=xxxx" -F "title=Raid Status" -F "message=$msg" -F "priority=5"