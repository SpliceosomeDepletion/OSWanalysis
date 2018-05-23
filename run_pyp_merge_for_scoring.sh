# load input files for scoring model
cp heuselm_L171221_001.osw $TMPDIR
cp heuselm_L171221_002.osw $TMPDIR
cp heuselm_L171221_003.osw $TMPDIR

pyprophet merge --out=$TMPDIR/merged_for_scoring.osw \
--subsample_ratio=1 $TMPDIR/*.osw

pyprophet score --in=$TMPDIR/merged_for_scoring.osw --level=ms2

cp $TMPDIR/merged* .
