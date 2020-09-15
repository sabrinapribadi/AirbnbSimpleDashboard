

# Define UI for application that draws a histogram
shinyUI(
    
    dashboardPage(
        
        dashboardHeader(title = "London Airbnb") , 
        
        dashboardSidebar( 
            
            sidebarMenu(
                
                menuItem(text = "Dashboard", icon = icon("globe-europe"), tabName = "dashboard" ) ,
                
                menuItem(text = "Statistics", icon = icon("chalkboard"), tabName = "stat") ,
                
                menuItem(text = "Data", icon = icon("database"), tabName = "data")
            )
            
        ) ,
        
        dashboardBody(  
            
            tabItems( 
                
                tabItem(tabName = "dashboard", align = "center",
                        
                        # page header
                        h2("London Airbnb Distribution") ,
                        
                        ## widget input
                        div(style = "display:inline-block",
                            pickerInput(inputId = "selectBorough", 
                                        label = "Select Borough",
                                        multiple = T,
                                        selected = c("Westminster"), 
                                        choices = unique(as.character(london_listing$neighbourhood)),
                                        options = list(`actions-box` = TRUE,
                                                       `none-selected-text` = "Please make a selection!"))
                        ) ,
                        div(style = "display:inline-block",
                            pickerInput(inputId = "selectRoom", 
                                        label = "Select Room Type",
                                        multiple = T,
                                        selected = c("Entire home/apt"), 
                                        choices = unique(as.character(london_listing$room_type)),
                                        options = list(`actions-box` = TRUE,
                                                       `none-selected-text` = "Please make a selection!"))
                        ) ,
                        sliderInput(inputId = "selectPrice", 
                                    label = "Price Range",
                                    min = 0, 
                                    max = max(london_listing$price), 
                                    value = 300
                        ) ,
                        
                        
                        ## leaflet London maps
                        leafletOutput(outputId = "dash_maps")
                        
                ) ,   
                
                tabItem(tabName = "stat", align = "center",
                        
                        column(3, align = "left",
                               
                               h2("Statistic Informations", align = "center"),
                               
                               uiOutput("airbnbInfo")
                               
                        ),
                        
                        column(9, align = "center",
                               
                               h2("Top-N Borough"),
                               
                               sliderInput(inputId = "topN", 
                                           label = "Select Top-N Value",
                                           min = 0, 
                                           max = 10, 
                                           value = 5),
                               
                               box(
                                   
                                   plotOutput(outputId = "topNmost")
                                   
                               ),
                               
                               box(
                                   
                                   plotOutput(outputId = "topNmostbyroom")
                                   
                               )
                               
                               
                               
                        )
                        
                ),   
                
                
                tabItem(tabName = "data",
                        
                        h2("London Listings"), # h2 = heading 2
                        
                        DT::dataTableOutput(outputId = "table")
                        
                )  
                
            )
            
        )
        
    )
)