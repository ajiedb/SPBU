library(shiny)
library(ShinyDash)

shinyUI(fluidPage(
    fluidRow(style = "background-color:#4C4646;",
      column(1),
      column(2),
      column(3),
      column(4,uiOutput('dropdown1')),
      column(5),
      column(6)
    ),
    fluidRow(style = "background-color:#4C4646;",
      column(1),
      column(2,tags$img(src="title.jpg")),
      column(3),
      column(4,uiOutput('dropdown2')),
      column(5),
      column(6)
    ),
    fluidRow(style = "background-color:#4C4646;",
      column(1),
      column(2,includeHTML("www/Index.html")),
      column(3),
      column(4),
      column(5),
      column(6)
    )
  ))
  
