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

# Define UI ----
ui <- fluidPage(
  
  titlePanel("Neurosynth RecommendR"),
    ## we need some UI output to come back and then update the UI based on choices.
      ## we can do that much later.
  sidebarLayout(
    sidebarPanel(
      #helpText("Choose your own adventure"),
      #selectInput("which.visual","Choose visualizer type",choices=list("Papers (PMIDs)","Words (stems)","Publication Year","Journal"),selected=1),
      textInput("pmid.or.word", label = "PMID/Stem input", value = "19789183"),
      #selectInput("pmid.or.word_dropdown", "Choose paper/word", choices = studies$pubmed, selected = random.pmid),
      radioButtons("papers.or.words", label = "Study (PMID) or Stem (words)", choices = list("Papers" = 1, "Words" = 2),selected = 1),
      radioButtons("dot.colors", label = "Color scheme", choices = list("Cluster colors" = 1, "Grey" = 2),selected = 2),
      #sliderInput("Zoom",label = "Range of interest:",min = 0, max = 100, value = c(0, 100)),
      sliderInput("zoom.hits", label = "Number of similar items:",min = 5, max = 100, value = 5),
      sliderInput("alpha", label = "Color alpha levels:",min = 0, max = 1, value = .35),
      selectInput("x.axis","X axis",choices=c(1:5), selected=1),
      selectInput("y.axis","Y axis",choices=c(1:5), selected=2)
      ## we should add a "highlight journal" option button...
      ## and maybe a highlight year option...
    ),
    mainPanel(
        ## ugh.
      plotOutput("nr.space",height="700px",width="700px")
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  
  output$nr.space <- renderPlot(
    {
      if(input$papers.or.words==1){
        warn.user <- studies.plot.panel(studies,studies_top.101_indices,input$dot.colors,input$pmid.or.word,input$zoom.hits,input$alpha, input$x.axis, input$y.axis)
      }else{
        warn.user <- stems.plot.panel(words,words_top.101_indices,input$dot.colors,input$pmid.or.word,input$zoom.hits,input$alpha, input$x.axis, input$y.axis)
      }
      
      if(warn.user){
        id <- showNotification(ui=paste0(input$pmid.or.word," is not a valid choice."), duration = 3, closeButton = T,type = "error")
      }
      
    }
  )
}

# Run the app ----
shinyApp(ui = ui, server = server)