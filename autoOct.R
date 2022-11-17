# test

library("optparse")
library("readr")
library("officer")
suppressMessages(library("tidyverse"))
suppressMessages(library('flextable'))

# ----
# 1. Get args from autoOct.sh

option_list = list(
  make_option(c("-a", "--rod"), action="store", default=NA, type='character',
              help="RNFL OD val"),
  make_option(c("-b", "--rodc"), action="store", default=NA, type='character',
              help="RNFL OD color (red, yellow, or green)"),
  make_option(c("-c", "--ros"), action="store", default=NA, type='character',
              help="RNFL OS val"),
  make_option(c("-d", "--rosc"), action="store", default=NA, type='character',
              help="RNFL OS color (red, yellow, or green)"),
  make_option(c("-e", "--god"), action="store", default=NA, type='character',
              help="GC IPL OD val"),
  make_option(c("-f", "--godc"), action="store", default=NA, type='character',
              help="GC IPL OD color (red, yellow, or green)"),
  make_option(c("-g", "--gos"), action="store", default=NA, type='character',
              help="GC IPL OS val"),
  make_option(c("-i", "--gosc"), action="store", default=NA, type='character',
              help="GC IPL OS color (red, yellow, or green)"),
  make_option(c("-j", "--ifind"), action="store", default=NA, type='character',
              help="Incidental findings"),
  make_option(c("-t","--textFile"), action="store", default=NA, type='character',
              help="pdfToText output"),
  make_option(c("-p","--ptid"), action="store", default=NA, type='character',
              help="pdfToText output"),
  make_option(c("-w","--workDir"), action="store", default=NA, type='character',
              help="out from pwd")
)

opt = parse_args(OptionParser(option_list=option_list))

cat("Are there any prior scans available for comparison? [T/F] ")
priorScans <- as.logical(readLines(file('stdin'), n=1))

if(priorScans) { 
  #get prior data
  cat("Copy prior scan data values, space seperated, no tabs: [date rnfl-od rnfl-os gcipl-od gcipl-os] \n")
  cat("ex: 9/1/2021 92 um 91 um 81 um 79 um 2/17/2021 94 um... \n")
  priorScanData <- readLines(file('stdin'), n=1)
  priorScanData <- as.list(scan(text = priorScanData, what = "   ")) # convert to list
  priorScanData <- priorScanData[priorScanData != "um"]
  
  if(length(priorScanData) %% 5 != 0){ #check list div by 5
    cat("input error, number of  elements not factor of 5. Try again!")
    # try again
    cat("Copy prior scan data values, space seperated, no tabs: [date rnfl-od rnfl-os gcipl-od gcipl-os]")
    cat("ex: 9/1/2021 92 um 91 um 81 um 79 um 2/17/2021 94 um...")
    priorScanData <- readLines(file('stdin'), n=1)
    priorScanData <- as.list(scan(text = priorScanData, what = "   ")) 
    
    if(length(priorScanData) %% 5 != 0){
      cat("still not working")
      
      quit()
    }
  }
  
  dateOfLastScan <- priorScanData[1]
  
}

# Sample Data (for debugging)
# opt <- list(rod = "84",
#             rodc = "green",
#             ros = "105",
#             rosc = "green",
#             god = "85",
#             godc = "red",
#             gos = "84",
#             gosc = "green",
#             ifind = " ",
#             #textFile = "Name:       HERNANDEZ, KARLA                               OD          OS\n\nID:         E106994687                    Exam Date:       9/28/2022   9/28/2022       Neuro\nDOB:        8/4/1998                      Exam Time:       8:35 AM     8:36 AM\nGender:     Female                        Serial Number:   5000-4373   5000-4373\nTechnician: Operator, Cirrus              Signal Strength: 10/10       10/10\n\nGanglion Cell OU Analysis: Macular Cube 512x128                                                    OD                    OS\n                  OD Thickness Map                                                          OS Thickness Map\n\n\n\n\n                     Fovea: 256, 66                                                          Fovea: 260, 65\n\n                                      OD Sectors                               OS Sectors\n       OD Deviation Map                                                                                OS Deviation Map\n\n\n\n\n OD Horizontal B-Scan                       BScan: 66              OS Horizontal B-Scan                         BScan:    65\n\n\n\n\n                                                       Doctor's Signature                             Neuro-CIRRUS1\nComments\n                                                                                                      SW Ver: 11.5.3.61246\n                                                                                                      Copyright 2021\n                                                                                                      Carl Zeiss Meditec, Inc\n                                                                                                      All Rights Reserved\n                                                                                                      Page 1 of 1\n\fName:        HERNANDEZ, KARLA                                OD             OS\n\nID:          E106994687                    Exam Date:        9/28/2022      9/28/2022      Neuro\nDOB:         8/4/1998                      Exam Time:        8:35 AM        8:36 AM\nGender:      Female                        Serial Number:    5000-4373      5000-4373\nTechnician: Operator, Cirrus               Signal Strength: 10/10           10/10\n\nMacula Thickness OU: Macular Cube 512x128                                                            OD                   OS\n             OD ILM-RPE Thickness Map                                                     OS ILM-RPE Thickness Map\n\n\n\n\n                   Fovea: 256, 66                                                               Fovea: 260, 65\n\n\n          OD OCT Fundus             OD ILM-RPE Thickness                    OS ILM-RPE Thickness          OS OCT Fundus\n\n\n\n\n  OD Horizontal B-Scan                       BScan:     66               OS Horizontal B-Scan                     BScan:     65\n\n\n\n\n                                                        Doctor's Signature                              Neuro-CIRRUS1\nComments\n                                                                                                        SW Ver: 11.5.3.61246\n                                                                                                        Copyright 2021\n                                                                                                        Carl Zeiss Meditec, Inc\n                                                                                                        All Rights Reserved\n                                                                                                        Page 1 of 1\n\fName:          HERNANDEZ, KARLA                        OD           OS\n\nID:            E106994687             Exam Date:       9/28/2022    9/28/2022   Neuro\nDOB:           8/4/1998               Exam Time:       8:35 AM      8:37 AM\nGender:        Female                 Serial Number:   5000-4373    5000-4373\nTechnician: Operator, Cirrus          Signal Strength: 10/10        10/10\n\nONH and RNFL OU Analysis:Optic Disc Cube 200x200                                            OD                   OS\n          RNFL Thickness Map                                                                 RNFL Thickness Map\n\n\n\n\n          RNFL Deviation Map                                                                  RNFL Deviation Map\n\n                                             Neuro-retinal Rim Thickness\n\n\n\n\n        Disc Center(-0.03,0.00)mm                                                           Disc Center(0.12,-0.03)mm\n      Extracted Horizontal Tomogram                                                     Extracted Horizontal Tomogram\n                                                   RNFL Thickness\n\n\n\n\n      Extracted Vertical Tomogram                                                         Extracted Vertical Tomogram\n\n\n\n\n        RNFL Circular Tomogram                           RNFL                               RNFL Circular Tomogram\n                                                       Quadrants\n\n\n                                                          RNFL\n                                                       ClockHours\n\n\n\n\n                                                   Doctor's Signature                          Neuro-CIRRUS1\nComments\n                                                                                               SW Ver: 11.5.3.61246\n                                                                                               Copyright 2021\n                                                                                               Carl Zeiss Meditec, Inc\n                                                                                               All Rights Reserved\n                                                                                               Page 1 of 1\n\f",
#             verbose = FALSE,
#             help = FALSE)
# 
# opt$textFile <- read_file("/Users/belladonna/work/oct/test.txt")

# ----
# 2. Get data from text file

## convert the file into seperate strings
y <- strsplit(opt$textFile, "[[:space:]]+")
y <- unlist(y)

## Get date of birth and exam, whatever comes after "DOB:"
dateOfBirth <- y[which(y %in% "DOB:")[1]+1]

dateOfExam <- y[which(y %in% "Date:")[1]+1]

## Get quality
qual <- grep("/10", y, fixed = TRUE)
qualOdGcIpl <- y[qual[1]]
qualOsGcIpl <- y[qual[2]]
qualOdRnfl <- y[qual[5]]
qualOsRnfl <- y[qual[6]]

qualOdGcIpl <- as.numeric(strsplit(qualOdGcIpl, "/")[[1]][1])
qualOsGcIpl <- as.numeric(strsplit(qualOsGcIpl, "/")[[1]][1])
qualOdRnfl <- as.numeric(strsplit(qualOdRnfl, "/")[[1]][1])
qualOsRnfl <- as.numeric(strsplit(qualOsRnfl, "/")[[1]][1])

# ----
# 3. Introduction text (var introText)
introText <- paste("Clinical OCT Report", 
                   "\n \n \n", 
                   "OCT findings: ",
                   "\n ")

# ----
# 4. Make the rnfl / gcipl table (var octDf)
# define rodperc, rosperc, etc.
if (opt$rodc == 'green'){rodPerc <- '5th-95th percentile'}else 
  if (opt$rodc == 'red') {rodPerc <- "< 1st percentile"}else 
  {rodPerc <- "1st-5th percentile"}

if (opt$rosc == 'green'){rosPerc <- '5th-95th percentile'}else 
  if (opt$rosc == 'red') {rosPerc <- "< 1st percentile"}else 
  {rosPerc <- "1st-5th percentile"}

if (opt$godc == 'green'){godPerc <- '5th-95th percentile'}else 
  if (opt$godc == 'red') {godPerc <- "< 1st percentile"}else 
  {godPerc <- "1st-5th percentile"}

if (opt$gosc == 'green'){gosPerc <- '5th-95th percentile'}else 
  if (opt$gosc == 'red') {gosPerc <- "< 1st percentile"}else 
  {gosPerc <- "1st-5th percentile"}

## add 'um' to the units
rod <- paste0(opt$rod, ' um')
ros <- paste0(opt$ros, ' um')
god <- paste0(opt$god, ' um')
gos <- paste0(opt$gos, ' um')

# make a data.frame
octDf <- data.frame(Date = c(dateOfExam, ""),
                    pRNFL_OD = c(rod, rodPerc),
                    pRNFL_OS = c(ros, rosPerc),
                    GCIPL_OD = c(god, godPerc),
                    GCIPL_OS = c(gos, gosPerc))

# add prior scan data to the table
if(priorScans){
  for(i in 1:(length(priorScanData)/5)){
    x <- c(priorScanData[(i*5)-4],
           paste(priorScanData[(i*5)-3],"um"),
           paste(priorScanData[(i*5)-2],"um"),
           paste(priorScanData[(i*5)-1],"um"),
           paste(priorScanData[i*5],"um"))
    
    octDf <- rbind(octDf, x)
  }
}

# ----
# 5. Incidental pathology statement

if (opt$ifind != " "){
  ifindings <- paste0("Incidental retinal pathology was found on this exam. Specifically, ", opt$ifind, ".")
  
  print(ifindings)
  
  cat("Need formal opthalmological evaluation for this? [T / F]? ")
  doReferral <- as.logical(readLines(file('stdin'), n=1))
  
  if (doReferral == TRUE) {
    ifindings <- paste(ifindings, "Formal ophthalmological evaluation is recommended", sep='\n')
  }
}

# ----
# 6. Make detailed interpretation section

detailedInt <- paste("DETAILED INTERPRETATION:", "\n")

cat("I personally reviewed the OCT scan that is stored on the FORUM server [T / F]? ")
x <- as.logical(readLines(file('stdin'), n=1))

if (x){detailedInt <- paste(detailedInt, "I personally reviewed the OCT scan that is stored on the FORUM server.", sep='\n')}

# Quality issues statement (var qualityIssue)
## If everything is >8/10, prompt user to make sure quality was good
if (as.numeric(qualOdRnfl) > 7 & as.numeric(qualOsRnfl) > 7 & as.numeric(qualOsGcIpl) > 7 & as.numeric(qualOdGcIpl) > 7){
  
  cat("All quality metrics were at least 8/10. Do you agree that this study has no quality issues? [T / F] ")
  x <- as.logical(readLines(file('stdin'), n=1))
  
  if (x == FALSE) {
    
    cat("Describe the quality issue (ex. \n
             1)	There was marked motion artifact in *** eye, limiting \n
             2)	Incidental pathology of *** in the *** eye limited \n
             3)	Poor scan quality in the *** eye resulted in poor segmentation resulting in *** ")
    
    qualityIssue <- paste("Quality: ", 
    readLines(file('stdin'), n=1),
             sep = '\n')
  }else {
      qualityIssue <- " "
    }
}else {
  
  cat("Describe the quality issue (ex. \n
             1)	There was marked motion artifact in *** eye, limiting \n
             2)	Incidental pathology of *** in the *** eye limited \n
             3)	Poor scan quality in the *** eye resulted in poor segmentation resulting in *** ")
  
  qualityIssue <- paste("Quality: ",
  readLines(file('stdin'), n=1),
  sep = '\n')
  
}

# RNFL statement (var rnflStatement)
## thickness sentence
if (opt$rodc == 'green' & opt$rosc == 'green') {
  rnflStatement <- "The average retinal nerve fiber layer (RNFL) thicknesses were within normal limits (5th – 95th percentile) in both eyes compared to age-matched normative control data. "
} else {
  rnflStatement <- paste("The average retinal nerve fiber layer (RNFL) thicknesses was in the", rodPerc, "in the right eye and", rosPerc, "in the left eye compared to age-matched normative control data.")
}

## asymmetric sentence
rodRosDif <- abs(as.numeric(opt$rod) - as.numeric(opt$ros))
thinnerEyeRnfl <- if (as.numeric(opt$rod) - as.numeric(opt$ros) < 0) {"right"} else {"left"}

if (rodRosDif < 6) {
  rnflStatement <- paste(rnflStatement, 
                         "There was no significant asymmetry in the average RNFL thickness between eyes.")
}else if (rodRosDif > 9) {
  rnflStatement <- paste(rnflStatement, 
                         "There was significant asymmetry (>9 µM) in the average RNFL thickness between eyes with the",
                         thinnerEyeRnfl, 
                         "eye having thinner RNFL.")
}else {
  rnflStatement <- paste(rnflStatement, 
                         "There was borderline asymmetry (6-9 µM) in the average RNFL thickness between eyes with the ",
                         thinnerEyeRnfl, 
                         "eye having thinner RNFL.")
}

# regional thinning
cat("Is there significant regional thinning in the RNFL in either eye? [T / F] ")
x <- as.logical(readLines(file('stdin'), n=1))

if (x) {
  cat("Ok, describe it (ex. \n
                  (1) There was significant symmetric temporal/inferior/superior/nasal regional thinning of the RNFL in both eyes \n
                  (2) There was significant temporal/inferior/superior/nasal regional thinning of the RNFL in the *** eye. \n")
  foo <- readLines(file('stdin'), n=1)
  rnflStatement <- paste(rnflStatement, 
                         " ",
                         foo,
                         ".")
} else {
  rnflStatement <- paste(rnflStatement, 
                         "There was no significant relative regional thinning of the RNFL in either eye.")
}

# Stable from prior sentence
if (priorScans) {
  print(octDf)
  cat("Was RNFL thickness stable from prior scans? \n Note: 0.15-.16 uM/year acceptable for age-related changes [T / F] ")
   rnflStable <- as.logical(readLines(file('stdin'), n=1))
   
   if (rnflStable){
     rnflStatement <- paste(rnflStatement, 
                            "Average RNFL thicknesses in both eyes were stable since prior OCT on",
                            dateOfLastScan)
   }else {
     cat("Ok, describe the change (ex. \n
                     RNFL thicknesses borderline/possibly decreased (5-6 µm) in *** eyes(s) overtime between *** and ***. \n
                     RNFL thicknesses significantly decreased (5-6 µm) in *** eyes(s) between *** and ***.  ")
     foo <- readLines(file('stdin'), n=1)
     
     rnflStatement <- paste(rnflStatement, 
                            ' ',
                            foo,
                            '.')
   }
}

# GC IPL statement (var gcIplStatement)
## thickness sentence
if (opt$godc == 'green' & opt$gosc == 'green') {
  gcIplStatement <- "The average composite ganglion cell layer (GCIPL) thicknesses were within normal limits (5th – 95th percentile) in both eyes compared to age-matched normative control data. "
} else {
  gcIplStatement <- paste("The average composite ganglion cell layer (GCIPL) thicknesses was in the", godPerc, "in the right eye and", gosPerc, "in the left eye compared to age-matched normative control data.")
}

## asymmetric sentence
godGosDif <- abs(as.numeric(opt$god) - as.numeric(opt$gos))
thinnerEyeGcIpl <- if (as.numeric(opt$god) - as.numeric(opt$gos) < 0) {"right"} else {"left"}

if (godGosDif < 4) {
  gcIplStatement <- paste(gcIplStatement, 
                         "There was no significant asymmetry in the average GCIPL thickness between eyes.")
}else if (godGosDif > 6) {
  gcIplStatement <- paste(gcIplStatement, 
                         "There was significant asymmetry (>6 µM) in the average GCIPL thickness between eyes with the ",
                         thinnerEyeGcIpl, 
                         "eye having thinner GCIPL.")
}else {
  gcIplStatement <- paste(gcIplStatement, 
                         "There was borderline asymmetry (4-6 µM) in the average GCIPL thickness between eyes with the ",
                         thinnerEyeGcIpl, 
                         "eye having thinner GCIPL.")
}

# regional thinning
cat("Was there significant regional thinning in the GCIPL in either eye? [T/F] ")
x <- as.logical(readLines(file('stdin'), n=1))

if (x) {
  cat("Ok, describe it (ex. \n
                  (1) There was significant symmetric temporal/inferior/superior/nasal regional thinning of the GCIPL in both eyes \n
                  (2) There was significant temporal/inferior/superior/nasal regional thinning of the GCIPL in the *** eye. \n")
  foo <- readLines(file('stdin'), n=1)
  gcIplStatement <- paste(gcIplStatement, 
                         " ",
                         foo,
                         ".")
} else {
  gcIplStatement <- paste(gcIplStatement, 
                         "There was no significant relative regional thinning of the GCIPL in either eye.")
}

# Stable from prior sentence
if (priorScans) {
  print(octDf)
  cat("Was GCIPL thickness stable from prior scans? \n Note: 0.15-.16 uM/year acceptable for age-related changes [T/F] ")
  gcIplStable <- as.logical(readLines(file('stdin'), n=1))
  
  if (gcIplStable){
    gcIplStatement <- paste(gcIplStatement, 
                           "Average GCIPL thicknesses in both eyes were stable since prior OCT on ",
                           dateOfLastScan, ".")
  }else {
    cat("Ok, describe the change (ex. \n
                      (1) GCIPL thicknesses borderline/possibly decreased (3 µM) in *** eyes(s) overtime between *** and ***. \n
                      (2) GCIPL thicknesses likely significantly decreased (4 µM) in *** eyes(s) overtime between *** and ***.\n
                      (3) GCIPL thicknesses significantly decreased (>4 µM) in *** eyes(s) overtime between *** and ***. \n")
    foo <- readLines(file('stdin'), n=1)
    
    gcIplStatement <- paste(gcIplStatement, 
                           ' ',
                           foo,
                           '.')
  }
}

detailedInt <- paste("\n", detailedInt, "\n", qualityIssue, "\n", rnflStatement, "\n", "\n", gcIplStatement)

# ----
# 7. Summary statement and signature (var sumStatement)
cat("Is this a normal OCT? [T/F] ")
normalOrAbnormal <- as.logical(readLines(file('stdin'), n=1))

if (!normalOrAbnormal){
  cat("Is this consistent with prior optic neuropathy? [T/F] ")
  isOpticNeuropathy <- as.logical(readLines(file('stdin'), n=1))
  }

if (normalOrAbnormal){
  sumStatement <- "The OCT findings are normal."
  if(priorScans){
    if (gcIplStable & rnflStable) {
      sumStatement <- paste(sumStatement, "RNFL and GCIPL values are stable from prior.")
    }
  }
}else{
  if (isOpticNeuropathy) {
    sumStatement <- paste("These findings could be supportive of optic neuropathy in the", thinnerEyeRnfl, "eye.")
  }else {
    cat("explain the summary statement of this OCT:")
    sumStatement <- readLines(file('stdin'), n=1)
  }
}

sumStatement <- paste("\n",
                      sumStatement, 
                      "Clinical correlation advised. Annual ophthalmological examination is recommended. ",
                      "\n \n",
                      "Sachin Gadani, MD PhD ",
                      "\n",
                      "Neuroimmunology Fellow")

# ----
# 8. Build / save the word doc

## create empty Word file
wordDoc <- read_docx()

## create a fileName
wordDocFileName <- paste0(substr(opt$ptid, start = 1, stop = 4),
                          "_read.docx")

## Add sections

# Intro
introText <- strsplit(introText, '\n')
for(i in 1:length(introText[[1]])){wordDoc %>% body_add_par(introText[[1]][i])}

# Table
set_flextable_defaults(font.size = 10, font.family = "Arial",
                       font.color = "black",
                       table.layout = "fixed",
                       border.color = "black",
                       theme_fun = 'theme_box')
wordDoc <- wordDoc %>% body_add_flextable(flextable(octDf)) 
wordDoc <- wordDoc %>% body_add_par(" ") 

# Incidental
ifindings <- strsplit(detailedInt, '\n')
for(i in 1:length(ifindings[[1]])){wordDoc %>% body_add_par(ifindings[[1]][i])}

# Detailed 
detailedInt <- strsplit(detailedInt, '\n')
for(i in 1:length(detailedInt[[1]])){wordDoc %>% body_add_par(detailedInt[[1]][i])}

# Summary
sumStatement <- strsplit(sumStatement, '\n')
for(i in 1:length(sumStatement[[1]])){wordDoc %>% body_add_par(sumStatement[[1]][i])}

# Print the doc
print(wordDocFileName)
print(wordDoc, target = paste0(opt$workDir,'/', wordDocFileName))

suppressMessages(closeAllConnections())
