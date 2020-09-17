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

if [ $# -eq 0 ]; then
	vols=1
else
	vols=$*
fi

scans=(1 2 3 4 5)

dir=brain/sms5-whole_brain

sample=512
res=$((sample / 2))
TR=4100
GA=7
lambda=0.001
reg=${lambda: 2:5}
nstate=60
overgrid=1.25

nspokes=208;
nspokes_per_frame=4
sms=5
slices=$sms

for i in ${vols[@]} ; do
	for j in ${scans[@]} ; do

		prefix=vol_${i}-${j}

		echo $prefix
                
                bart scale 1. $dir/$prefix data/_ksp
		./prep.sh -s$sample -R$TR -G$GA -p$nspokes -f$nspokes_per_frame -m$sms -S$slices -c$nstate data/_ksp ${prefix}-data.coo ${prefix}-traj.coo ${prefix}-TI.coo
		./reco.sh -m$sms -R$lambda -o$overgrid ${prefix}-TI.coo ${prefix}-traj.coo ${prefix}-data.coo ${prefix}-sms5-brain-reco-${reg}.coo | tee -a $prefix.log
		./post.sh -R$TR -r$res ${prefix}-sms5-brain-reco-${reg}.coo ${prefix}-sms5-brain-${reg}-t1map.coo
                rm ${prefix}-traj.coo ${prefix}-data.coo 
	done
done
