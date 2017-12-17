library(shiny)
load('./data/studies.rda')
load('./data/words.rda')
source('./helpers.R')
# Define UI ----
ui <- fluidPage(
  
  titlePanel("Neurosynth RecommendR"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Choose your own adventure"),
      
      radioButtons("papers.or.words", h3("Papers or Words"), choices = list("Papers" = 1, "Words" = 2),selected = 1),
      radioButtons("dot.colors", h3("Color scheme"), choices = list("Cluster colors" = 1, "Grey" = 2),selected = 2),
      #sliderInput("Zoom",label = "Range of interest:",min = 0, max = 100, value = c(0, 100)),
      #selectInput("number.hits", h3("Number of similar papers/words"),choices = list("5" = 1, "10" = 2,"25" = 3, "50" = 4, "100" = 5), selected = 1),
      sliderInput("zoom.hits", label = "Range of interest:",min = 5, max = 100, value = 5),
      textInput("pmid.or.word", h3("Text input"), value = "Enter PMID or Word")#,
      #selectInput("pmid.or.word_dropdown", h3("Choose paper/word"),choices = list("Choice 1" = 1, "Choice 2" = 2,"Choice 3" = 3), selected = 1),
      #submitButton("Go!")
      
    ),
    mainPanel(
      #textOutput("radiobutton1"),
      #textOutput("radiobutton2"),
      #textOutput("slider"),
      #textOutput("inputbox")
      #sliderInput("Zoom", label = "Range of interest:",min = 0, max = 100, value = c(0, 100))
      plotOutput("nr.space")
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  
  output$nr.space <- renderPlot(
    {
      if(input$papers.or.words==1){
        nr.base.studies.plot(studies)
      }else{
        
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