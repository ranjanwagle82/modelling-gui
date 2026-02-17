# run_app_dev.R
# This script sets up the environment and launches the Shiny app.

cat("Running app development script...\n")

# 1. Set options
options(shiny.autoreload = TRUE)

# 2. Check and install required packages
params <- list(
  pkgs = c('shiny', 'bslib', 'readr', 'readxl', 'DT', 'ggplot2', 'car'),
  repo = 'https://cran.rstudio.com/'
)

installed <- installed.packages()[, 'Package']
missing <- params$pkgs[!(params$pkgs %in% installed)]

if (length(missing) > 0) {
  cat(sprintf("Installing missing packages: %s\n", paste(missing, collapse = ", ")))
  install.packages(missing, repos = params$repo)
}

# 3. Validation
if (!require('shiny', quietly = TRUE)) {
  stop("The 'shiny' package could not be loaded even after installation attempt.")
}

# 4. Launch App
# We use '.' to run the app in the current directory (ui.R/server.R)
cat("Launching Shiny app from current directory...\n")
shiny::runApp('.', port = 7896, launch.browser = TRUE)
