# OSWanalysis

## Library generation
For library generation run \code{dda_search.sh}

## OpenSWATH
For the OpenSwathWorkflow run \code{run_osw.sh}

## PyProphet
For PyProphet run \code{run_pyp.sh}.
First, \code{run_pyp_merge_for_scoring.sh} merges the SEC input samples and performs the LDA to learn the score weights.
Second, \code{run_pyp_merge_fast.sh} merges all SEC files.
\code{run_pyp_scoring_1} performs run-specific peak group level scoring of all samples based on the LDA from the input samples.
\code{run_pyp_scoring_2} performs experiment-wide and global peptide level scoring of all samples.
\code{run_pyp_scoring_3} performs experiment-wide and global protein level scoring of all samples.
\code{run_pyp_scoring_4} exports the .osw file to .tsv format while filtering for 1% global peptide FDR.

## Additional filtering
Run \code{filter_pyprophet_export.R} to additionally filter the PyProphet output for 5% run-specific peak group FDR and 5% experiment-wide peptide FDR. 

## TRIC
For feature alignment by TRIC run \code{run_tric.sh}
