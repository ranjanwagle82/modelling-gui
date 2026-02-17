# ui.R

ui <- page_navbar(
  title = "GUIModeling",
  theme = bs_theme(version = 5),
  
  # -- Tab 1: Data --
  nav_panel("Data",
    navset_card_underline(
      id = "data_subtab",
      
      # Sub-tab: Default Data
      nav_panel("Default Data",
        h4("Default Dataset: Iris"),
        p("You are currently using the built-in 'iris' dataset."),
        p("To use your own data, switch to the 'Upload Data' tab.")
      ),
      
      # Sub-tab: Upload Data
      nav_panel("Upload Data",
        fileInput("file1", "Upload File (CSV/Excel)",
                  accept = c(".csv", ".xlsx", ".xls")
        ),
        uiOutput("sheet_selector")
      )
    ),
    
    # Common Data Preview (Compact)
    card(
      card_header("Data Snapshot"),
      div(style = "width: 100%;",
          DTOutput("data_preview_table")
      )
    )
  ),
  
  # -- Tab 2: Model --
  nav_panel("Model",
    navset_card_underline(
      id = "model_subtab",
      
      # Linear Model
      nav_panel("Linear Model",
        layout_columns(
            col_widths = c(4, 8), # Spacious inputs
            
            # Left: Controls
            div(
              card(
                card_header("Variables"),
                selectInput("response_var", "Response (Y)", choices = NULL),
                selectInput("explanatory_vars", "Explanatory (X)", choices = NULL, multiple = TRUE),
                checkboxInput("interactions", "Include Interactions (*)", value = FALSE)
              ),
              card(
                card_header("Settings"),
                selectInput("anova_type", "ANOVA Type", choices = c("II", "III"), selected = "II")
              ),
              card(
                card_header("Code Execution"),
                textAreaInput("model_code", "R Code", value = "", height = "120px"),
                actionButton("run_model", "Run Analysis", class = "btn-primary w-100")
              )
            ),
            # Right: Output
            div(
              card(
                card_header("Model Summary"),
                verbatimTextOutput("model_summary"),
                style = "max-height: 400px; overflow-y: auto;"
              ),
              card(
                card_header("ANOVA Table"),
                tableOutput("anova_table")
              )
            )
        )
      ),
      
      # Placeholders
      nav_panel("Linear Mixed",
        div(class = "p-5 text-center",
            h3("Coming Soon"),
            p("Linear Mixed Models support is under development.")
        )
      ),
      nav_panel("Generalized Linear Mixed",
        div(class = "p-5 text-center",
            h3("Coming Soon"),
            p("GLMM support is under development.")
        )
      )
    )
  ),
  
  # -- Tab 3: Plots --
  nav_panel("Plots",
    navset_card_underline(
      id = "plot_subtab",
      
      # Diagnostics
      nav_panel("Diagnostic Plots",
         layout_columns(
           col_widths = c(6, 6, 6, 6),
           card(card_header("Residuals vs Fitted"), plotOutput("plot_resid")),
           card(card_header("Normal Q-Q"), plotOutput("plot_qq")),
           card(card_header("Scale-Location"), plotOutput("plot_scale")),
           card(card_header("Residuals vs Leverage"), plotOutput("plot_leverage"))
         )
      ),
      
      # Relational
      nav_panel("Relational Plots",
         layout_columns(
           col_widths = c(3, 9),
           card(
             card_header("Settings"),
             selectInput("rel_x", "X Axis", choices = NULL),
             selectInput("rel_y", "Y Axis", choices = NULL)
           ),
           card(
             card_header("Scatter Plot"),
             plotOutput("plot_relational", height = "500px")
           )
         )
      )
    )
  ), # Comma added here
  
  # Right-aligned items (now at the end, so they appear on right)
  nav_spacer(),
  nav_item(input_dark_mode(id = "theme_mode", mode = "dark"))
)
