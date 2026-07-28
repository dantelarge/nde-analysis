library(shiny)
library(tidyverse)
library(plotly)
library(DT)

theme_labels <- c(
  ai_clinical     = "Clinical death details",
  ai_obe          = "Out-of-body experience",
  ai_unity        = "Unity / oneness",
  ai_esp          = "Extrasensory perception",
  ai_hellish      = "Hellish elements",
  ai_past_lives   = "Past lives",
  ai_world_future = "Future visions",
  ai_aliens       = "Alien encounters"
)

ui <- fluidPage(
  titlePanel("Near Death Experiences — NDERF Archive"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      radioButtons(
        "gender_filter", "Filter by gender",
        choices = c("All", "Female" = "F", "Male" = "M"),
        selected = "All"
      ),
      hr(),
      checkboxGroupInput(
        "theme_filter", "Themes to include",
        choiceNames  = unname(theme_labels),
        choiceValues = names(theme_labels),
        selected     = names(theme_labels)
      )
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Overall themes", plotlyOutput("plot_overall", height = "450px")),
        tabPanel("By gender",      plotlyOutput("plot_gender",  height = "450px")),
        tabPanel("Data",           DTOutput("table"))
      )
    )
  )
)

server <- function(input, output, session) {

  nde_raw <- reactive({
    readr::read_csv(
      "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-07-21/nde_experiences.csv",
      show_col_types = FALSE
    )
  })

  nde_filtered <- reactive({
    df <- nde_raw()
    if (input$gender_filter != "All") df <- filter(df, gender == input$gender_filter)
    df
  })

  selected_themes <- reactive({
    req(length(input$theme_filter) > 0)
    input$theme_filter
  })

  theme_counts <- reactive({
    nde_filtered() %>%
      select(entry_id, all_of(selected_themes())) %>%
      pivot_longer(-entry_id, names_to = "theme", values_to = "present") %>%
      group_by(theme) %>%
      summarise(n_present = sum(present, na.rm = TRUE), total = n(), .groups = "drop") %>%
      mutate(pct = n_present / total * 100, label = theme_labels[theme])
  })

  theme_gender <- reactive({
    nde_filtered() %>%
      filter(gender %in% c("F", "M")) %>%
      select(entry_id, gender, all_of(selected_themes())) %>%
      pivot_longer(-c(entry_id, gender), names_to = "theme", values_to = "present") %>%
      group_by(theme, gender) %>%
      summarise(n_present = sum(present, na.rm = TRUE), total = n(), .groups = "drop") %>%
      mutate(
        pct          = n_present / total * 100,
        label        = theme_labels[theme],
        gender_label = if_else(gender == "F", "Female", "Male")
      )
  })

  output$plot_overall <- renderPlotly({
    p <- ggplot(
      theme_counts(),
      aes(
        x    = reorder(label, pct),
        y    = pct,
        text = paste0(label, "\n", round(pct, 1), "% (", n_present, " / ", total, ")")
      )
    ) +
      geom_col(fill = "#2c7fb8") +
      coord_flip() +
      scale_y_continuous(limits = c(0, 100)) +
      labs(x = NULL, y = "% of experiences") +
      theme_minimal(base_size = 13)

    ggplotly(p, tooltip = "text") %>%
      layout(margin = list(l = 180))
  })

  output$plot_gender <- renderPlotly({
    p <- ggplot(
      theme_gender(),
      aes(
        x    = reorder(label, pct),
        y    = pct,
        fill = gender_label,
        text = paste0(label, " — ", gender_label, "\n",
                      round(pct, 1), "% (", n_present, " / ", total, ")")
      )
    ) +
      geom_col(position = "dodge") +
      coord_flip() +
      scale_y_continuous(limits = c(0, 100)) +
      scale_fill_manual(values = c("Female" = "#e07a8b", "Male" = "#2c7fb8")) +
      labs(x = NULL, y = "% of experiences", fill = NULL) +
      theme_minimal(base_size = 13)

    ggplotly(p, tooltip = "text") %>%
      layout(margin = list(l = 180))
  })

  output$table <- renderDT({
    nde_filtered() %>%
      rename_with(~ theme_labels[.x], starts_with("ai_")) %>%
      datatable(
        filter  = "top",
        options = list(pageLength = 20, scrollX = TRUE)
      )
  })
}

shinyApp(ui, server)
