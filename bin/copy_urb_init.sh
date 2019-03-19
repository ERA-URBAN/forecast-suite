#!/bin/bash


TMPFILE=temp.`basename $0`.$$

function usage {
        echo "`basename $0` copies urban fields (TRL, TBL, and TGL) from a WRF output to a WRF input file"
        echo "to be used with a warm start for WRF. Note that you also have to set"
        echo "sf_urban_init_from_file to true in the physics section of the namelist"
        echo 
        echo "Usage:"
        echo "`basename $0` wrfoutput time wrfinput"
        echo
        echo "  wrfoutput  An outputfile from a WRF run"
        echo "  time       Time index of field to copy"
        echo "  wrfinput   wrfinput_d?? file"
        echo 
        echo "Run this for each domain."
        exit -1
}


if [[ $# != 3 ]]; then
    echo "Got $# arguments"
    usage
fi
URBANFIELDS="TC_URB,TR_URB,TB_URB,TG_URB,TS_URB,TRL_URB,TBL_URB,TGL_URB"
CYCLEFIELDS="TSLB,SMOIS,SH2O,SMCREL,CANWAT,TSK"
ncks -C -A -o $2 -v ${URBANFIELDS} -d Time,$3 $1
ncks -C -A -o $2 -v ${CYCLEFIELDS} -d Time,$3 $1

