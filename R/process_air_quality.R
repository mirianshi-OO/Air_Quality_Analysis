#' Process EPA RDU daily air-quality observations for one file.
#'
#' @param file_path Character string: path to a year-specific EPA CSV file.
#' @param o3_units Character string: output ozone units, "ppm" (default) or "ppb".
#' @return Tibble with one row per date and columns date, co, pm25, and o3.
#'   CO is in ppm; PM2.5 is in ug/m3; O3 units follow o3_units.
#'   Exact duplicate raw rows are removed before negative values are clipped
#'   and same-day nonmissing measurements are averaged pollutant by pollutant.
process_air_quality <- function(file_path, o3_units = "ppm") {
  o3_units <- match.arg(o3_units, c("ppm", "ppb"))
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }

  raw <- readr::read_csv(file_path, show_col_types = FALSE)
  required <- c(
    "Date", "Daily Max 8-hour CO Concentration", "units_CO",
    "Daily Mean PM2.5 Concentration", "units_PM",
    "Daily Max 8-hour Ozone Concentration", "units_O3"
  )
  if (!all(required %in% names(raw))) {
    stop("Missing required columns in ", basename(file_path))
  }
  if (any(!is.na(raw$units_CO) & raw$units_CO != "ppm") ||
      any(!is.na(raw$units_PM) & raw$units_PM != "ug/m3 LC") ||
      any(!is.na(raw$units_O3) & raw$units_O3 != "ppm")) {
    stop("Unexpected pollutant units: check the input CSV before processing.")
  }

  clean <- raw |>
    dplyr::distinct() |>  # Remove exact repeated records before averaging.
    dplyr::transmute(
      date = as.Date(Date, format = "%m/%d/%Y"),
      co = `Daily Max 8-hour CO Concentration`,
      pm25 = `Daily Mean PM2.5 Concentration`,
      o3 = `Daily Max 8-hour Ozone Concentration`
    )
  if (any(is.na(clean$date))) {
    stop("At least one Date could not be parsed in ", basename(file_path))
  }

  # Clip negative instrument readings BEFORE daily aggregation: averaging first
  # can wrongly allow a negative value to reduce an otherwise valid day's mean.
  pollutant_vars <- c("co", "pm25", "o3")
  for (pollutant in pollutant_vars) {
    clean[[pollutant]] <- ifelse(
      is.na(clean[[pollutant]]), NA_real_,
      pmax(clean[[pollutant]], 0)
    )
  }

  # Missing pollutant values are ignored individually; an all-missing group
  # remains NA instead of becoming NaN.
  daily <- clean |>
    dplyr::group_by(date) |>
    dplyr::summarise(
      dplyr::across(
        dplyr::all_of(pollutant_vars),
        ~ if (all(is.na(.x))) NA_real_ else mean(.x, na.rm = TRUE)
      ),
      .groups = "drop"
    ) |>
    dplyr::arrange(date)

  if (o3_units == "ppb") daily$o3 <- daily$o3 * 1000
  daily
}
