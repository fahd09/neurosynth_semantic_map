library(shiny)
load('./data/studies.rda')
load('./data/words.rda')
load('./data/studies_top.101_indices.rda')
load('./data/words_top.101_indices.rda')
source('./helpers.R')

random.pmid.loc <- sample(length(studies$pubmed),1)
random.pmid <- studies$pubmed[random.pmid.loc]
random.stem.loc <- sample(length(words$word),1)
random.stem <- words$word[random.stem.loc]

random.year.loc <- sample(length(studies$year),1)
random.year <- studies$year[random.year.loc]

random.journal.loc <- sample(length(studies$journal),1)
random.journal <- studies$journal[random.journal.loc]


# Define UI ----
ui <- fluidPage(
  
  titlePanel("Neurosynth RecommendR"),
  sidebarLayout(
    sidebarPanel(
      selectInput("whichvisual","Choose visualizer type",choices=list("Papers (PMIDs)"="papers","Words (stems)"="words","Publication Year"="pubs","Journal"="journals"),selected=1),
      conditionalPanel(
        condition="input.whichvisual=='papers'",
        #selectInput("pmid.or.word_dropdown", "Choose paper", choices = studies$pubmed, selected = random.pmid)
        textInput("pmid", label = "Input PMID:", value = "19789183"),
        downloadButton("downloadPMIDs","Download similar studies")
      ),
      conditionalPanel(
        condition="input.whichvisual=='words'",
        #selectInput("pmid.or.word_dropdown", "Choose word", choices = words$word, selected = random.stem)
        textInput("word", label = "Input stem:", value = "truth"),
        downloadButton("downloadStems","Download similar stems")
      ),
      conditionalPanel(
        condition="input.whichvisual=='pubs'",
        selectInput("years_dropdown", "Choose publication year", choices = studies$year, selected = 1)
      ),
      conditionalPanel(
        condition="input.whichvisual=='journals'",
        selectInput("journals_dropdown", "Choose journal", choices = studies$journal, selected = 1)
      ),      
      
      conditionalPanel(
        condition="input.whichvisual=='papers' || input.whichvisual=='words'",
        radioButtons("dot.colors", label = "Color scheme", choices = list("Cluster colors" = 1, "Grey" = 2),selected = 2)
      ),
      conditionalPanel(
        condition="input.whichvisual=='papers' || input.whichvisual=='words'",
        sliderInput("zoom.hits", label = "Number of similar items:",min = 5, max = 100, value = 5)
      ),

      sliderInput("alpha", label = "Color alpha levels:",min = 0, max = 1, value = .35),
      sliderInput("cex", label = "cex (dot size)",min = .25, max = 1, value = .75),
      selectInput("x.axis","X axis",choices=c(1:5), selected=1),
      selectInput("y.axis","Y axis",choices=c(1:5), selected=2)
    ),
    mainPanel(
        ## ugh.
      plotOutput("nr.space",height="700px",width="700px")
    )
  )
)

# Define server logic ----
server <- function(input, output) {

  grabData <- reactive({
    if(input$whichvisual=="papers"){
      if( !(input$pmid %in% studies[,'pubmed']) ){
        return(NULL)
      }else{
        return(studies[studies_top.101_indices[input$pmid,1:(input$zoom.hits+1)],])
      }
    }else if(input$whichvisual=="words"){
      if( !(input$word %in% words[,'word']) ){
        return(NULL)
      }else{
        return(words[words_top.101_indices[input$word,1:(input$zoom.hits+1)],])
      }
    }else{
      return(NULL)
    }
    
  })  
  
  output$nr.space <- renderPlot(
    {

      if(input$whichvisual=="papers"){
        #warning(input$pmid)
        studies.ret <- studies.plot.panel(studies,studies_top.101_indices,input$dot.colors,input$pmid,input$zoom.hits,input$alpha, input$x.axis, input$y.axis, input$cex)
        if(studies.ret$message=="invalid"){
          id <- showNotification(ui=paste0(input$pmid," is not a valid choice."), duration = 3, closeButton = T,type = "error")
        }
      }else if(input$whichvisual=="words"){
        #warning(input$word)
        stems.ret <- stems.plot.panel(words,words_top.101_indices,input$dot.colors,input$word,input$zoom.hits,input$alpha, input$x.axis, input$y.axis, input$cex)
        if(stems.ret$message=="invalid"){
          id <- showNotification(ui=paste0(input$word," is not a valid choice."), duration = 3, closeButton = T,type = "error")
        }
      }else if(input$whichvisual=="pubs"){
        #warning(input$years_dropdown)
        years.plot.panel(studies, input$years_dropdown,alpha=input$alpha, input$x.axis, input$y.axis,input$cex)
      }else if(input$whichvisual=="journals"){
        #warning(input$journals_dropdown)
        journal.plot.panel(studies, input$journals_dropdown,alpha=input$alpha, input$x.axis, input$y.axis,input$cex)
      }else{
        #warn.user <- T
        id <- showNotification(ui="I don't know how you did that.",duration=NULL,closeButton=T,type="error")
      }
      
    }
  )
  
  output$downloadPMIDs <- downloadHandler(
    filename = function() { 
      paste0("Top_",nrow(grabData()),"_PMIDS_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(grabData(), file,row.names = F,quote=T)
    })
  
  output$downloadStems <- downloadHandler(
    filename = function() { 
      paste0("Top_",nrow(grabData()),"_Stems_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(grabData(), file,row.names = F, quote=T)
    })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)