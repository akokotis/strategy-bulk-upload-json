#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
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

# Define server logic required to draw a histogram
server=function(input, output, session) {
  
  output$image1 <- renderImage({
    return(list(
      src = "images/instructions.png",
      contentType = "image/png",
      width = NULL,
      height = 540,
      alt = "Test"
    ))
    
  }, deleteFile = FALSE)
  
  myData <- reactive({
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header = TRUE, stringsAsFactors=F)
    data
  })
  
  backup_global <- NULL
  makeReactiveBinding("backup_global")
  
  exportTable_global <- NULL
  makeReactiveBinding("exportTable_global")
  
  
  observeEvent(input$run, {
    req(myData())
    
    ###connect to database
    pg = dbDriver("PostgreSQL")
    
    con = dbConnect(pg, user="postgres", password="gbi123gbi",
                    host="10.10.1.175", port=5432, dbname="feeddata_prod")
    
    atttab = dbReadTable(con, "attributes")
    valtab = dbReadTable(con, "values")
    buctab = dbReadTable(con, "buckets")
    
    ###Upload id's
    ids=data.frame(att_id=0,val_id=0)
    
    backup=cbind(ids,myData())
    
    for(i in 2:nrow(backup)){
      attribute=backup$attribute[i]
      value=backup$value[i]
      
      A_id=atttab[which(atttab$name==attribute),"id"]
      V_id=valtab[which(valtab$name==value),"id"]
      
      backup$att_id[i]=ifelse(any(A_id),A_id,0)
      backup$val_id[i]=ifelse(any(V_id),V_id,0)
      
    }
    
    ###print strategy code lines
    buckets=backup[1,6:ncol(backup)]
    
    exportTable=c()
    for(i in 1:ncol(buckets)){
      bucket=buckets[i]
      index=match(bucket,backup[1,])
      
      subset=backup[which(backup[,index]==1),c(1,2,3)]
      
      #turn into json
      txt=toJSON(setNames(as.data.frame(subset),c("attributeId","valueId","questionType")))
      
      #adding parent_hierarchy=6595 ensures it comes from V2 taxonomy
      line1=cbind("bucketIds",buctab[which(buctab$name==paste(bucket) & buctab$parent_hierarchy %like% "6595"),"id"])
      line2=cbind(txt,"")
      
      jsonline=rbind(line1,line2)
      
      exportTable=rbind(exportTable,jsonline)
      
    }
    
    
    ###disconnect from the database
    dbDisconnect(con)
    
    ###make data accessible outside
    backup_global <<- backup
    exportTable_global <<- exportTable
    
    
    ###show zeros
    slice_backup=backup[2:nrow(backup),]
    output$att_zeros <- renderPrint({
      print(unique(slice_backup[which(slice_backup$att_id==0),"attribute"]))
    })
    
    output$val_zeros <- renderPrint({
      print(unique(slice_backup[which(slice_backup$val_id==0),"value"]))
    })
    
    
  })
  
  
  
  datasetInput <- reactive({
    switch(input$dataset,
           "IDs" = backup_global,
           "JSON" = exportTable_global)
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {	
      paste(input$dataset, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(datasetInput(),file, row.names = FALSE)
    }
  )
  
  
  
}