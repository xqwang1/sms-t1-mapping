#!/bin/bash
# 
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Xiaoqing Wang, 2020
# xiaoqing.wang@med.uni-goettingen.de
#
# Wang X et al.
# Model‐Based Reconstruction for Simultaneous Multi‐Slice T1 Mapping 
# using Single‐Shot Inversion‐Recovery Radial FLASH.
# Magn Reson Med. 2020
#

set -e

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi

dir=liver/inter3
dir2=liver/sms3

sample=512
res=$(($sample/2))
TR=2700
GA=7
lambda=0.00025
reg=${lambda: 2:5}
nstate=180
overgrid=1.25

nspokes=520;
nspokes_per_frame=10
sms=1
slices=3


prefix=vol_1-inter3-center

echo $prefix
                
bart scale 1. $dir/$prefix data/_ksp
./prep.sh -s$sample -R$TR -G$GA -p$nspokes -f$nspokes_per_frame -m$sms -S$slices -c$nstate data/_ksp $dir2/coil_index/vol_1.txt ${prefix}-data.coo ${prefix}-traj.coo ${prefix}-TI.coo
./reco.sh -m$sms -R$lambda -k -o$overgrid ${prefix}-TI.coo ${prefix}-traj.coo ${prefix}-data.coo ${prefix}-liver-reco-${reg}.coo | tee -a $prefix.log
./post.sh -R$TR -r$res ${prefix}-liver-reco-${reg}.coo ${prefix}-liver-${reg}-t1map.coo
rm ${prefix}-traj.coo ${prefix}-data.coo 