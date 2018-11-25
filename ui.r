library(openxlsx)
library(ggplot2)
library(plotly)
library(ggthemr)
library(crosstalk)
library(shiny)
library(scales)

#############################################################
#															#
#															#
#															#
#			NEVEK NÉPSZERŰSÉGE AZ ÉVEK MÚLÁSÁVAL 			#
#						BUMB CHART							#
#															#
#  															#
#															#
#															#
#############################################################

shinyUI(fluidPage(
  plotlyOutput("plot", height = "700px", width = "100%")
))
