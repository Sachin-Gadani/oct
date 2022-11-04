#! /bin/bash

# Usage: make sure script and pdf are in same dir
# ./autoOct.sh example.pdf

## What this script does:
## Input a .pdf OCT file
## Make a temp dir, go there
## Convert pdf to plain text ("tempDoc.txt")
## Convert pdf to images (tempImg*)
## Show the user images and get input
## pass everything to R to format and create a word doc

if [ $# -eq 0 ]; then
	echo "error: need input .pdf"
	exit 1
fi

open $1


workDir=`pwd`

rm -r tempDir 
mkdir tempDir
cd tempDir

pdftotext -layout ../$1 pdfToText.txt
pdfToText=`cat pdfToText.txt`

pdfimages -png ../$1 tempImg

# open rnfl pic
#open -F -g tempImg-068.png

echo RNFL OD?
read rnflOd

read -p "RNFL OD color [green]: " rnflOdCol
rnflOdCol=${rnflOdCol:-green}

echo RNFL OS?
read rnflOs

read -p "RNFL OD color [green]: " rnflOsCol
rnflOsCol=${rnflOsCol:-green}

# close rnflpic; open gcipl pic
#pkill Preview
#open -F -g tempImg-002.png

echo GC IPL OD?
read gcIplOd

read -p "GC IPL OD color [green]: " gcIplOdCol
gcIplOdCol=${gcIplOdCol:-green}

echo GC IPL OS?
read gcIplOs

read -p "GC IPL OS color [green]: " gcIplOsCol
gcIplOsCol=${gcIplOsCol:-green}

read -p "Any incidental findings (describe them here or leave blank)? " incidentalFindings
incidentalFindings=${incidentalFindings:- }

#pkill Preview
#open -F -g ../$1

###
# Rscript
Rscript ../autoOct.R \
--rod "$rnflOd" \
--rodc "$rnflOdCol" \
--ros "$rnflOs" \
--rosc "$rnflOsCol" \
--god "$gcIplOd" \
--godc "$gcIplOdCol" \
--gos "$gcIplOs" \
--gosc "$gcIplOsCol" \
--ifind "$incidentalFindings" \
--textFile "$pdfToText" \
--ptid "$1" \
--workDir "$workDir"
###

#cleanUp
pkill Preview
cd ../
rm -r tempDir

