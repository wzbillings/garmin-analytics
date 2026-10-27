
library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "jsonlite",
    "processx"
  )
)

analysis_date <- "2026-10-25"

list(
  tar_target(
    python_script,
    "python/fetch_garmin.py",
    format = "file"
  ),
  
  tar_target(
    raw_file,
    {
      output <- file.path(
        "data", "raw",
        paste0(analysis_date, ".json")
      )
      
      processx::run(
        command = "uv",
        args = c(
          "run", "--locked",
          "python",
          python_script,
          analysis_date,
          output
        ),
        error_on_status = TRUE
      )
      
      output
    },
    format = "file"
  ),
  
  tar_target(
    daily_data,
    jsonlite::read_json(
      raw_file,
      simplifyVector = FALSE
    )
  ),
  
  tar_quarto(
    report,
    path = "reports/recovery.qmd"
  )
)
