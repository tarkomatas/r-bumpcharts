library(openxlsx)
library(ggplot2)
library(plotly)
library(ggthemr)
library(crosstalk)
library(shiny)
library(scales)

#-------------------------------------
# LOAD THE DATABASE
#-------------------------------------

database = read.xlsx("Hungarian_first_and_middle_name_db_1954_2016.xlsx", startRow = 1, colNames = TRUE)

##### recorde the years

db = database
db = database[database$YEAR >= 2000,]

##### top10 names in 2016

top10_name = db$NAME_MALE[db$YEAR == 2016 & db$RANK <= 10]

#-------------------------------------
# SHINY APP
#-------------------------------------

shinyServer(
	function(input, output) {

  data <- reactive({
		db = database
		db = database[database$YEAR >= 2000,]
		db = as.data.frame(xtabs(RANK ~ YEAR + eval(parse(text = "NAME_MALE")), data = db))
		colnames(db)[2] = "NAME_MALE"

		###### select only the top10
		top10_name = db$NAME_MALE[db$YEAR == 2016 & db$Freq <= 10 & db$Freq > 0]
		db = db[is.na(match(db$NAME_MALE, top10_name)) == FALSE,]

		###### override all the values which is greather than 10

		db$Freq[db$Freq > 10] = 11

		db = cbind(db, label = db$Freq)
		db$label[db$label == 11] = "10+"
		
		db
  })

  output$plot <- renderPlotly({
					pdf(NULL)
					db = data()
					
					db$YEAR = as.numeric(as.character(db$YEAR))
					
					sd <- SharedData$new(db, ~NAME_MALE, group = "Choose the first name You want to highlight")
					gg = ggplot(sd, aes(x = YEAR, y = Freq, colour = NAME_MALE, text = NAME_MALE)) + 
							geom_point(size = 8) + 
							geom_line(size = 1.1) +
							geom_text(aes(label = paste0("#",label)), color = "white", size=3.5) +
							scale_y_continuous("", limits = c(1,11), breaks = seq(0,11,1), labels = c(seq(0,10,1),"10+")) +
							scale_x_continuous("", breaks = seq(2000,2016,1)) +
							guides(colour = guide_legend(override.aes = list(size=1))) +
					    scale_y_reverse() +
							theme(legend.position="none",
							      axis.title.y=element_blank(),
							      axis.text.y=element_blank(),
							      axis.ticks.y=element_blank(),
							      panel.background = element_rect(fill = '#34495e'),
								    panel.grid.major = element_blank())

					gg <- ggplotly(gg, tooltip = c("text")) %>%
						highlight(on = "plotly_click", persistent = FALSE, selectize = TRUE)  

					gg
  })
}
)