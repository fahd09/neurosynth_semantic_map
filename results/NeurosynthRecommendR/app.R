library(shiny)
load('./data/studies.rda')
load('./data/words.rda')
source('./helpers.R')

random.pmid <- sample(studies$pubmed,1)
random.stem <- sample(words$word,1)

# Define UI ----
ui <- fluidPage(
  
  titlePanel("Neurosynth RecommendR"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Choose your own adventure"),
      
      radioButtons("papers.or.words", label = "Study (PMID) or Stem (words)", choices = list("Papers" = 1, "Words" = 2),selected = 1),
      radioButtons("dot.colors", label = "Color scheme", choices = list("Cluster colors" = 1, "Grey" = 2),selected = 2),
      #sliderInput("Zoom",label = "Range of interest:",min = 0, max = 100, value = c(0, 100)),
      sliderInput("zoom.hits", label = "Number of similar items:",min = 5, max = 100, value = 5),
      sliderInput("alpha", label = "Color alpha levels:",min = 0, max = 1, value = .5),
      textInput("pmid.or.word", label = "PMID/Stem input", value = random.pmid)#,
      #selectInput("pmid.or.word_dropdown", h3("Choose paper/word"),choices = list("Choice 1" = 1, "Choice 2" = 2,"Choice 3" = 3), selected = 1),
      
    ),
    mainPanel(
        ## ugh.
      plotOutput("nr.space",height="600px",width="600px")
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  
  output$nr.space <- renderPlot(
    {
      if(input$papers.or.words==1){
        studies.plot.panel(studies,input$dot.colors,input$pmid.or.word,input$zoom.hits,input$alpha)
      }else{
        stems.plot.panel(words,input$dot.colors,input$pmid.or.word,input$zoom.hits,input$alpha)
      }
    }
  )
  
  # output$radiobutton1 <- renderText({ 
  #   paste("Radio button 1 is:", input$papers.or.words)
  # })
  # 
  # output$radiobutton2 <- renderText({ 
  #   paste("Radio button 2 is:", input$dot.colors)
  # })  
  # 
  # output$slider <- renderText({ 
  #   paste("Slider is:", input$zoom.hits)
  # })    
  # 
  # output$inputbox <- renderText({ 
  #   paste("Radio button 2 is:", input$pmid.or.word)
  # })    
  
}

# Run the app ----
shinyApp(ui = ui, server = server)