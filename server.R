




server <- function(input, output, session) {
  
  # la carte de l'onglet cartographie
  output$map <- renderLeaflet({
    df <- dr %>% 
      filter(year == input$year_map & !is.na(rate))
    
    # Joindre avec les codes pays disponibles dans leaflet::countrycode
    world <- rnaturalearth::ne_countries(returnclass = "sf")
    map_data <- left_join(world, df, by = c("iso_a3" = "iso_code"))
    
    pal <- colorNumeric("YlOrRd", domain = map_data$rate)
    
    leaflet(map_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(rate),
        color = "#444444",
        weight = 0.3,
        fillOpacity = 0.7,
        popup = ~paste0(name, "<br/>rate : ", format(rate, big.mark = " "))
      ) %>%
      addLegend(pal = pal, values = ~rate,
                title = "rate totale",
                position = "bottomright")
  })
  
  
  # la table des données
  output$table = renderDT({heart})
  
  # la table des variables explicatives
  output$var = renderDT({variables})
  
  # histogramme en fonction des variables mesurables de l'onglet Explorer
  output$hist_var_num = renderPlot({
    ggplot(heart) + 
      aes_string(x = input$var_num, fill = "as.factor(output)") +
      geom_histogram(binwidth = 5, position = "dodge") +
      scale_fill_manual(values = c("0" = "#00BFC4", "1" = "#F8766D"),
                        name = "Maladie Cardiaque",
                        labels = c("Non", "Oui")) +
      xlab(input$var_num) +
      ylab("Nombre de Patients") +
      ggtitle(paste("Distribution de", input$var_num, "selon la présence de maladie cardiaque"))
  })
  
  
  
  
  # histogramme en fonction des variables non mesurables de l'onglet Explorer
  output$hist_var_non_num = renderPlot({
    ggplot(heart) +
      aes_string(x = input$var_non_num, fill = "as.factor(output)") +
      geom_bar(position = "dodge") +
      scale_fill_manual(values = c("0" = "#00BFC4", "1" = "#F8766D"),
                        name = "Maladie Cardiaque",
                        labels = c("Non", "Oui")) +
      xlab(input$var_non_num) +
      ylab("Nombre de Patients") +
      ggtitle(paste("Répartition de", input$var_non_num, "selon la présence de maladie cardiaque"))
  })
  
  
  # Charger les données pour le modèle 1
  modele1_perf <- reactive({
    readRDS("www/modeles/modele1_performance.rds")
  })
  
  modele1_final <- reactive({
    readRDS("www/modeles/modele1_final.rds")
  })
  
  
  
  # Affichages pour le modèle 1
  output$conf_matrix1 <- renderPlot({
    
    
    ggplot(as.data.frame(modele1_perf()$confusion)) +
      geom_text(
        aes(x = obs,y = prev,label = Freq,
            color = ifelse((prev == 1 & obs == 0) | (prev == 0 & obs == 1), "Erreur", "Correct")),size = 10
      ) +
      scale_color_manual(values = c("Correct" = "green", "Erreur" = "red")) +
      labs(x = "Observé", y = "Prédit", title = "Matrice de Confusion - Modèle 1",color = "Légende"
      ) +
      theme_minimal()
  })
  
  output$roc_curve1 <- renderPlot({
    plot(modele1_perf()$roc_curve, main = "Courbe ROC - Modèle 1(modèle complet)",col="pink")
    legend("bottomright", legend = paste("AUC =", round(auc(modele1_perf()$roc_curve), 3)*100,"%"))
  })
  
  output$metrics1 <- renderPrint({lapply(modele1_perf()$metrics, function(x) { paste0(format(round(x * 100, 1), nsmall = 1), "%") })
  })
  
  
  
  
  # Charger les données pour le modèle 2
  modele2_perf <- reactive({
    readRDS("www/modeles/modele2_performance.rds")
  })
  
  modele2_final <- reactive({
    readRDS("www/modeles/modele2_final.rds")
  })
  
  # Affichages pour le modèle 2
  output$conf_matrix2 <- renderPlot({
    ggplot(as.data.frame(modele1_perf()$confusion)) +
      geom_text(
        aes(x = obs,y = prev,label = Freq,
            color = ifelse((prev == 1 & obs == 0) | (prev == 0 & obs == 1), "Erreur", "Correct")),size = 10
      ) +
      scale_color_manual(values = c("Correct" = "green", "Erreur" = "red")) +
      labs(x = "Observé", y = "Prédit", title = "Matrice de Confusion - Modèle 2",color = "Légende"
      ) +
      theme_minimal()
  })
  
  output$roc_curve2 <- renderPlot({
    plot(modele2_perf()$roc_curve, main = "Courbe ROC - Modèle 2(modèle avec Anova)",col="purple")
    legend("bottomright", legend = paste("AUC =", round(auc(modele2_perf()$roc_curve), 3)*100,"%"))
  })
  
  output$metrics2 <- renderPrint({
    metrics <- modele2_perf()$metrics
    metrics$AUC <- as.numeric(modele2_perf()$roc_curve$auc)
    lapply(metrics, function(x) paste0(round(x * 100, 1), "%"))
  })
  
  
  
  
  # Chargement des données de test 
  dtest_data <- reactive({
    readRDS("www/modeles/dtest.rds") |> 
      mutate(across(where(is.character), as.factor))
  })
  
  
  
  # ----------------------------------------------------------
  # Sorties pour le Modèle 1 (md3bis)
  # ----------------------------------------------------------
  
  output$var_importance1 <- renderPlot({
    model <- modele1_final()
    
    broom::tidy(model) |> 
      filter(term != "(Intercept)") |> 
      ggplot(aes(x = reorder(term, estimate), y = abs(estimate), 
                 fill = ifelse(estimate > 0, "Augmente le risque", "Diminue le risque"))) +
      geom_col() +
      coord_flip() +
      scale_fill_manual(values = c("Augmente le risque" = "red", "Diminue le risque" = "blue")) +
      labs(title = "Impact des Variables (Modèle 1 - Toutes les variables explicatives de la base de donnée)",
           x = "",
           y = " ",
           fill = "Effet") +
      theme_minimal()
  })
  
  output$coef_table1 <- renderDT({
    model <- modele1_final()
    
    broom::tidy(model) |> 
      mutate(
        `Ratio de cotes` = exp(estimate),
        Significativité = case_when(
          p.value < 0.001 ~ "***",
          p.value < 0.01 ~ "**",
          p.value < 0.05 ~ "*",
          TRUE ~ ""
        )
      ) |> 
      select(
        Variable = term,
        Coefficient = estimate,
        `Ratio de cotes`,
        `p-value` = p.value,
        Significativité
      ) |> 
      datatable(
        options = list(
          pageLength = 10,
          dom = 'Bfrtip'
        )
      ) |> 
      formatRound(columns = c(2:4), digits = 3)
  })
  
  # ----------------------------------------------------------
  # Sorties pour le Modèle 2 (mAbis)
  # ----------------------------------------------------------
  
  output$var_importance2 <- renderPlot({
    model <- modele2_final()
    
    broom::tidy(model) |> 
      filter(term != "(Intercept)") |> 
      ggplot(aes(x = reorder(term, estimate), y = abs(estimate), 
                 fill = ifelse(estimate > 0, "Augmente le risque", "Diminue le risque"))) +
      geom_col() +
      coord_flip() +
      scale_fill_manual(values = c("Augmente le risque" = "red", "Diminue le risque" = "blue")) +
      labs(title = "Impact des Variables (Modèle 2 - Sélection de variables avec Anova)",
           x = "",
           y = " ",
           fill = "Effet") +
      theme_minimal()
  })
  
  output$coef_table2 <- renderDT({
    model <- modele2_final()
    
    broom::tidy(model) |> 
      mutate(
        `Ratio de cotes` = exp(estimate),
        Significativité = case_when(
          p.value < 0.001 ~ "***",
          p.value < 0.01 ~ "**",
          p.value < 0.05 ~ "*",
          TRUE ~ ""
        )
      ) |> 
      select(
        Variable = term,
        Coefficient = estimate,
        `Ratio de cotes`,
        `p-value` = p.value,
        Significativité
      ) |> 
      datatable(
        options = list(
          pageLength = 10,
          dom = 'Bfrtip'
        )
      ) |> 
      formatRound(columns = c(2:4), digits = 3)
  })
  
  
  
    
  # Initialisation des valeurs réactives
  values <- reactiveValues(
    risk_score = 0,
    risk_percent = 0
  )
  
  # Dynamic inputs UI
  output$dynamic_inputs <- renderUI({
    if (input$selected_model == "full") {
      tagList(
        numericInput("age", "Âge (années)", value = 50, min = 20, max = 100),
        selectInput("sexe", "Sexe", choices = c("Homme" = "1", "Femme" = "0")),
        selectInput("cp","Type de douleur thoracique",choices = c( "Angine typique (Typical Angina)"="1", " Angine atypique (Atypical Angina)"="2", " Douleur non angineuse (Non-Anginal Pain)"="3"
                                                                  ,  "Asymptomatique (Asymptomatic)"="4")),
       numericInput( "trtbps" ,"Pression artérielle systolique (au repos, mmHg) :",value = 120,min = 80,max = 250),
       
       numericInput("caa","Nombre de vaisseaux coronaires obstrués (0-3) :",value = 0, min = 0,max = 3),
      selectInput("fumeur", "Fumeur actuel", choices = c("Non" = "0", "Oui" = "1"))
        
      )
    } else {
      tagList(
        numericInput("age_simple", "Âge (années)", value = 50, min = 20, max = 100),
        selectInput("sexe_simple", "Sexe", choices = c("Homme" = "1", "Femme" = "0")),
        selectInput("cp_simple","Type de douleur thoracique",choices = c( "Angine typique (Typical Angina)"="1", " Angine atypique (Atypical Angina)"="2", " Douleur non angineuse (Non-Anginal Pain)"="3"
                                                                   ,  "Asymptomatique (Asymptomatic)"="4")),
        numericInput("trtbps_simple", "Pression artérielle systolique (mmHg)", value = 120, min = 80, max = 250),
        numericInput("caa_simple","Nombre de vaisseaux coronaires obstrués (0-3) :",value = 0, min = 0,max = 3),
        selectInput("fumeur_simple", "Fumeur actuel", choices = c("Non" = "0", "Oui" = "1")),
        numericInput("chol", "Taux de cholestérol (en mg/dl)", value = 200, min = 100, max = 400),
        numericInput( "oldpeak","Dépression du segment ST à l'effort (mm) :",value = 0.0, min = 0.0, max = 6.0, step = 0.1,  
          width = "150px" )
        
      )
    }
  })
  
  # Affichage du modèle utilisé
  output$model_used <- renderUI({
    if (input$predict_btn == 0) return(NULL)
    
    model_name <- if (input$selected_model == "full") {
      "Modèle1 Complet (toutes variables)"
    } else {
      "Modèle2 Simplifié (variables sélectionnées avec Anova)"
    }
    
    HTML(paste0("<div style='margin-bottom: 20px;'><strong>Modèle utilisé :</strong> ", model_name, "</div>"))
  })
  
  # Calcul du risque et affichage
  observeEvent(c(input$predict_btn, input$selected_model), {
    # Vérification ultra-robuste des inputs
    req(input$age, input$sexe, input$trtbps)
    
    tryCatch({
      # Calcul du score
      if (input$selected_model == "full") {
        values$risk_score <- (
          as.numeric(input$age) * 0.06 +
            as.numeric(input$sexe) * 0.8 +
            (as.numeric(input$trtbps) - 120) * 0.025 +
            as.numeric(input$fumeur) * 0.6 +
            ifelse(input$cp == "1", 0.7, 0))
      } else {
        values$risk_score <- (
          as.numeric(input$age_simple) * 0.05 +
            as.numeric(input$sexe_simple) * 0.7 +
            (as.numeric(input$trtbps_simple) - 120) * 0.02 +
            as.numeric(input$caa_simple) * 0.5 +
            as.numeric(input$fumeur_simple) * 0.4 +
            ifelse(input$cp_simple %in% c("1","2"), 0.6, 0) +
            as.numeric(input$oldpeak) * 0.3 +
            (as.numeric(input$chol) - 200) * 0.003
        )
      }
      
      # Normalisation
      values$risk_percent <- pmin(pmax(values$risk_score * 10, 0), 100)
      
      # Debug
      print(paste("Score calculé:", values$risk_percent))
      
      # Force l'update
      session$sendCustomMessage("forceRiskUpdate", list())
      
    }, error = function(e) {
      showNotification("Erreur de calcul. Vérifiez les valeurs.", type = "error")
    })
  }, ignoreNULL = FALSE)
  
  # Jauge de risque
  output$risk_gauge <- renderPlotly({
    if (input$predict_btn == 0) return(NULL)
    
    fig <- plot_ly(
      domain = list(x = c(0, 1), y = c(0, 1)),
      value = values$risk_percent,
      title = list(text = "Risque cardiovasculaire"),
      type = "indicator",
      mode = "gauge+number",
      gauge = list(
        axis = list(range = list(NULL, 100), tickwidth = 1, tickcolor = "darkblue"),
        bar = list(color = "blue"),
        bgcolor = "white",
        borderwidth = 2,
        bordercolor = "gray",
        steps = list(
          list(range = c(0, 30), color = "green"),
          list(range = c(30, 70), color = "yellow"),
          list(range = c(70, 100), color = "red")
        )
      )
    )
    
    fig
  })
  # Interprétation du risque
  output$risk_interpretation <- renderUI({
    req(values$risk_percent)  # Nécessite le calcul
    
    risk_level <- if (values$risk_percent < 30) {
      "<span style='color:green;'>Faible</span>"
    } else if (values$risk_percent < 70) {
      "<span style='color:orange;'>Modéré</span>"
    } else {
      "<span style='color:red;'>Élevé</span>"
    }
    
    HTML(paste0("<div style='margin-top:20px;'>
            <strong>Niveau de risque :</strong> ", risk_level, "<br>
            <strong>Score :</strong> ", round(values$risk_percent, 1), "/100</div>"))
  })
  
  ########recommendations########
  
  output$recommendations <- renderUI({
    # Vérification basique
    if(input$predict_btn == 0) return(NULL)
    
    # Liste des recommandations de base
    recoms <- list()
    
    # Déterminer quels inputs utiliser selon le modèle sélectionné
    if(input$selected_model == "full") {
      age <- input$age
      trtbps <- input$trtbps
      cp <- input$cp
      fumeur <- input$fumeur
      caa <- input$caa
    } else {
      age <- input$age_simple
      trtbps <- input$trtbps_simple
      cp <- input$cp_simple
      fumeur <- input$fumeur_simple
      caa <- input$caa_simple
      oldpeak <- input$oldpeak
      chol<-input$chol
    }
    
    # Vérifier que les inputs nécessaires existent
    req(age, trtbps, cp, fumeur, caa)
    
    # 1. Recommandation Âge
    if(age > 60) {
      recoms$age <- tags$div(
        icon("user-clock"), 
        "Surveillance cardiologique annuelle recommandée (", age, " ans)"
      )
    }
    
    # 2. Recommandation Tension
    if(trtbps >= 140) {
      recoms$trtbps <- tags$div(
        icon("heart-pulse"), 
        tags$strong(paste("Tension artérielle élevée :", trtbps, "mmHg")),
        tags$ul(
          tags$li("Consultation urgente pour hypertension chez un spécialiste"),
          tags$li("Réduire la consommation de sel et de sodium"),
          tags$li("Faire de l'exercice régulièrement (au moins 30 minutes par jour)"),
          tags$li("Éviter les substances stimulantes comme la caféine et le tabac")
        )
      )
    } else if(trtbps >= 130) {
      recoms$trtbps <- tags$div(
        icon("heart-pulse"), 
        "Surveillance tensionnelle recommandée (", trtbps, " mmHg)"
      )
    } else if(trtbps <= 90) {
      recoms$trtbps <- tags$div(
        icon("heart-pulse"), 
        tags$strong(paste("Tension artérielle basse :", trtbps, "mmHg")),
        tags$ul(
          tags$li("Boire suffisamment d'eau pour éviter la déshydratation"),
          tags$li("Augmenter la consommation de sel et de liquides"),
          tags$li("Faire exercice régulièrement pour améliorer la circulation sanguine"),
          tags$li("Éviter les substances qui peuvent abaisser la pression artérielle")
        )
      )
    }
    
    # 3. Type de douleur thoracique
    if(cp == "1") {
      recoms$cp <- tags$div(
        icon("stethoscope"),
        tags$strong("Douleur thoracique typique (angine d'effort)"),
        tags$ul(
          tags$li("Consulter un cardiologue dès que possible"),
          tags$li("Faire un test d'effort ou un ECG de repos"),
          tags$li("Éviter les efforts intenses sans avis médical")
        )
      )
    } else if(cp == "2") {
      recoms$cp <- tags$div(
        icon("heart"),
        tags$strong("Douleur thoracique atypique"),
        tags$ul(
          tags$li("Faire un bilan cardiovasculaire pour exclure une cause cardiaque"),
          tags$li("Surveiller si la douleur s'aggrave à l'effort ou au repos")
        )
      )
    } else if(cp == "3") {
      recoms$cp <- tags$div(
        icon("lungs"),
        tags$strong("Douleur non angineuse"),
        tags$ul(
          tags$li("Évaluer les causes non cardiaques (digestives, musculaires, pulmonaires)"),
          tags$li("Repos, réduction du stress, et traitement symptomatique")
        )
      )
    } else if(cp == "4") {
      recoms$cp <- tags$div(
        icon("exclamation-triangle"),
        tags$strong("Asymptomatique mais anomalies détectées"),
        tags$ul(
          tags$li("Suivi régulier chez un spécialiste"),
          tags$li("Explorer les autres facteurs de risque cardiovasculaires")
        )
      )
    }
    
    # 4. Vaisseaux obstrués
    if(caa > 0) {
      recoms$caa <- tags$div(
        icon("heart-crack"), 
        caa, " vaisseau(x) obstrué(s) - Angiographie recommandée"
      )
    }
    
    # 5. Tabagisme
    if(fumeur == "1") {
      recoms$fumeur <- tags$div(
        icon("smoking"), 
        "Arrêt tabagique urgent recommandé"
      )
    }
    
    # 6. Recommandation Cholestérol (uniquement pour le modèle 2)
    if(input$selected_model != "full") {
      if(input$chol >= 240) {
        recoms$chol <- tags$div(
          icon("vial"),
          tags$strong(paste("Cholestérol très élevé :", input$chol, "mg/dL")),
          tags$ul(
            tags$li("Bilan lipidique complet recommandé"),
            tags$li("Régime pauvre en graisses saturées"),
            tags$li("Activité physique régulière (30 min/jour)"),
            tags$li("Consultation médicale pour évaluation")
          )
        )
      } else if(input$chol >= 200) {
        recoms$chol <- tags$div(
          icon("vial"),
          paste("Cholestérol élevé :", input$chol, "mg/dL - Surveillance recommandée")
        )
      } else if(input$chol < 200) {
        recoms$chol <- tags$div(
          icon("vial"),
          paste("Cholestérol normale :", input$chol, "mg/dL - Vérification recommandée")
        )
      }
    
  }
    # 7. Recommandation Dépression ST (uniquement pour le modèle 2)
    if(input$selected_model != "full") {
      if(input$oldpeak >= 2.0) {
        recoms$oldpeak <- tags$div(
          icon("heart-crack"),
          tags$strong(paste("Dépression ST sévère :", input$oldpeak, "mm")),
          tags$ul(
            tags$li("Consultation cardiologique urgente"),
            tags$li("Évaluation pour syndrome coronarien aigu"),
            tags$li("Éviter tout effort physique intense")
          )
        )
      } else if(input$oldpeak >= 1.0) {
        recoms$oldpeak <- tags$div(
          icon("heartbeat"),
          tags$strong(paste("Dépression ST modérée :", input$oldpeak, "mm")),
          tags$ul(
            tags$li("Bilan cardiologique recommandé"),
            tags$li("Test d'effort supervisé"),
            tags$li("Surveillance des symptômes")
          )
        )
      } else if(input$oldpeak > 0.5) {
        recoms$oldpeak <- tags$div(
          icon("heartbeat"),
          paste("Dépression ST légère :", input$oldpeak, "mm - Surveillance conseillée")
        )
      }
  
   
      
    }
    
    # Affichage final
    if(length(recoms) > 0) {
      tagList(
        h4("Recommandations personnalisées :"),
        recoms
      )
    } else {
      tags$div(
        icon("check"), 
        " Aucune recommandation spécifique",
        style = "color:green;"
      )
    }
  })

  
  }



