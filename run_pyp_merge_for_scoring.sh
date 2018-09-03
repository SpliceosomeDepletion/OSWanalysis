# load input files for scoring model
cp heuselm_L171221_001.osw $TMPDIR
cp heuselm_L171221_002.osw $TMPDIR
cp heuselm_L171221_003.osw $TMPDIR

pyprophet merge --out=$TMPDIR/initial_merged_for_scoring.osw \
--subsample_ratio=0.33 $TMPDIR/*.osw

cp $TMPDIR/initial_merged_for_scoring.osw .
