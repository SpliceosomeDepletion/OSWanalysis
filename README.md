# OSWanalysis

## Library generation
For library generation run 'dda_search.sh'

## OpenSWATH
For the OpenSwathWorkflow run 'run_osw.sh'

## PyProphet
For PyProphet run 'run_pyp.sh'. This includes following steps:
- 'run_pyp_merge_for_scoring.sh' merges and subsamples the 3 SEC input samples
- 'run_pyp_subscoring.sh' performs the LDA to learn the score weights
- 'run_pyp_merge_fast.sh' merges all SEC files
- 'run_pyp_scoring_1' performs run-specific peak group level scoring of all samples based on the LDA from the input samples
- 'run_pyp_scoring_2' performs experiment-wide and global peptide level scoring of all samples
- 'run_pyp_scoring_3_prot' performs experiment-wide and global protein level scoring of all samples
- 'run_pyp_scoring_3_prot_expAll' exports the .osw file to .tsv format while filtering for 1% global protein-level FDR, 5% global peptide-level FDR and 10% run-specific peakgroup-level FDR

## Additional filtering
Run 'filter_pyprophet_export.R' to additionally filter the PyProphet output for 5% run-specific peak group FDR and 5% experiment-wide peptide FDR.

## TRIC
For feature alignment by TRIC run 'run_tric.sh'. It first filters the PyProphet output for 10% experiment-wide peptide FDR and 10% experiment-wide protein FDR ('filter_pyprophet_export.R'), followed by the actual feature alignment.
