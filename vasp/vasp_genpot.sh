#!/bin/bash

# ***********************************************************
#   File: vasp_genpot.sh
#   Description: a tool to generate POTCAR file for specific
#               functional in a VASP computational task,
#               supports lda, gga & pbe potential.
#               usage: 
#                 vasp_genpot.sh lda/gga/pbe [ element list ]
#               example:
#                 vasp_genpot.sh pbe c h o n
#                   - generate POTCAR file with atom elements
#                     in the order of (C H O N) with PBE
#                     functional
#
#   Copyright 2008-2016 Jianming Chen <jmchen@iccas.ac.cn>
#
#   This software may be modified and distributed under the terms
#   of the MIT license.  See the LICENSE file for details.
#
#   Revision history:
#      2011-10-27  Jianming Chen
#        - Original version
#      2016-10-10  Jianming Chen
#        - Add confirmation prompt before deleting existed
#          POTCAR file
# ***********************************************************

potnam=POTCAR.Z

# Specify the directories of the potential files
potdir=/opt/vasp/PSEUDOPOTENTIAL/PAW

ldadir=$potdir/POTPAW
ggadir=$potdir/POTPAW_GGA
pbedir=$potdir/POTPAW_PBE

if [ $# -lt 2 ]; then
        echo "Usage: $0 lda/gga/pbe [ element list ] "
        exit 2
fi

itype=`echo $1 | tr "[A-Z]" "[a-z]"`
case "$itype" in
    lda)  echo "The pot_type is defined as LDA"; rdir=$ldadir
    ;;
    gga)  echo "The pot_type is defined as GGA(PW91)"; rdir=$ggadir
    ;;
    pbe)  echo "The pot_type is defined as PBE"; rdir=$pbedir
    ;;
    *)    echo "Error: The pot_type can only be \"lda\", \"gga\" or \"pbe\""; exit 1
    ;;
esac
shift

if [ -e POTCAR ]; then
    read -p "POTCAR exists. Delete? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf POTCAR
        echo "Info: POTCAR deleted. "
    else
        echo "Warning: Program terminated. "
        exit 3
    fi
fi

if [ -e ${potnam} ]; then
    rm -rf ${potnam}
    echo "${potnam} exists. Deleted. "
fi

for name in $@ ; do
    i=`echo $name | tr "[a-z]" "[A-Z]"`
    potfil=${rdir}/${i}/${potnam}
    if [ ! -e ${potfil} ] ; then
        echo "Error: Cannot find the ${potnam} of ${i}. "
        exit 4
    fi
    cp -f ${potfil} ./
    gunzip -c ${potnam} >> POTCAR
    rm -f ./${potnam}
done
