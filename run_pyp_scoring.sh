# load data from merge and scoring
cp merged_for_scoring.osw $TMPDIR
cp merged.osw $TMPDIR
mv $TMPDIR/merged.osw $TMPDIR/merged_ms2.osw

pyprophet score --in=$TMPDIR/merged_ms2.osw --apply_weights=$TMPDIR/merged_for_scoring.osw --level=ms2

cp $TMPDIR/merged_ms2* .
mv $TMPDIR/merged_ms2.osw $TMPDIR/merged_peptide.osw

pyprophet peptide --in=$TMPDIR/merged_peptide.osw --context=experiment-wide \
peptide --in=$TMPDIR/merged_peptide.osw --context=global

cp $TMPDIR/merged_peptide* .
mv $TMPDIR/merged_peptide.osw $TMPDIR/merged_peptide_export.osw

pyprophet export --in=$TMPDIR/merged_peptide_export.osw \
--out=$TMPDIR/merged_peptide_export.tsv \
--format=legacy_merged \
--no-ipf \
--no-transition_quantification \
--max_rs_peakgroup_qvalue=1 \
--max_rs_peakgroup_pep=1 \
--peptide \
--max_global_peptide_qvalue=0.01 \
--no-protein \
--max_global_protein_qvalue=1

pyprophet export \
--in=$TMPDIR/merged_peptide_export.osw \
--format=score_plots

cp $TMPDIR/merged_peptide_export* .
