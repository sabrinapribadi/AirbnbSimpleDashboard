

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # --- Reactive Function --- #
  
  
  # for dashboard page
  londons <- reactive({
    
    selectBorough = input$selectBorough
    selectRoom = input$selectRoom
    selectPrice = input$selectPrice
    london_listing %>%
      filter(neighbourhood %in% selectBorough) %>% 
      filter(room_type %in% selectRoom) %>% 
      filter(price <= selectPrice)
      
    
  })
  
  # for statistic page
  numTopN <- reactive({
    
    as.numeric(input$topN)
    
  })
  
  
  n_bor <- reactive({
    
    length(unique(london_listing$neighbourhood))
    
    
  })
  
  n_host <- reactive({
    
    l_host <-  number(length(unique(london_listing$host_name)), big.mark = ',', accuracy = 1)
    
    
  })
  
  avg_rent <- reactive({
    
    london_listing %>% 
      group_by(year) %>% 
      summarize(avg_price = mean(price, na.rm = TRUE)) %>% 
      na.omit() %>% 
      top_n(1) %>% 
      mutate(avg_price = number(avg_price, big.mark = ',', accuracy = 0.01))
    
  })
  
  
  # --- Dashboard Page --- #
  
  
  # Show London maps
  output$dash_maps <- renderLeaflet({
    
    leaflet() %>% 
      setView(-0.103894, 51.503971, zoom = 10) %>%
      addTiles() %>%
      addPolygons(data = london_neigh, color = "#444444", weight = 2, opacity = 1) %>% 
      addMarkers(lng = londons()$longitude, 
                 lat = londons()$latitude,
                 clusterOptions = markerClusterOptions(),
                 label = paste0("Host Name: ", londons()$host_name),
                 popup = paste0("Borough: ", londons()$neighbourhood,
                                "<br>Room Type: ", londons()$room_type,
                                "<br>Price: $", londons()$price,
                                "<br>Min. Night: ", londons()$minimum_nights," night(s)"))
  })
  
  
  # --- Statistic Page --- #
  
  
  # Show top-N the most listings
  output$topNmost <- renderPlot({
    
    london_listing %>% 
      group_by(neighbourhood) %>% 
      summarize(sum_neigh = n()) %>% 
      arrange(-sum_neigh) %>% 
      head(numTopN()) %>% 
      ggplot() +
      geom_bar(aes(reorder(as.factor(neighbourhood), sum_neigh), sum_neigh, fill=neighbourhood), stat = 'identity') +
      geom_text(aes(neighbourhood, sum_neigh, label = sum_neigh), hjust = 2.0,  color = "white") +
      scale_fill_brewer(palette = "Set3") +
      theme(legend.position = 'none') +
      ggtitle("The Most Listing Borough") + 
      xlab("Neighbourhood") + 
      ylab("Number of Listings") +
      theme(legend.position = 'none',
            plot.title = element_text(color = 'black', size = 14, face = 'bold', hjust = 0.5),
            axis.title.y = element_text(),
            axis.title.x = element_text()) +
      coord_flip()
    
  })
  
  
  output$topNmostbyroom <- renderPlot({
    
    mostlisting_byroom %>% 
      arrange(-count_n4, -freq_room) %>% 
      head(4*numTopN()) %>% 
      ggplot()+
      geom_col(aes(x = reorder(room_type, avg_price_room), 
                   y = avg_price_room,
                   fill = room_type), 
               position = "dodge") +
      scale_fill_brewer(palette = "Reds") +
      theme(legend.position = 'none') +
      ggtitle("Average Price by Room Type") +
      xlab("Borough") + 
      ylab("Mean Price ($)") +
      theme(legend.position = "none",
            plot.title = element_text(color = "black", size = 14, face = "bold", hjust = 0.5),
            plot.subtitle = element_text(color = "darkblue", hjust = 0.5),
            axis.title.y = element_text(),
            axis.title.x = element_text(),
            axis.ticks = element_blank()) +
      facet_wrap(~ neighbourhood, ncol = 2) +
      coord_flip()
    
  })
  
  
  
  
  
  
  output$airbnbInfo <- renderUI({
    list(
      infoBox(
        title = "Number of Boroughs",
        value = n_bor(),
        color = "teal", 
        fill = T, 
        width = NULL
      ),
      infoBox(
        title = "Number of hosts",
        value = n_host(),
        color = "maroon", 
        fill = T, 
        width = NULL
      ),
      infoBox(
        title = "Avg. Rent per Night ($)",
        value = avg_rent()[, 2],
        color = "aqua", 
        fill = T, 
        width = NULL
      )
    )
  })
  
  
  
  # --- Data Page --- #
  
  
  # Show Data
  output$table <- DT::renderDataTable({
    
    london_listing
  })
  
})
