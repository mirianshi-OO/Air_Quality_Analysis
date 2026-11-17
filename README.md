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
├── report.Rmd                # main RMarkdown analysis and report
├── reports/report.docx       # rendered Word report (after knitting)
├── output/figures/           # optional plot exports
├── .gitignore
└── README.md
```

## Reproduce the report

1. Install **R (4.1 or newer)**, **RStudio** (recommended), and **Pandoc** (included in RStudio).
2. Open this folder as an RStudio project (File → New Project → Existing Directory) or set the R working directory to the repository root.
3. In the R console, install packages once:

   ```r
   install.packages(c("readr", "dplyr", "tidyr", "ggplot2", "knitr", "rmarkdown"))
   ```

4. Open `report.Rmd` and use **Knit → Knit to Word** (code will be hidden in the Word output). Or run at the project root:

   ```r
   rmarkdown::render("report.Rmd", output_file = "report.docx",
                     output_dir = "reports")
   ```

5. Verify the Word report, including three tables and two plots. The Rmd source and R function contain code comments, but chunks are set to `echo = FALSE` so the Word report is code-free.
6. To use ozone in ppb instead of ppm for a separate analysis, run:

   ```r
   source("R/process_air_quality.R")
   ozone_ppb <- process_air_quality("data/raw/AQ_2018.csv", o3_units = "ppb")
   ```

## Cleaning logic

The function checks input columns and units; removes exact duplicate records; parses dates; sets any negative pollutant concentration to zero **before aggregation**; averages available nonmissing pollutant values by day; and converts ozone to ppb if requested. All-missing daily pollutant groups remain `NA`. Daily averages are used for all analyses; a day with multiple source rows contributes just **one** value to each monthly average.

**CI note:** The specified ±1.96 SE error bars use nonmissing daily observations pooled by calendar month, without adjusting for serial correlation. January–April pool three years, May–December two years.

## GitHub and submission checklist

- [ ] Create a public or private GitHub repository and connect this folder using Git/GitHub Desktop or RStudio.
- [ ] **Commit 1**: raw data, documented processing function, and README; push.
- [ ] **Commit 2** (after working on report): finished report.Rmd and final output; push. Make these actual sequential commits, not a single bulk upload.
- [ ] Replace `[Your Name]` in the report and author placeholder below.
- [ ] Knit the report to `reports/report.docx` **in RStudio**, then review it.
- [ ] Zip the whole project folder, including code, raw files, README, and Word report; submit ZIP to Canvas by **November 19, 2026, 5:00 PM EST**.

## Author and date

**Author:** Shi Mingyu  
**Date:** November 14, 2026
