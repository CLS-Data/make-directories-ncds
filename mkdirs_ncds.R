# install.packages(c("tidyverse", "labelled")) # Uncomment if you need to install
library(tidyverse)
library(glue)
library(magrittr)
library(haven)
library(labelled)

rm(list = ls())

# 1. Unzip UKDS Files ----
ukds_folders <- tribble(
  ~code, ~ukds_fld, ~sweep_fld,
  '5560', 'Response and Outcomes Dataset, 1958-2013', 'xwave',
  '5565', 'Childhood Data from Birth to Age 16, Sweeps 0-3, 1958-1974', '0y-16y',
  '5566', 'Age 23, Sweep 4, 1981, and Public Examination Results, 1978', '23y',
  '5567', 'Age 33, Sweep 5, 1991', '33y',
  '5578', 'Age 42, Sweep 6, 1999-2000', '42y',
  '5579', 'Age 46, Sweep 7, 2004-2005', '46y',
  '6137', 'Age 50, Sweep 8, 2008-2009', '50y',
  '6940', 'Partnership Histories, 1974-2013', 'xwave',
  '6942', 'Activity Histories, 1974-2013', 'xwave',
  '6978', 'Age 50, Sweep 8, Imagine You are 60, 2008-2009', '50y',
  '7669', 'Age 55, Sweep 9, 2013', '55y',
  '8313', 'Age 11, Sweep 2, Imagine you are 25 Essays, 1969', '0y-16y',
  '8731', 'Biomedical Survey 2002-2004', '42y-44y Biomedical'
)

ukds_dict <- ukds_folders %>%
  select(code, ukds_fld) %>%
  deframe()

dir.create("UKDS")

unzip_folder <- function(zipped){
  sn <- str_sub(zipped, 8, 11)
  exdir <- glue("UKDS/{ukds_dict[sn]}")
  unzip(zipped, exdir = exdir)
}
list.files("Zipped", "\\.zip", full.names = TRUE) %>%
  walk(unzip_folder)

# 2. Place in Sweep Folders ----
## a. Make Sweep Folders ----
unique(ukds_folders$sweep_fld) %>%
  walk(dir.create)

## b. Move .dta Files ----
fld_to_sweep <- function(file){
  dashes <- str_locate_all(file, "\\/")[[1]][1:2, 1]
  ukds_fld <- str_sub(file, dashes[1] + 1, dashes[2] - 1)
  sweep_fld <- ukds_folders$sweep_fld[ukds_folders$ukds_fld == ukds_fld]
  return(sweep_fld)
}

df_file <- list.files("UKDS", "\\.dta$", 
                      recursive = TRUE, full.names = TRUE) %>%
  tibble(file = .) %>%
  mutate(n_dashes = str_count(file, "\\/"),
         dash_pos = str_locate_all(file, "\\/") %>%
           map2_int(n_dashes, ~ .x[.y, 1]),
         dta = str_sub(file, dash_pos + 1),
         folder = map_chr(file, fld_to_sweep),
         new_path = glue("{folder}/{dta}"))

df_file %$%
  walk2(file, new_path, ~ file.copy(.x, .y))

## c. Move Essays ----
age11_rtfs <- list.files("UKDS" , "ncdsessay.*\\.rtf$", 
                         recursive = TRUE, full.names = TRUE)

if (length(age11_rtfs) > 0){
  dir.create("0y-16y/11y Essays")
  file.copy(age11_rtfs, "0y-16y/11y Essays")
}

age50_xmls <- list.files("UKDS" , "6978ess.*\\.xml$", 
                         recursive = TRUE, full.names = TRUE)

if (length(age50_xmls) > 0){
  dir.create("50y/Essays")
  file.copy(age50_xmls, "50y/Essays")
}

age50_essays <- list.files("UKDS" , "ncds8_imagine_text\\.tab$", 
                           recursive = TRUE, full.names = TRUE)
if (length(age50_essays) > 0){
  file.copy(age50_essays, "50y")
}

# 3. Make Variable Lookup ----
make_lookfor <- function(file){
  data <- read_dta(file, n_max = 1)
  
  tibble(pos = 1:ncol(data),
         variable = names(data),
         label = var_label(data, unlist = TRUE),
         col_type = map_chr(data, vctrs::vec_ptype_abbr),
         value_labels = map(data, val_labels))
}

lookup <- df_file %>%
  mutate(lookup = map(new_path, make_lookfor)) %>%
  select(folder, dta, lookup) %>%
  unnest(lookup)

lookup %>%
  select(-value_labels) %>%
  write_csv("lookup.csv")

saveRDS(lookup, file = "lookup.Rds")
