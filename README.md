# RDU Air Quality and Sickle Cell Disease: Exploratory Data Analysis

This reproducible R project cleans daily EPA air-pollution monitoring observations from RDU airport in North Carolina and summarizes CO, PM2.5, and O3 by year and month. The SCD context motivates the study, but **the provided files do not contain SCD outcomes**; no patient-level association is estimated.

## Data source and coverage

Three **course-provided EPA-derived** CSVs from the air pollution monitor at Raleigh–Durham International Airport (RDU), covering 2018 and 2019 and **January–April 2020 only**. The repository retains the original files unmodified under `data/raw/`. The source files have CO and O3 in ppm and PM2.5 in `ug/m3 LC`.

## File structure

```
SCD_Air_Quality_Project/
├── data/raw/AQ_2018.csv       # original 2018 data
├── data/raw/AQ_2019.csv       # original 2019 data
├── data/raw/AQ_2020.csv       # original 2020 data (through April)
├── R/process_air_quality.R   # documented daily-cleaning function
├── reports/report.Rmd               # main RMarkdown analysis and report
├── reports/report.docx       # rendered Word report (after knitting)
├── output/figures/           # optional plot exports
├── .gitignore
└── README.md
```

## Reproduce the report

1. Install **R (version 4.1 or newer)** and **RStudio** (which includes Pandoc).

2. Open `SCD_Air_Quality_Project.Rproj` in RStudio to ensure the project root is correctly identified.

3. Install the required R packages by running the following command in the R console:

   ```r
   install.packages(c(
     "readr", "dplyr", "tidyr", "ggplot2",
     "knitr", "rmarkdown", "here"
   ))
   ```

4. Open `reports/report.Rmd` and select **Knit → Knit to Word**. Alternatively, run the following command from the project root:

   ```r
   rmarkdown::render(
     "reports/report.Rmd",
     output_file = "report.docx"
   )
   ```

5. The generated Word report will be saved as `reports/report.docx`. Verify that it contains three summary tables and two plots. Code is hidden in the Word output using `echo = FALSE`, while the RMarkdown source retains documented code.

6. To process ozone concentrations in ppb rather than the default ppm, run:

   ```r
   source(here::here("R", "process_air_quality.R"))

   ozone_ppb <- process_air_quality(
     here::here("data", "raw", "AQ_2018.csv"),
     o3_units = "ppb"
   )
   ```


## Cleaning logic

The function checks input columns and units; removes exact duplicate records; parses dates; sets any negative pollutant concentration to zero **before aggregation**; averages available nonmissing pollutant values by day; and converts ozone to ppb if requested. All-missing daily pollutant groups remain `NA`. Daily averages are used for all analyses; a day with multiple source rows contributes just **one** value to each monthly average.

**CI note:** The specified +-1.96 SE error bars use nonmissing daily observations pooled by calendar month, without adjusting for serial correlation. January–April pool three years, May–December two years.


## Author and date

**Author:** Shi Mingyu  
**Date:** November 14, 2026
