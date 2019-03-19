#!/bin/csh
#################################################################
# Csh Script to retrieve 2 online Data files of 'ds084.1',
# total 364.11M. This script uses 'wget' to download data.
#
# Highlight this script by Select All, Copy and Paste it into a file;
# make the file executable and run it on command line.
#
# You need pass in your password as a parameter to execute
# this script; or you can set an environment variable RDAPSWD
# if your Operating System supports it.
#
# Contact rpconroy@ucar.edu (Riley Conroy) for further assistance.
#################################################################

set pswd = $2
set eml = $1
set targetdir = $6
if(x$pswd == x && `env | grep RDAPSWD` != '') then
 set pswd = $RDAPSWD
endif
if(x$pswd == x) then
 echo
 echo Usage: $0 YourPassword
 echo
 exit 1
endif
set v = `wget -V |grep 'GNU Wget ' | cut -d ' ' -f 3`
set a = `echo $v | cut -d '.' -f 1`
set b = `echo $v | cut -d '.' -f 2`
if(100 * $a + $b > 109) then
 set opt = "wget --no-check-certificate -P $targetdir"
else
 set opt = "wget -P $targetdir"
endif
set opt1 = '-O Authentication.log --save-cookies auth.rda_ucar_edu --post-data'
set opt2 = "email=$eml&passwd=$pswd&action=login"
$opt $opt1="$opt2" https://rda.ucar.edu/cgi-bin/login
set opt1 = "-N --load-cookies auth.rda_ucar_edu"
set opt2 = "$opt $opt1 http://rda.ucar.edu/data/ds084.1/"
set yr = $3
set mnth = $4
set day = $5
set filelist = ( \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f000.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f006.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f012.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f018.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f024.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f030.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f036.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f042.grib2 \
  $yr/${yr}${mnth}${day}/gfs.0p25.${yr}${mnth}${day}00.f048.grib2 \
)
while($#filelist > 0)
 set syscmd = "$opt2$filelist[1]"
 echo "$syscmd ..."
 $syscmd
 shift filelist
end

rm -f auth.rda_ucar_edu Authentication.log

# rename
foreach fhr ( 00 06 12 18 24 30 36 42 48 )
  mv $targetdir/gfs.0p25.${yr}${mnth}${day}00.f0${fhr}.grib2 $targetdir/gfs.t00z.pgrb2.0p25.f0${fhr} 
end

exit 0
