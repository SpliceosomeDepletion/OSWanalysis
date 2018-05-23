cp heuselm_*.osw $TMPDIR

pyprophet merge --out=$TMPDIR/merged.osw \
--subsample_ratio=1 $TMPDIR/*.osw

cp $TMPDIR/merged.osw .
