# data_utils.R

# Function to get sheets if it's an Excel file
get_sheets <- function(file_path) {
  readxl::excel_sheets(file_path)
}

# Function to load data based on type
load_user_data <- function(file_path, file_type, sheet = NULL) {
  if (is.null(file_path)) return(NULL)
  
  tryCatch({
    if (file_type == "csv") {
      readr::read_csv(file_path, show_col_types = FALSE)
    } else if (file_type %in% c("xlsx", "xls")) {
      if (is.null(sheet)) stop("Sheet not specified for Excel file")
      readxl::read_excel(file_path, sheet = sheet)
    } else {
      NULL
    }
  }, error = function(e) {
    stop(paste("Error reading file:", e$message))
  })
}

# Function to get default mtcars data
get_default_data <- function() {
    d <- datasets::iris
  return(d)
}
