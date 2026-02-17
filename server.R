# server.R

server <- function(input, output, session) {
  
  # -- 1. Data Handling --
  
  uploaded_file <- reactiveValues(path = NULL, type = NULL, sheets = NULL)
  
  observeEvent(input$file1, {
    uploaded_file$path <- input$file1$datapath
    uploaded_file$type <- tolower(tools::file_ext(input$file1$name))
    
    if (uploaded_file$type %in% c("xlsx", "xls")) {
      uploaded_file$sheets <- get_sheets(uploaded_file$path)
    } else {
      uploaded_file$sheets <- NULL
    }
  })
  
  output$sheet_selector <- renderUI({
    req(uploaded_file$type %in% c("xlsx", "xls"))
    selectInput("sheet", "Select Sheet", choices = uploaded_file$sheets)
  })
  
  # Master Data Reactive
  data_input <- reactive({
    # Check the currently active sub-tab in Data
    # If explicit 'Upload Data' tab is selected, look for file.
    # Otherwise default.
    
    if (is.null(input$data_subtab)) return(get_default_data()) # Safety fallback
    
    if (input$data_subtab == "Default Data") {
      return(get_default_data())
    } else {
      # Upload logic
      req(uploaded_file$path)
      if (uploaded_file$type %in% c("xlsx", "xls")) {
        req(input$sheet)
      }
      load_user_data(uploaded_file$path, uploaded_file$type, input$sheet)
    }
  })
  
  # Update Selectors
  observeEvent(data_input(), {
    req(data_input())
    df <- data_input()
    vars <- names(df)
    
    # Model variables
    updateSelectInput(session, "response_var", choices = vars, selected = character(0))
    updateSelectInput(session, "explanatory_vars", choices = vars, selected = character(0))
    
    # Relational Plot variables
    # Default to first two columns if available
    v1 <- if(length(vars) > 0) vars[1] else NULL
    v2 <- if(length(vars) > 1) vars[2] else v1
    updateSelectInput(session, "rel_x", choices = vars, selected = v1)
    updateSelectInput(session, "rel_y", choices = vars, selected = v2)
  })
  
  # Compact Data Table
  output$data_preview_table <- renderDT({
    req(data_input())
    datatable(data_input(), 
              options = list(
                pageLength = 5,       # Show only 5 rows
                dom = 't',            # Table only (no search, no info, no pagination control)
                scrollX = TRUE
              ),
              style = "bootstrap")
  })
  
  
  # -- 2. Model Logic --
  
  observe({
    req(input$response_var, input$explanatory_vars)
    code <- build_formula_code(input$response_var, input$explanatory_vars, input$interactions)
    updateTextAreaInput(session, "model_code", value = code)
  })
  
  model_results <- eventReactive(input$run_model, {
    req(input$model_code, data_input())
    tryCatch({
      execute_model_code(input$model_code, data_input())
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error")
      return(NULL)
    })
  })
  
  output$model_summary <- renderPrint({
    req(model_results())
    summary(model_results())
  })
  
  output$anova_table <- renderTable({
    req(model_results())
    req(input$anova_type)
    get_anova_table(model_results(), type = input$anova_type)
  }, rownames = TRUE, hover = TRUE, bordered = TRUE)
  
  
  # -- 3. Diagnostic Plots --
  
  output$plot_resid <- renderPlot({
    req(model_results())
    get_model_plot(model_results(), 1)
  })
  
  output$plot_qq <- renderPlot({
    req(model_results())
    get_model_plot(model_results(), 2)
  })
  
  output$plot_scale <- renderPlot({
    req(model_results())
    get_model_plot(model_results(), 3)
  })
  
  output$plot_leverage <- renderPlot({
    req(model_results())
    get_model_plot(model_results(), 5)
  })
  
  # -- 4. Relational Plots --
  output$plot_relational <- renderPlot({
    req(data_input(), input$rel_x, input$rel_y)
    df <- data_input()
    
    # Minimal base plot for functionality
    x <- df[[input$rel_x]]
    y <- df[[input$rel_y]]
    
    # Check if numeric
    if (!is.numeric(x) && !is.numeric(y)) {
      # Basic categorical table plot? Or just error?
      # Let's try simple plot() which usually handles factors ok-ish
    }
    
    plot(x, y, xlab = input$rel_x, ylab = input$rel_y, 
         pch = 19, col = "steelblue", main = paste(input$rel_y, "vs", input$rel_x))
    grid()
  })
}
