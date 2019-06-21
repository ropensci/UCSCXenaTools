# library(dplyr)
# library(shinydashboard)
# library(shiny)
# library(DT)

##' @title Xena Shiny App
##' @importFrom shinydashboard dashboardPage dashboardBody dashboardHeader dashboardSidebar sidebarMenu menuItem tabItem tabItems
##' @importFrom shiny fluidRow column selectInput updateSelectInput runApp shinyApp icon
##' @export
XenaShiny <- function() { # nocov start
  data <- showTCGA()
  projects <- unique(data$ProjectID)
  datatypes <- unique(data$DataType)
  filetypes <- unique(data$FileType)

  ui <- dashboardPage(
    dashboardHeader(title = "UCSCXenaTools"),
    dashboardSidebar(sidebarMenu(
      menuItem(
        "TCGA DataTable",
        tabName = "tcga_datatable",
        icon = icon("list")
      )
    )),
    dashboardBody(tabItems(
      tabItem(
        tabName = "tcga_datatable",
        fluidRow(
          column(
            2,
            selectInput(
              "projectid",
              "ProjectID:",
              c("All", projects),
              selected = "All",
              multiple = TRUE
            )
          ),
          column(
            3,
            selectInput(
              "datatype",
              "DataType:",
              c("All", datatypes),
              selected = "All",
              multiple = TRUE
            )
          ),
          column(
            4,
            selectInput(
              "filetype",
              "FileType:",
              c("All", filetypes),
              selected = "All",
              multiple = TRUE
            )
          )
        ),
        # Create the table.
        fluidRow(DT::dataTableOutput("tcga_table"))
      )
    ))
  )


  server <- function(input, output, session) {
    updateSelectInput(session,
      "datatype",
      "DataType:",
      c("All", unique(data$DataType)),
      selected = "All"
    )
    updateSelectInput(session,
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
  runApp(shinyApp(ui, server))
} # nocov end
