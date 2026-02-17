# model_utils.R

# Function to build the formula string
build_formula_code <- function(y, xs, use_interactions = FALSE) {
  if (missing(y) || is.null(y) || length(y) == 0) return("")
  if (missing(xs) || is.null(xs) || length(xs) == 0) return("")
  
  sep_char <- if (use_interactions) " * " else " + "
  formula_rhs <- paste(xs, collapse = sep_char)
  
  # Return the full code string
  paste0("fit <- lm(", y, " ~ ", formula_rhs, ", data = df)")
}

# Function to execute model code
execute_model_code <- function(code_string, data_df) {
  # Create a clean environment
  eval_env <- new.env()
  assign("df", data_df, envir = eval_env)
  
  # Run the code
  eval(parse(text = code_string), envir = eval_env)
  
  # Check for result
  if (exists("fit", envir = eval_env)) {
    return(get("fit", envir = eval_env))
  } else {
    stop("The code executed but did not create a 'fit' variable.")
  }
}

# [NEW] Function to calculate ANOVA table
get_anova_table <- function(model_fit, type = "II") {
  if (is.null(model_fit)) return(NULL)
  
  # car::Anova handles different types
  tryCatch({
    # Type II or III
    tbl <- car::Anova(model_fit, type = type)
    return(tbl)
  }, error = function(e) {
    stop(paste("ANOVA Error:", e$message))
  })
}
