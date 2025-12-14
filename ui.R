ui <- navbarPage(
  title = "CardioVision", theme = shinytheme("flatly"),
  
  # 1. Onglet Accueil
  tabPanel(title = "Accueil",
           div(h1(tags$b("CardioVision : L'IA au service du Cœur" ,style="color: #008B8B;")),
               p("Et si une simple application pouvait sauver des vies en prédisant les risques cardiaques invisibles ?"),
               hr(),
               br(),
               p(img(src= "img/104200.jpg",width="45%")), align="center"),
           
           tags$head(
             tags$style(HTML("
    body {
      background-color: #e0ffff;
    }
  "))
           ),
           
           hr(),
           br(),
           
           p("Bienvenue sur l’application de prédiction du risque d’attaque cardiaque."),
           p("Dans un contexte où les maladies cardiovasculaires sont l'une des principales causes de mortalité dans
              le monde, comment utiliser les données médicales des patients pour prédire les risques d’attaque 
              cardiaque et favoriser une prévention plus efficace ?"),
           
           div(
             style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #3498db;",
             
             p("Pour la petite histoire, les maladies cardiovasculaires (MCV) représentent aujourd’hui la première cause 
           de mortalité dans le monde. Selon l’Organisation mondiale de la Santé (OMS), elles sont responsables de près 
           de 18 millions de décès chaque année, soit environ" ,tags$b("32%"), "des décès mondiaux (source : ",
               tags$a(href = "https://www.who.int/news-room/fact-sheets/detail/cardiovascular-diseases-(cvds)", "OMS"), ")."),
             
             p("La grande majorité de ces décès, environ" ,tags$b("85%"), ", surviennent dans des pays à revenus faibles ou 
           intermédiaires, ce qui souligne l’impact des inégalités d’accès à la prévention et aux soins (source : OMS)."),
             
             p("Les hommes sont globalement plus touchés que les femmes, avec un risque de mortalité" ,tags$b("2,5"), "fois 
           plus élevé selon une étude de la European Society of Cardiology. En moyenne, les maladies cardiovasculaires sont 
           diagnostiquées 7 à 10 ans plus tôt chez les hommes (source : ",
               tags$a(href = "https://www.escardio.org/The-ESC/Press-Office/Press-releases/sex-gaps-in-cardiovascular-disease", 
                      "ESC"), ")."),
             
             p("Parmi les principaux facteurs de risque modifiables, on retrouve notamment : l’hypertension artérielle 
           (responsable de plus de 10 millions de décès selon le rapport OMS 2023 sur l’hypertension), l’obésité, 
           le tabagisme, une alimentation déséquilibrée, la sédentarité et la pollution de l’air."),
             
             p("La bonne nouvelle, c’est qu’environ",tags$b("80%"), "des infarctus du myocarde et des AVC prématurés peuvent 
           être évités grâce à une prévention adaptée (source : ",
               tags$a(href = "https://world-heart-federation.org/resources/world-heart-day-key-messages/", "World Heart Federation"), 
               ")."),
             
             p("Enfin, selon les données de Our World in Data, le nombre annuel de décès dus aux MCV est passé 
           de" ,tags$b("14 millions"), "en 2000 à plus de" ,tags$b("18 millions"), "en 2019 (source : ",
               tags$a(href = "https://ourworldindata.org/grapher/deaths-cardiovascular-diseases-number", "OWID", ), ")."), 
             style = "color: #2c3e50;"),
           
           div(
             style = "background-color: #fff3cd; padding: 10px; border-radius: 5px;",
             
             p(markdown("**Notre Mission :** Explorer, Comprendre, Prévenir.")),
             p(markdown("Notre projet **CardioVision** vise à mettre la data science au service de la santé cardiaque, en transformant 
              des données médicales brutes en outils concrets pour identifier les risques invisibles : ")),
             p(markdown("- **EXLORER :** Plongez dans les données pour découvrir les liens cachés entre les facteurs de risque (âge, 
              cholestérol, tension artérielle...) et les problèmes cardiaques.")),
             p(markdown("- **COMPRENDRE :** Présentation des modèles et leurs caractéristiques. Quels facteurs pèsent le plus ? ")),
             p(markdown("- **PRÉVENIR :** Estimation du risque individuel. Alertes préventives ciblées.")), style = "color: #2c3e50;"),
           
           p("Explorez les différents onglets pour visualiser les données et mieux comprendre les facteurs 
              qui influencent le risque cardiovasculaire.")
  ),
  
  # 2. Onglet Cartographie
  tabPanel(title = "Cartographie",
           h2(tags$b("Cartographie du taux de mortalité" ,style="color: green;")),
           hr(),
           p("La carte montre l'évolution du nombre de décès par cause de maladies cardiovasculaires à 
           travers le monde de 2000 à 2021.
           L'objectif est d'avoir une vue d'ensemble sur l'étendue du phénomène."),
           p("Explorez la carte par année pour faire le constat selon la situation géographique."),
           sidebarLayout(
             sidebarPanel(
               sliderInput(inputId = "year_map", label ="Faites glisser pour choisir l'année", 
                           min = min(dr$year, na.rm = TRUE), 
                           max = max(dr$year, na.rm = TRUE),
                           value = max(dr$year, na.rm = TRUE),
                           sep = ""),
               hr(),
               div(
                 style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #3498db;",
                 p("Comme vous pouvez le constater, de 2000 à 2021, de nombreux progrès ont été faits en ce qui concerne
                   le taux de mortalité. Mais les 18 millions de décès en 2019 doivent nous alerter. Beaucoup d'effort
                   reste à faire."), 
                 style = "color: #2c3e50;")
             ),
             mainPanel(
               leafletOutput("map", height = "700px")
             )
           )
  ),
  
  # 3. Onglet Explorer
  navbarMenu(title = "Explorer",
             
             # 3.1 Sous onglet Data Base
             tabPanel(title = "Data Base",
                      h2(tags$b("Présentation de la Base de Données" ,style="color: green;")),
                      hr(),
                      p(markdown("Le jeu de données **heart.csv** à été obtenu après une étude clinique portant sur 303 patients. 
                      La variable à expliquer **output** est une variable binaire qui indique si le patient est sujet à une attaque 
                      cardiaque (0=peu de chances, 1=plus de chances).")),
                      hr(),
                      # la table des données
                      DTOutput("table"),
                      hr(),
                      br(),
                      p("Les détails sur les 13 variables explicatives sont donnés dans le tableau ci-dessous :"),
                      hr(),
                      # la table des variables explicatives
                      DTOutput("var")
                      
             ),
             
             # 3.2 Sous onglet Visualisation
             tabPanel(title = "Visualisation des Données",
                      h2(tags$b("Visualisation des Données" ,style="color: green;")),
                      hr(),
                      p("Nous présentons ici des graphes afin de visualiser le comportement des facteurs sur le 
                        risque d'attaque cardiaque."),
                      tabsetPanel(
                        # premier sous onglet
                        tabPanel(title = "Facteurs mesurables",
                                 sidebarLayout(
                                   sidebarPanel(
                                     selectInput(inputId = "var_num", label = "Choisissez un facteur à visualiser",
                                                 choices = c("Âge"="age", "Préssion artérielle au repos" = "trtbps", 
                                                             "Taux de cholestérol" = "chol", "Fréquence cardiaque maximale atteinte" = "thalachh", 
                                                             "Dépression du segment ST pendant l’exercice" = "oldpeak", 
                                                             "Nombre de vaisseaux sanguins colorés par fluoroscopie" = "caa"),
                                                 selected = "age")
                                   ),
                                   mainPanel(
                                     plotOutput("hist_var_num"),
                                     hr(),
                                     h4(tags$b("Commentaires")),
                                     p(markdown("Nous désignerons les patients par ***malade***, s'ils ont plus de chance d'être sujet à une attaque 
                                                cardiaque (correspondant aux patients qui ont 1 comme observation dans la colonne **output** du
                                                tableau de données).")),
                                     p(markdown("De façon générale on observe que :
                                                - La maladie cardiaque touche principalement les patients entre **40 et 65 ans**
                                                avec une concentration plus prononcée dans la tranche d'âge des **45 à 55 ans**.
                                                - Les patients avec maladie cardiaque ont majoritairement une pression 
                                                artérielle au repos comprise entre **100 et 150 mmHg** (millimètre de mercure), avec 
                                                une forte concentration entre **120 et 140 mmHg**.
                                                - Les patients malades ont un taux de cholestérol compris entre **150 et 350
                                                mg/dl** (milligramme par décilitre), avec une forte prédominance entre **200 et 300 mg/dl**.
                                                - La grande majorité des patients malades ont une fréquence cardiaque maximale élevée. 
                                                Ces fréquences sont essentiellement concentrées entre **150 et 180 bpm** (battements par minute).
                                                - La dépression du segment ST de l’ECG pendant l’exercice des patients malades est comprise
                                                majoritairement entre **0 et 2.5 mm** (millimètre).
                                                - Les patients malades ont un nombre de vaisseaux sanguins colorés par fluoroscopie
                                                compris entre **0 et 2.5**."))
                                   )
                                 )
                        ),
                        # deuxième sous onglet
                        tabPanel(title = "Facteurs non mesurables",
                                 sidebarLayout(
                                   sidebarPanel(
                                     selectInput(inputId = "var_non_num", label = "Choisissez un facteur à visualiser",
                                                 choices = c("Sexe" = "sex", "Type de douleur thoracique" = "cp", 
                                                             "Type de glycémie à jeun" = "fbs", "Type de résultat de l’ECG au repos" = "restecg", 
                                                             "Angine induite par exercice" = "exng", "Type de pente du segment ST" = "slp", 
                                                             "Thalassémie" = "thall"),
                                                 selected = "sex")
                                   ),
                                   mainPanel(
                                     plotOutput("hist_var_non_num"),
                                     hr(),
                                     h4(tags$b("Commentaires")),
                                     p(markdown("Nous désignerons les patients par ***malade***, s'ils ont plus de chance d'être sujet à une attaque 
                                                cardiaque (correspondant aux patients qui ont 1 comme observation dans la colonne **output** du
                                                tableau de données).")),
                                     p(markdown("De façon générale, on observe que : 
                                                - Les patients malades de sexe masculin sont plus nombreux que ceux de sexe féminin. Toutefois,
                                                la proportion de femmes malades est plus élevée que la proportion d'hommes malades (on rappelle
                                                que dans la colonne **sex** du tableau de données, 1 désigne un patient de sexe masculin et 0, un 
                                                patient de sexe féminin).
                                                - La proportion de patients malades est plus élevée pour les douleurs thoraciques de type 1, 2 
                                                et 3 désignant respectivement une **angine type**, une **angine atypique** et une 
                                                **douleur non angineuse**.
                                                Les patients malades sont plus concentrés dans la classe de douleur de type 2.
                                                - Pour une glycémie à jeun inférieure ou égale à 120 mg/dl (milligramme par décilitre), 
                                                correspondant au chiffre 0 de la colonne **fbs**, le nombre de patients malades est sensiblement 
                                                supérieur au nombre de patient sains. On n'a pas de différence notable entre les deux catégories 
                                                de patients pour une glycémie à jeun supérieure à 120 mg/dl (chiffre 1 de la colonne **fbs**).
                                                 - Pour le type de résultat de l’ECG au repos, les patients malades sont beaucoup plus présents
                                                dans les classes des résultats de type 0 et 1, désignant respectivement un résultat **normal**
                                                et une **anomalie onde ST-T**. Toutefois, la présence des malades est plus prononcée dans la
                                                classe du résultat de type 1.
                                                - Pour le facteur 'Angine induite par exercice', la majorité des patients malades se compte
                                                parmi ceux qui ne ressentent aucune douleur thoracique déclenchée spécifiquement par l'effort 
                                                physique.
                                                - Pour le type de pente du segment ST de l’ECG pendant l’exercice, les patients malades se 
                                                retrouvent majortitairement dans la catégorie 2 correspondant à la catégorie anormale **pente 
                                                descendante**.
                                                - Concernant la thalassémie, les patients malades sont majoritairement dans la catégorie, 
                                                **défaut fixe**."))
                                   )
                                 )
                        )
                      )
             )
  ),
  
  # Troisème onglet
  tabPanel(title = "Comprendre",
           titlePanel("Analyse des Modèles de Prédiction"),
           
           
           div(
             style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #3498db;",
             
             p(markdown("**Pour prédire votre risque cardiovasculaire, deux modèles sont disponibles** *(après une étude comparative des modèles par notre équipe de data scientists)* :"), 
               style = "color: #2c3e50; font-size: 16px;"),
             
             br(),
             
             div(
               style = "display: flex; justify-content: space-between; margin-bottom: 10px;",
               
               # Modèle Complet
               div(
                 style = "background-color: #e8f4fc; padding: 10px; border-radius: 5px; width: 48%;",
                 p(markdown("<span style='color:#3498db; font-weight:bold;'>🔍 Modèle Complet :</span>"), 
                   style = "margin-bottom: 5px;"),
                 p(markdown("Utilise <span style='color:#2980b9;'>toutes les variables</span> du jeu de données + transformations avancées"), 
                   style = "color: #7f8c8d; font-size: 14px;")
               ),
               
               # Modèle Simplifié
               div(
                 style = "background-color: #eaf7ea; padding: 10px; border-radius: 5px; width: 48%;",
                 p(markdown("<span style='color:#27ae60; font-weight:bold;'>⚡ Modèle Simplifié :</span>"), 
                   style = "margin-bottom: 5px;"),
                 p(markdown("Sélection optimale via <span style='color:#2ecc71;'>critères ANOVA</span> (variables les plus pertinentes)"), 
                   style = "color: #7f8c8d; font-size: 14px;")
               )
             ),
             
             br(),
             
             div(
               style = "background-color: #fff3cd; padding: 10px; border-radius: 5px; text-align: center;",
               p(markdown("**📊 Comparez leurs performances ci-dessous** (exactitude, sensibilité, AUC,...) et choisissez le modèle adapté à votre besoin."),
                 p(markdown("*Vous pouvez changer de modèle à tout moment*"), style = "color: #e67e22; font-size: 13px;")
               )
             )), 
    
    
    tabsetPanel(
             # Modèle 1
             tabPanel("Modèle 1",
                      fluidRow(
                        column(6,
                               # Matrice de confusion avec bordure rouge
                               div(
                                 style = "border: 2px solid #e74c3c; border-radius: 5px; padding: 10px;",
                                 plotOutput("conf_matrix1")
                               ),
                               
                               # Légende des erreurs en rouge
                               div(
                                 style = "margin-top: 15px; background-color: #fdecea; padding: 10px; border-left: 4px solid #e74c3c;",
                                 h4("Analyse des erreurs", style = "color: #c0392b;"),
                                 p(markdown("**<span style='color:#e74c3c;'>Erreurs du modèle :</span>**")),
                                 tags$ul(
                                   tags$li(markdown("<span style='color:#e74c3c;'>2 → Patients non malades classés à tort comme malades (faux positifs)</span>")),
                                   tags$li(markdown("<span style='color:#e74c3c;'>5 → Patients malades non détectés (faux négatifs)</span>"))
                                 ),
                                 p(markdown("_Plus la valeur est faible, meilleur est le modèle_"), style = "color: #7f8c8d; font-style: italic;")
                               )
                        ),
                        column(6, plotOutput("roc_curve1"))
                      ),
                      
                      fluidRow(
                        column(12,
                               div(
                                 style = "background-color: #f8f9fa; border-radius: 8px; padding: 15px; margin-bottom: 15px;",
                                 
                                 h4("📊 Performance du Modèle Complet", style = "color: #3498db;"),  # Couleur bleue pour modèle complet
                                 
                                 # Métriques en ligne compacte - structure identique au modèle 2
                                 div(
                                   style = "display: flex; justify-content: space-between; text-align: center; margin-bottom: 10px;",
                                   div(
                                     style = "width: 23%;",
                                     h5("Exactitude", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #3498db;", "76.2%")
                                   ),
                                   div(
                                     style = "width: 23%;",
                                     h5("AUC", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #3498db;", "84.2%")
                                   ),
                                   div(
                                     style = "width: 23%;",
                                     h5("Sensibilité", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #e67e22;", "84.8%")
                                   ),
                                   div(
                                     style = "width: 23%;",
                                     h5("Spécificité", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #e91e63;", "66.7%")
                                   )
                                 ),
                                 
                                 # Explication concise - même style que modèle 2
                                 div(
                                   style = "background-color: #ebf5fb; padding: 10px; border-radius: 5px; font-size: 14px;",
                                   p("🔍 Sur 100 patients :", style = "margin-bottom: 5px;"),
                                   tags$ul(
                                     style = "margin-top: 0; padding-left: 20px;",
                                     tags$li("24 erreurs de prédiction"),
                                     tags$li("Détecte 85% des malades"),
                                     tags$li("67% des sains correctement identifiés")
                                   )
                                 )
                               )
                        )
                      ),
                      
                      
                      
                      hr(),
                      
                      fluidRow(
                        column(12,
                               p(markdown("**Analyse des Variables Importantes**")),
                               br(),
                               fluidRow(
                                 column(6, plotOutput("var_importance1",height = "400px")),
                                 
                                 column(6,div(style = "background-color: #e3f2fd; color: #0d47a1; padding: 10px 15px; border-radius: 5px 5px 0 0;
                                           border-left: 4px solid #1976d2;
                                           font-size: 14px;
                                           font-weight: 500;",icon("info-circle", style = "margin-right: 8px; color: #1976d2;"),
                                              "Dans l'onglet prévenir, la prédiction utilise uniquement les variables marquées ",
                                              tags$span("(*)ou(**)ou(***) ", style = "color: #d32f2f; font-weight: bold;")
                                 ),
                                 
                                 div( style = "border-radius: 0 0 5px 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
                                      DTOutput("coef_table1", width = "100%",))))
                        )
                      ),
                      
             ),
             
             # Modèle 2  
             tabPanel("Modèle 2",
                      fluidRow(
                        column(6,
                               # Matrice de confusion avec bordure rouge
                               div(
                                 style = "border: 2px solid #e74c3c; border-radius: 5px; padding: 10px;",
                                 plotOutput("conf_matrix2")
                               ),
                               
                               # Légende des erreurs en rouge
                               div(
                                 style = "margin-top: 15px; background-color: #fdecea; padding: 10px; border-left: 4px solid #e74c3c;",
                                 h4("Analyse des erreurs", style = "color: #c0392b;"),
                                 p(markdown("**<span style='color:#e74c3c;'>Erreurs du modèle :</span>**")),
                                 tags$ul(
                                   tags$li(markdown("<span style='color:#e74c3c;'>2 → Patients non malades classés à tort comme malades (faux positifs)</span>")),
                                   tags$li(markdown("<span style='color:#e74c3c;'>5 → Patients malades non détectés (faux négatifs)</span>"))
                                 ),
                                 p(markdown("_Plus la valeur est faible, meilleur est le modèle_"), style = "color: #7f8c8d; font-style: italic;")
                               )
                        ),
                        column(6, plotOutput("roc_curve2"))
                      ),
                      
                      fluidRow(
                        column(12,
                               div(
                                 style = "background-color: #f8f9fa; border-radius: 8px; padding: 15px; margin-bottom: 15px;",
                                 
                                 h4("📊 Performance du Modèle Simplifié", style = "color: #27ae60;"),
                                 
                                 # Métriques en ligne compacte
                                 div(
                                   style = "display: flex; justify-content: space-between; text-align: center; margin-bottom: 10px;",
                                   div(
                                     style = "width: 23%;",
                                     h5("Exactitude", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #27ae60;", "76.2%")
                                   ),
                                   div(
                                     style = "width: 23%;",
                                     h5("AUC", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #3498db;", "81.9%")
                                   ),
                                   div(
                                     style = "width: 23%;",
                                     h5("Sensibilité", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #e67e22;", "82.9%")
                                   ),
                                   div(
                                     style = "width: 23%;",
                                     h5("Spécificité", style = "margin-bottom: 5px;"),
                                     div(style = "font-weight: bold; color: #e91e63;", "67.9%")
                                   )
                                 ),
                                 
                                 # Explication concise
                                 div(
                                   style = "background-color: #f0f7fa; padding: 10px; border-radius: 5px; font-size: 14px;",
                                   p("🔍 Sur 100 patients :", style = "margin-bottom: 5px;"),
                                   tags$ul(
                                     style = "margin-top: 0; padding-left: 20px;",
                                     tags$li("24 erreurs de prédiction"),
                                     tags$li("Détecte 83% des malades"),
                                     tags$li("67% des sains correctement identifiés")
                                   )
                                 )
                               ),
                               
                               hr(),
                               
                               # Section analyse
                               
                               fluidRow(
                                 column(12,
                                        p(markdown("**Analyse des Variables Importantes**")),
                                        br(),
                                        fluidRow(
                                          column(6, plotOutput("var_importance2",height = "400px")),
                                          
                                          column(6,div(style = "background-color: #e3f2fd; color: #0d47a1; padding: 10px 15px; border-radius: 5px 5px 0 0;
                                           border-left: 4px solid #1976d2;
                                           font-size: 14px;
                                           font-weight: 500;",icon("info-circle", style = "margin-right: 8px; color: #1976d2;"),
                                                   "Dans l'onglet prévenir, la prédiction utilise uniquement les variables marquées ",
                                                   tags$span("(*)ou(**)ou(***) ", style = "color: #d32f2f; font-weight: bold;")
                                                 ),
                                                 
                                  div( style = "border-radius: 0 0 5px 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
                                                   DTOutput("coef_table2", width = "100%",))))
                                 )
                               )
                        ))
  )) ),
  
  
  
  # Quatrième onglet
  tabPanel("Prévenir",
           
          
           titlePanel("Estimation du Risque Cardiovasculaire"),
           sidebarLayout(
             sidebarPanel(
               width = 4,
               h4("Sélection du Modèle"),
               radioButtons("selected_model", "Modèle à utiliser :",
                            choices = c("Modèle Complet (toutes variables)" = "full",
                                        "Modèle Simplifié (variables sélectionnées)" = "simplified"),
                            selected = "full"),
               
               h4("Informations Patient"),
               # Champs conditionnels selon le modèle choisi
               uiOutput("dynamic_inputs"),
               
               actionButton("predict_btn", "Estimer le Risque", 
                            icon = icon("heart-pulse"),
                            class = "btn-danger")
             ),
             
             mainPanel(
               width = 8,
               h3("Résultats", style = "color: #d9534f;"),
               
               # Affichage du modèle utilisé
               uiOutput("model_used"),
               
               # Carte de résultat
               div(
                 style = "border: 1px solid #ddd; border-radius: 5px; padding: 15px; margin-bottom: 20px;",
                 h4("Score de Risque", style = "margin-top: 0;"),
                 plotlyOutput("risk_gauge"),
                 htmlOutput("risk_interpretation")
               ),
               
               # Recommandations
               conditionalPanel(
                 condition = "input.predict_btn > 0",
                 
                 uiOutput("recommendations")
               )
               )
             )
           ),
  
  # Cinquième onglet
  # 6. Onglet À Propos
  tabPanel(title = "À Propos",
           h1(tags$b("À propos de cette application" ,style="color: green;")),
           hr(),
           p("Cette application Shiny a été développée dans le cadre d’un projet visant à analyser les facteurs 
              influençant les risques d’attaque cardiaque. Elle repose sur un jeu de données clinique comportant des 
              mesures telles que l’âge, le taux de cholestérol, la fréquence cardiaque, etc."),
           p("L’objectif est double : permettre une exploration visuelle des données, et proposer une modélisation 
              prédictive basée sur des algorithmes de machine learning (régression logistique, arbres de décision…)."),
           p(markdown("**⚠ Attention :** cette application a une visée pédagogique et exploratoire. Elle ne remplace en aucun cas 
              un diagnostic médical ou un avis professionnel de santé.")),
           hr(),
           h4(tags$b("Sources de données :")),
           p(tags$a(href = "https://archive.ics.uci.edu/dataset/45/heart+disease", "UC Irvine")),
           p(tags$a(href = "https://ourworldindata.org/cardiovascular-diseases?utm_source=chatgpt.com#all-charts", "OWID")),
           hr(),
           p("Cette application a été développée par : "),
           br(), br(),
           fluidRow(
             div(column(6, markdown("**KOFFI** Jean-Baptiste"), 
                        img(src= "img/photo1.jpg", width="45%"),
                        p(markdown("**Master 1 en Science des Données**")),
                      p("Faculté de Mathématiques et Informatique, UFHB • 2024–Présent"),
                      p(markdown("**Licence en Mathématiques Appliquées (Classe Étoile)** Même université • 2021–2024 "))


             ), align = "center"),
             div(column(6,markdown("**KOUASSI** Prosper"),
                        img(src= "img/photo2.jpg", width="45%")
             ), align = "center")
             
           )
  )
)