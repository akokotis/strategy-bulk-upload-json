#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

require("shiny")
require("png")
require("shinydashboard")
require("dplyr")
require("RPostgreSQL")
require("dplyr")
require("data.table")
require("jsonlite")

# Define UI for application that draws a histogram
header <- dashboardHeader(title = "Strategy Bulk Upload"
)



body <- dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL, height = 570,solidHeader = TRUE,
               imageOutput("image1")),
           
           box(title = "Attributes Not in Global Taxonomy", width = NULL, height = NULL,
               verbatimTextOutput("att_zeros")),
           box(title = "Values Not in Global Taxonomy", width = NULL, height = NULL,
               verbatimTextOutput("val_zeros"))
           
    ),
    
    
    
    column(width = 3,
           box(width = NULL, status = "warning",
               fileInput("file1", "Choose CSV File",
                         multiple = FALSE,
                         accept = c("text/csv",
                                    "text/comma-separated-values,text/plain",
                                    ".csv")),
               
               p(class = "text-muted",
                 paste("Note: Input file assumes all attributes and values",
                       "exist in the Global Taxonomy. If attributes/values are not,",
                       "they need to be manually entered.")),
               p(class = "text-muted",
                 paste("If 0 attributes/values are returned that you know exist in the",
                       "Global Taxonomy, this is likely a database issue. Please resolve",
                       "with Dev Team immediately.")
               ),
               actionButton("run", label = "Run", style="color: #fff;background-color: #FF8521;font-style: bold")
           ),
           
           box(width = NULL, status = "warning",
               selectInput("dataset", "Choose dataset for download:",
                           choices = c(
                             "IDs",
                             "JSON"
                           ),
                           selected = "JSON"
               ),
               downloadButton("downloadData", "Download"),
               p(class = "text-muted", br(),
                 paste("IDs is the strategy mapping dataset containing all attribute and value IDs.")
               ),
               p(class = "text-muted",
                 paste("JSON File is the final JSON code used for bulk upload, however, **FIRST ROW MUST BE DELETED FIRST**.")
               )
           )
    )
  ), 
  
  tags$head(tags$style(HTML('
      .main-header .logo {
        font-family: "Verdana";
        font-weight: bold;
        font-size: 14px;
      }
    ')))
)


ui= dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body,skin = "green"
)