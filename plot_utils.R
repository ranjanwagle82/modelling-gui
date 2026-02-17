# plot_utils.R

# Function to generate a specific diagnostic plot
# which = 1: Residuals vs Fitted
# which = 2: Normal Q-Q
# which = 3: Scale-Location
# which = 5: Residuals vs Leverage (using 5 because 4 is Cook's distance which can be messy)
# Note: standard plot(lm) has 1,2,3,5 as defaults usually. Let's stick to 1,2,3,5.

get_model_plot <- function(model_fit, plot_num) {
  if (is.null(model_fit)) return(NULL)
  
  # plot() for lm allows selecting specific plots via 'which' argument
  # 1=Residuals vs Fitted, 2=Normal Q-Q, 3=Scale-Location, 5=Residuals vs Leverage
  
  plot(model_fit, which = plot_num)
}
