# library(dplyr)
# library(shinydashboard)
# library(shiny)
# library(DT)

##' @title Xena Shiny App
##' @export
XenaShiny <- function() { # nocov start
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required!")
  }

  if (!requireNamespace("shinydashboard", quietly = TRUE)) {
    stop("Package 'shinydashboard' is required!")
  }

  if (!requireNamespace("DT", quietly = TRUE)) {
    stop("Package 'DT' is required!")
  }

  data <- showTCGA()
  projects <- unique(data$ProjectID)
  datatypes <- unique(data$DataType)
  filetypes <- unique(data$FileType)

  ui <- shinydashboard::dashboardPage(
    shinydashboard::dashboardHeader(title = "UCSCXenaTools"),
    shinydashboard::dashboardSidebar(shinydashboard::sidebarMenu(
      shinydashboard::menuItem(
        "TCGA DataTable",
        tabName = "tcga_datatable",
        icon = shiny::icon("list")
      )
    )),
    shinydashboard::dashboardBody(shinydashboard::tabItems(
      shinydashboard::tabItem(
        tabName = "tcga_datatable",
        shiny::fluidRow(
          shiny::column(
            2,
            shiny::selectInput(
              "projectid",
              "ProjectID:",
              c("All", projects),
              selected = "All",
              multiple = TRUE
            )
          ),
          shiny::column(
            3,
            shiny::selectInput(
              "datatype",
              "DataType:",
              c("All", datatypes),
              selected = "All",
              multiple = TRUE
            )
          ),
          shiny::column(
            4,
            shiny::selectInput(
              "filetype",
              "FileType:",
              c("All", filetypes),
              selected = "All",
              multiple = TRUE
            )
          )
        ),
        # Create the table.
        shiny::fluidRow(DT::dataTableOutput("tcga_table"))
      )
    ))
  )


  server <- function(input, output, session) {
    shiny::updateSelectInput(session,
      "datatype",
      "DataType:",
      c("All", unique(data$DataType)),
      selected = "All"
    )
    shiny::updateSelectInput(session,
      "filetype",
      "FileType:",
      c("All", unique(data$FileType)),
      selected = "All"
    )

    # Filter data based on selections
    output$tcga_table <- DT::renderDataTable(DT::datatable({
      if (!"All" %in% input$projectid) {
        data <- data[data$ProjectID %in% input$projectid, ]
      }
      if (!"All" %in% input$datatype) {
        data <- data[data$DataType %in% input$datatype, ]
      }
      if (!"All" %in% input$filetype) {
        data <- data[data$FileType %in% input$filetype, ]
      }
      data
    }))
  }

  # run Shiny
  shiny::runApp(shiny::shinyApp(ui, server))
} # nocov end
