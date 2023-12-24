# Formatting NCDS UKDS EUL Data Files

The purpose of this code is to take zipped Stata NCDS files downloaded from the UK Data Service (End User Licence Version) and to arrange these files in a set of per-sweep folders to make using NCDS data easier. The code further creates a lookup dictionary of NCDS variables from the files (in csv and R formats), which can be used to search through the data efficiently - the R format lookup file contains a values label field which can be especially useful to use. The code also moves Age 11 (ncdsessay-*.rtfs) and Age 50 (ncds8_imagine_text.tab & 6978ess*.xml) essay files into the correct per-sweep folders.

To use the code you will need R (https://cran.r-project.org/) and RStudio (https://posit.co/download/rstudio-desktop/) installed. You will only need to use R and RStudio once, so if you are unfamiliar with the programme, you can run the code and then work in Stata.

## Instructions
1. Go to the UKDS and download the individual zipped Stata folders. Keep these folders zipped and place them into the 'Zipped' folder.  For the Age 11 essays, download both the RTF and Stata version files from the UKDS. For the age 50 essays, just download the Stata files.
2. Double click the 'NCDS UKDS.Rproj' file. This will open RStudio and automatically set the working directory to the folder which contains the 'NCDS UKDS.Rproj' file, so you won't need to change any file paths.
3. Run the code. You will need the 'tidyverse' and 'labelled' packages installed. If you do not have these installed, uncomment the first line and run it.

After the code is finished, you will have a set of new folders. The name of the folders refers to the sweep the data were collected. 'xwave' refers to the cross-wave files (e.g., ncds_response.dta and ncds_activity_histories.dta). 'Zipped' contains the zipped folders. 'UKDS' contains the unzipped UKDS files (including user guides and other documentation).

This code was created using UKDS files downloaded on 26/05/2023. It works for UKDS assets 5560, 5565, 5566, 5567, 5578, 5579, 6137, 6940, 6942, 6978, 7669, 8313, 8731. 

If you have any issues using this code, please contact me at [liam.wright@ucl.ac.uk](mailto:liam.wright@ucl.ac.uk)