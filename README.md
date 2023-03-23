# Pptical coherence tomography (oct) report generator
This simple script assists the user with creating an OCT report. It was designed to be used with the Zeiss Cirrus OCT machine, but could be adapted for use with any machine. It takes information from the OCT report and some user input and generates a .doc file that includes the report and a table of RNFL and GCIPL values. 

# Dependencies
R Packages:
- optparse
- readr
- officer
- tidyverse
- flextable

# Usage
./autoOct.sh octReportPath.pdf
