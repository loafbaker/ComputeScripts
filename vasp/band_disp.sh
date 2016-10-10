#!/bin/bash

# ***********************************************************
#   File: band_disp.sh
#   Description: a script to read band dispersino from 
#               the result of VASP computational task,
#               usage: band_disp.sh start_band_index end_band_index
#
#   Copyright 2008-2016 Jianming Chen <jmchen@iccas.ac.cn>
#
#   This software may be modified and distributed under the terms
#   of the MIT license.  See the LICENSE file for details.
#
#   Revision history:
#      2011-10-31  Jianming Chen
#        - Original version
# ***********************************************************

eigenfile=EIGENVAL
if [ ! -f $eigenfile ]; then
    echo "Warning: File EIGENVAL does not exist."
    echo "Program terminated."
    exit 2
fi
if [ $# -gt 3 ]; then
    echo "Usage: $0 start_band_index end_band_index"
    exit 3
elif [ $# -eq 1 ]; then
    step1=$1
    step2=$1
elif [ $# -eq 2 ]; then
    step1=$1
    step2=$2
else
    step1=1
    step2=2
fi

if echo $step1 $step2 | grep '[.-]' > /dev/null; then
   echo "Warning: The band index is not a positive interger."
   echo "Program terminated."
   exit 4
fi
# Number of atoms
natom=$(sed -n '6 p' $eigenfile | awk '{print $1}')

# Number of points
nkpot=$(sed -n '6 p' $eigenfile | awk '{print $2}')

# Number of bands
nband=$(sed -n '6 p' $eigenfile | awk '{print $3}')

if [ $step2 -gt $nband ]; then
    echo "Warning: The given band_end is too large. It should not larger than $nband."
    echo "Program terminated."
    exit 5
fi
lcycle=$((nband + 2))
echo "-----------------------------------------------------------------------"
echo " Band index |    Emin     |    Emax     |    Edisp     | kpmin | kpmax "
echo "-----------------------------------------------------------------------"
iband=$step1
while [ $iband -le $step2 ]; do
    #Initialize the line index
    ikpot=1
    lindex=$((iband + 8))
    bmin=10000
    bmax=-10000
    kmin=0
    kmax=0
    while [ $ikpot -le $nkpot ]; do
        bdlevel=$(sed -n ''$lindex' p' EIGENVAL | awk '{print $2}')
        testmin=$(awk 'BEGIN{if('$bdlevel' < '$bmin') {print 1} else {print 0}}')
        testmax=$(awk 'BEGIN{if('$bdlevel' > '$bmax') {print 1} else {print 0}}')
        if (( $testmin ))
        then
            bmin=$bdlevel
            kmin=$ikpot
        fi
        if (( $testmax ))
        then
            bmax=$bdlevel
            kmax=$ikpot
        fi
    
        #Calculate the index for the next cycle
        ikpot=$((ikpot + 1))
        lindex=$((lindex + lcycle))
    done
    
    #Print the statistic results
    edisp=$(echo "$bmax - $bmin" | bc )
    printf "    %3d     | %10.6f  | %10.6f  | %10.6f  |  %3d  |  %3d  \n" $iband $bmin $bmax $edisp $kmin $kmax     
    
    iband=$((iband + 1))
done

echo "-----------------------------------------------------------------------"
