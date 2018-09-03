# load input files for scoring model
cp initial_merged_for_scoring.osw $TMPDIR
mv $TMPDIR/initial_merged_for_scoring.osw $TMPDIR/merged_for_scoring.osw

pyprophet score --in=$TMPDIR/merged_for_scoring.osw --level=ms2 --threads=12

cp $TMPDIR/merged* .
