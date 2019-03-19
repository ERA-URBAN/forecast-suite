#!/bin/bash

# errors are fatal
#set -e


function usage {
        echo "`basename $0` copies urban SST field (temperature) from Rijkswaterstaat"
        echo "observations, as prepared by the prepare_sst.sh script, to a wrfinput file"
        echo 
        echo "Usage:"
        echo "`basename $0` sstfile wrfinput"
        echo
        echo "  sstfile    File containing the 'temperature' variable"
        echo "  wrfinput   wrfinput_d?? file"
        echo 
        echo "Run this for the hi-res domains over the Netherlands."
        exit -1
}


if [[ $# != 2 ]]; then
    echo "Got $# arguments"
    usage
fi

# Add the SST to the wrfinput
ncrename -v temperature,SST -d time,Time "$1"
#ncks -A -o "$2" -v SST "$1"

# Create a field from the input SST
# - rename temperature to TSK
ncks -O -o sst_new.nc -v SST "$1"
ncrename -v SST,TSK sst_new.nc

# Create a field from the input TSK
ncks -v TSK -O -o tsk_old.nc "$2"

# Merge them
# - create mask based on land fraction
ncks -O -o lsmask.nc -v LANDMASK "$2"
cdo ifthenelse lsmask.nc tsk_old.nc sst_new.nc tsk_new.nc
ncrename -d time,Time tsk_new.nc 

# Add to wrfinput
#ncks -A -o "$2" -v TSK tsk_new.nc 

# clean up
#rm -r sst_new.nc tsk_old.nc tsk_new.nc lsmask.nc


