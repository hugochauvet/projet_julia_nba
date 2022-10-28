#####################################################################

##### PROJET (Logiciel_specialise R)
##### Application en Julia sur les joueurs de nba
##### Utilisation du package DASH
##### http://127.0.0.1:8050/

#####################################################################

##### DEFINE
const BLUE = "#17408B"
const RED = "#C9082A"
const WHITE = "#FFFFFF"
const tabs_styles = (
    height = "60px",
    width = "97.5%",
)
const tabs_style = (
    borderBottom = "2px solid #FFFFFF",
    padding = "18px",
    backgroundColor = WHITE,
    color = BLUE,
)
const tabs_selected_style = (
    #borderTop = "3px solid #C9082A",
    #borderBottom = "3px solid #C9082A",
    #borderLeft = "3px solid #C9082A",
    #borderRight = "3px solid #C9082A",
    backgroundColor = "#119DFF",
    color = WHITE,
    padding = "18px",
    fontWeight = "bold",
)


#####################################################################

##### UTILISATION DES PACKAGES #####
using DataFrames, PlotlyJS, CSV, StatsBase, Statistics
using Dash, DashBootstrapComponents

##### IMPORTATION DES DONNEES #####
path = @__DIR__
df_ref = DataFrame(CSV.File(path * "/all_seasons.csv"))
df = copy(df_ref)

##### MODIFICATION DES DONNEES #####
### Renommage des colonnes
# ID
if names(df)[1] != "ID"
    rename!(df, Dict(:Column1 => :ID)) # Renomme la première colonne en "ID"
end 
# Player
if names(df)[2] != "Player"
    rename!(df, Dict(:player_name => :Player)) # Renomme la première colonne en "ID"
end 
# Team
if names(df)[3] != "Team"
    rename!(df, Dict(:team_abbreviation => :Team)) # Renomme la première colonne en "ID"
end 
# Age 
if names(df)[4] != "Age"
    rename!(df, Dict(:age => :Age)) # Renomme la première colonne en "ID"
end 
# Height 
if names(df)[5] != "Height"
    rename!(df, Dict(:player_height => :Height)) # Renomme la première colonne en "ID"
end 
# Weight
if names(df)[6] != "Weight"
    rename!(df, Dict(:player_weight => :Weight)) # Renomme la première colonne en "ID"
end 
# College
if names(df)[7] != "College"
    rename!(df, Dict(:college => :College)) # Renomme la première colonne en "ID"
end 
# College
if names(df)[8] != "Country"
    rename!(df, Dict(:country => :Country)) # Renomme la première colonne en "ID"
end 
# Draft year
if names(df)[9] != "Draft_year"
    rename!(df, Dict(:draft_year => :Draft_year)) # Renomme la première colonne en "ID"
end 
# Draft year
if names(df)[10] != "Draft_round"
    rename!(df, Dict(:draft_round => :Draft_round)) # Renomme la première colonne en "ID"
end 
# Draft number
if names(df)[10] != "Draft_number"
    rename!(df, Dict(:draft_number => :Draft_number)) # Renomme la première colonne en "ID"
end 
# Game played
if names(df)[12] != "Game_Played"
    rename!(df, Dict(:gp => :Game_played)) # Renomme la première colonne en "ID"
end 
# Points average
if names(df)[13] != "Points_avg"
    rename!(df, Dict(:pts => :Points_avg)) # Renomme la première colonne en "ID"
end 
# Rebounds average
if names(df)[14] != "Rebound_avg"
    rename!(df, Dict(:reb => :Rebound_avg)) # Renomme la première colonne en "ID"
end 
# Assist average
if names(df)[15] != "Assist_avg"
    rename!(df, Dict(:ast => :Assist_avg)) # Renomme la première colonne en "ID"
end 
# Net rating
if names(df)[15] != "Net_rating"
    rename!(df, Dict(:net_rating => :Net_rating)) # Renomme la première colonne en "ID"
end 
# Season
if names(df)[end] != "Season"
    rename!(df, Dict(:season => :Season)) # Renomme la première colonne en "ID"
end 

##### Dataframe pour les graphes (données plus pertinantes)
df_graphe = df[df[!, :Game_played] .>= 50, :]

##### CREATION D'UNE NOUVELLE COLONNE 
#df[!, :Wiki] = "[" .* df[!, :Player] .* "](https://fr.wikipedia.org/wiki/" .* df[!, :Player] .* ")"
df[!, :Wiki] = "**[" .* df[!, :Player] .* "](https://fr.wikipedia.org/wiki/" .* replace.(df[!, :Player], " " => "_") .* ")**"

##### VISUALISATION DES DONNEES #####
first(df, 5) # Visualisation des 5 premières lignes

##### RESUME DES DONNEES #####
#print(names(df)) # Nom des variables du DF 
#propertynames(df) # Quels noms utiliser pour appeler les colonnes
#size(df) # Dimension des données 
#describe(df[!, :pts]) # Statistique describtive de la variable point moyenne par match
#show(df) # Permet de visualiser le DF 

##### CREATION DE VARIABLE SUR LES DONNES POUR LA SUITE #####
global unique_player_name = unique(df[!, "Player"])
global unique_season = pushfirst!(unique(df[!, "Season"]), "...")
global unique_team = pushfirst!(unique(df[!, "Team"]), "...")
global unique_country = pushfirst!(unique(df[!, "Country"]), "...")
global df_to_show = df[:, Not([:ID, :Draft_year, :Draft_round, :Draft_number, :Height, :Weight, :oreb_pct, :dreb_pct,
:usg_pct, :ts_pct, :ast_pct, :Net_rating])]


########### FONCTIONS ###############################################

########### Première partie #########################################

function page_one()

    return html_div() do

        html_h2( # Titre
            "DATA PRESENTATION",
            style = Dict("color" => RED, "textAlign" => "center"),
        ),

        ##### Recherche d'un joueurs
        
        ### Recherche année
        html_div( 
            children = [
                html_label("SEASON", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_year",
                    options = [
                        (label = i, value = i) for i in unique_season
                    ],
                    value = "...",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "32%"),
        ),
        ### Espace
        html_span(" "),
        ### Recherche équipe
        html_div( 
            children = [
                html_label("TEAM", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_team",
                    options = [
                        (label = i, value = i) for i in unique_team
                    ],
                    value = "...",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "32%"),
        ),
        ### Espace
        html_span(" "),
        ### Recherche nationalité
        html_div( 
            children = [
                html_label("NATIONALITY", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_country",
                    options = [
                        (label = i, value = i) for i in unique_country
                    ],
                    value = "...",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "33%"),
            #style = (width = "25%", display = "inline-block"),
        ),
        ### Retour à la ligne avec Espace
        html_pre(""),
        ### Affichage du dataframe correspondant à la recherche en cours
        html_div(
            children = [
                dash_datatable(
                    id = "dataframe",
                    columns = [Dict("name" =>i, "id" => i, "presentation" => (i == "Wiki" ? "markdown" : "input")) for i in names(df_to_show)],
                    
                    data = Dict.(pairs.(eachrow(df_to_show))),
                    sort_action = "native",
                    page_size = 20,
                ),
            ],
            style = Dict("width" => "97.5%", "lineHeight" => "20px", "textAlign" => "center"),
        )
    end
end


########### Deuxième partie #########################################

function page_two()

    return html_div() do

        html_h2( # Titre
            "HISTOGRAM",
            style = Dict("color" => RED, "textAlign" => "center"),
        ),

        ##### Choix des variables pour le filtre

        ### Choix d'une variable quanti
        html_div( 
            children = [
                html_label("VARIABLE", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_variable",
                    options = [
                        (label = i, value = i) for i in ["Age", "Points_avg", "Rebound_avg", "Assist_avg"]
                    ],
                    value = "Age",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "24%"),
        ),
        ### Espace
        html_span(" "),
        ### Choix de l'année (facultatif)
        html_div( 
            children = [
                html_label("SEASON", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_year2",
                    options = [
                        (label = i, value = i) for i in unique_season
                    ],
                    value = "...",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "24%"),
        ),
        ### Espace
        html_span(" "),
        ### Choix du parametre de l'hist 
        html_div( 
            children = [
                html_label("EFFECTIVE / PROBABILITY", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_histnorm",
                    options = [
                        (label = i, value = i) for i in ["Effective", "Probability"]
                    ],
                    value = "Effective",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "24%"),
        ),
        ### Espace
        html_span(" "),
        ### Choix du nombre de barre de l'Histogramme
        html_div( 
            children = [
                html_label("NUMBER OF BIN", style = Dict("color" => WHITE)),
                dcc_slider(
                    id = "slider_hist",
                    min = 10,
                    max = 30,
                    step = 5,
                    value = 20,
                    marks = Dict(
                        10 => Dict("label" => "10", "style" => Dict("color" => WHITE)),
                        15 => Dict("label" => "15", "style" => Dict("color" => WHITE)),
                        20 => Dict("label" => "20", "style" => Dict("color" => WHITE)),
                        25 => Dict("label" => "25", "style" => Dict("color" => WHITE)),
                        30 => Dict("label" => "30", "style" => Dict("color" => WHITE)),
                    )
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "25%"),
        ),
        ### Retour à la ligne avec Espace
        html_pre(""),
        ##### Histogramme des variables sélectionnées
        html_div(
            children = [
                dcc_graph(
                    id = "histogram",
                ),
            ],
            style = Dict("width" => "97.5%", "lineHeight" => "20px", "textAlign" => "center"),
        )
    end
end


########### Troisième partie #########################################

function page_three()

    return html_div() do

        html_h2( # Titre
            "SCATTER PLOT",
            style = Dict("color" => RED, "textAlign" => "center"),
        ),

        ##### Choix des 2 variables pour le scatter plot

        ### 1ere variable 
        html_div( 
            children = [
                html_label("VARIABLE 1", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_variable1_scatter",
                    options = [
                        (label = i, value = i) for i in ["Age", "Points_avg", "Rebound_avg", "Assist_avg", "Height", "Weight"]
                    ],
                    value = "Age",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "19%"),
        ),
        ### Espace
        html_span(" "),
        ### 2eme variable 
        html_div( 
            children = [
                html_label("VARIABLE 2", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_variable2_scatter",
                    options = [
                        (label = i, value = i) for i in ["Age", "Points_avg", "Rebound_avg", "Assist_avg", "Height", "Weight"]
                    ],
                    value = "Points_avg",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "19%"),
        ),
        ### Espace
        html_span(" "),
        ### Recherche année
        html_div( 
            children = [
                html_label("SEASON", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_year3",
                    options = [
                        (label = i, value = i) for i in unique_season
                    ],
                    value = "...",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "19%"),
        ),
        ### Espace
        html_span(" "),
        ### Recherche équipe
        html_div( 
            children = [
                html_label("TEAM", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_team2",
                    options = [
                        (label = i, value = i) for i in sort(unique_team)
                    ],
                    value = "...",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "19%"),
        ),
        ### Espace
        html_span(" "),
        ### Normaliser ou non les données
        html_div( 
            children = [
                html_label("NORMALIZE WITH USAGE PER POSSESSION", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_norm",
                    options = [
                        (label = i, value = i) for i in ["NO", "YES"]
                    ],
                    value = "NO",
                ),
            ],
            style = Dict("display" => "inline-block", "width" => "19.5%"),
        ),
        ### Retour à la ligne avec Espace
        html_pre(""),
        ##### Nuage de point des variables sélectionnées
        html_div(
            children = [
                dcc_graph(
                    id = "scatter_plot",
                ),
            ],
            style = Dict("width" => "97.5%", "lineHeight" => "20px", "textAlign" => "center"),
        )
    end
end


########### Troisième partie #########################################

function page_four()

    return html_div() do

        html_h2( # Titre
            "RESEARCH A PLAYER",
            style = Dict("color" => RED, "textAlign" => "center"),
        ),

        ### Choix du joueur
        html_div( 
            children = [
                html_label("PLAYER", style = Dict("color" => WHITE)),
                dcc_dropdown(
                    id = "dropdown_player",
                    options = [
                        (label = i, value = i) for i in sort(unique_player_name)
                    ],
                    value = "A.C. Green",
                ),
            ],
            #style = Dict("display" => "inline-block", "width" => "19%"),
        ),
        ### Retour à la ligne avec Espace
        html_pre(""),
        ### Affichage info sur joueur
        html_div(id = "player_info_1", style = Dict("color" => WHITE, "fontSize" => 22, "fontStyle" => "italic")),
        ### Retour à la ligne avec Espace
        html_pre(""),
        ### Affichage info sur joueur
        html_div(id = "player_info_2", style = Dict("color" => WHITE, "fontSize" => 22, "fontStyle" => "italic")),
        ### Retour à la ligne avec Espace
        html_pre(""),
        ### Affichage info sur joueur
        html_div(id = "player_info_3",  style = Dict("color" => WHITE, "fontSize" => 22, "fontStyle" => "italic"))
    end
end

########### Base de l'app ###########################################

app = dash() # Création de l'UI sous dash

app.layout = html_div( # Style de la page
    style = Dict("backgroundColor" => BLUE, "padding-left" => "1cm")) do # Couleur de la page
    html_h1( #Titre de la page (équivalent à la balise <h1> HTML)
        "NBA Project",
        style = Dict("color" => WHITE, "textAlign" => "center"),
    ),
    dcc_tabs(
        id = "pages",
        value = "page_one",
        style = tabs_styles,
        children = [
            dcc_tab(
                label = "DATA PRESENTATION",
                value = "page_one",
                style = tabs_style,
                selected_style = tabs_selected_style,
                #children = [ page_one() ]
            ),
            dcc_tab(
                label = "HISTOGRAM",
                value = "page_two",
                style = tabs_style,
                selected_style = tabs_selected_style,
                #children = [ page_two() ]
            ),
            dcc_tab(
                label = "SCATTER PLOT",
                value = "page_three",
                style = tabs_style,
                selected_style = tabs_selected_style,
                #children = [ page_two() ]
            ),
            dcc_tab(
                label = "RESEARCH A PLAYER",
                value = "page_four",
                style = tabs_style,
                selected_style = tabs_selected_style,
                #children = [ page_two() ]
            ),
        ]
    ),
    html_div(id = "pages_classes")
end

########### CALLBACK ###################################################################

##### Tabs

callback!(
    app,
    Output("pages_classes", "children"),
    Input("pages", "value"),
) do tab
    if tab == "page_one"
        return page_one()
    elseif tab == "page_two"
        return page_two()
    elseif tab == "page_three"
        return page_three()
    elseif tab == "page_four"
        return page_four()
    end
end

##### Filtre sur les dropdown #####

### Garder les équipes
callback!(
    app,
    Output("dropdown_team", "options"),
    Input("dropdown_year", "value"),
    Input("dropdown_country", "value"),
) do selected_year, selected_country
    if selected_year != "..." || selected_country != "..."
        df_keep_year = df
        ### Filtre saison
        if selected_year != "..."
            df_keep_year = df_keep_year[df_keep_year[!,:Season] .== selected_year, :] # On garde dans le DF que les données de l'année sélectionnée
        end
        ### Filtre nationalité
        if selected_country != "..."
            df_keep_year = df_keep_year[df_keep_year[!,:Country] .== selected_country, :]
        end
        ### On garde que les équipe
        df_keep_year = unique(df_keep_year[!, "Team"])
        df_keep_year = sort(df_keep_year)
        return [(label = i, value = i) for i in pushfirst!(df_keep_year, "...")]
    else
        return [(label = i, value = i) for i in sort(unique_team)]
    end
end

### Garder les saisons
callback!(
    app,
    Output("dropdown_year", "options"),
    Input("dropdown_team", "value"),
    Input("dropdown_country", "value"),
) do selected_team, selected_country2
    if selected_team != "..." || selected_country2 != "..."
        df_keep_year = df
        ### Filtre équipe
        if selected_team != "..."
            df_keep_year = df_keep_year[df_keep_year[!,:Team] .== selected_team, :] # On garde dans le DF que les données de l'année sélectionnée
        end
        ### Filtre nationalité  
        if selected_country2 != "..."
            df_keep_year = df_keep_year[df_keep_year[!,:Country] .== selected_country2, :] # On garde dans le DF que les données de l'année sélectionnée
        end  
        ### On garde que les saisons      
        df_keep_year = unique(df_keep_year[!, "Season"])
        df_keep_year = sort(df_keep_year)
        return [(label = i, value = i) for i in pushfirst!(df_keep_year, "...")]
    else 
        return [(label = i, value = i) for i in sort(unique_season)]
    end
end

### Garder les nationalités
callback!(
    app,
    Output("dropdown_country", "options"),
    Input("dropdown_team", "value"),
    Input("dropdown_year", "value"),
) do selected_team3, selected_year3
    if selected_team3 != "..." || selected_year3 != "..."
        df_keep_country = df
        ### Filtre équipe
        if selected_team3 != "..."
            df_keep_country = df_keep_country[df_keep_country[!,:Team] .== selected_team3, :] 
        end
        ### Filtre saison
        if selected_year3 != "..." 
            df_keep_country = df_keep_country[df_keep_country[!,:Season] .== selected_year3, :]
        end
        ### On garde que les nationalités
        df_keep_country = unique(df_keep_country[!, "Country"])
        df_keep_country = sort(df_keep_country)
        return [(label = i, value = i) for i in pushfirst!(df_keep_country, "...")]
    else 
        return [(label = i, value = i) for i in sort(unique_country)]
    end
end

##### Filtrer le dataframe affiché #####
callback!(
    app,
    Output("dataframe", "data"),
    Input("dropdown_year", "value"),
    Input("dropdown_team", "value"),
    Input("dropdown_country", "value"),
) do selected_year2, selected_team2, selected_country3
    if selected_country3 != "..." || selected_team2 != "..." || selected_year2 != "..." 
        df_show_filter = df_to_show
        ### Filtre saison
        if selected_year2 != "..."
            df_show_filter = df_show_filter[df_show_filter[!,:Season] .== selected_year2, :] 
        end
        ### Filtre équipe
        if selected_team2 != "..."
            df_show_filter = df_show_filter[df_show_filter[!,:Team] .== selected_team2, :]    
        end
        ### Filtre nationalité
        if selected_country3 != "..."
            df_show_filter = df_show_filter[df_show_filter[!,:Country] .== selected_country3, :]    
        end
        ### Affichage du dataframe filté
        return Dict.(pairs.(eachrow(df_show_filter)))
    else
        ### Affichage du dataframe sans filtre
        return Dict.(pairs.(eachrow(df_to_show)))
    end
end

##### Histogramme
callback!(
    app,
    Output("histogram", "figure"),
    Input("dropdown_year2", "value"),
    Input("dropdown_variable", "value"),
    Input("dropdown_histnorm", "value"),
    Input("slider_hist", "value"),
) do selected_year4, selected_variable, histnorm, slider_nb
    df_hist = df_graphe
    if histnorm == "Effective"
        histnorm = "None"
    elseif histnorm == "Probability" 
        histnorm = "probability"
    end
    if selected_year4 != "..."
        df_hist = df_hist[df_hist[!, :Season] .== selected_year4, :]
    end
    if selected_variable == "Age"
        return Plot(
            df_hist, x = :Age, kind = "histogram", histnorm = histnorm, nbinsx = slider_nb) 
    end   
    if selected_variable == "Points_avg"
        return Plot(
            df_hist, x = :Points_avg, kind = "histogram", histnorm = histnorm, nbinsx = slider_nb) 
    end 
    if selected_variable == "Rebound_avg"
        return Plot(
            df_hist, x = :Rebound_avg, kind = "histogram", histnorm = histnorm, nbinsx = slider_nb) 
    end 
    if selected_variable == "Assist_avg"
        return Plot(
            df_hist, x = :Assist_avg, kind = "histogram", histnorm = histnorm, nbinsx = slider_nb) 
    end 
end

### Garder les saisons nuage de points
callback!(
    app,
    Output("dropdown_year3", "options"),
    Input("dropdown_team2", "value"),
) do selected_team
    if selected_team != "..." 
        df_keep_year = df
        ### Filtre équipe
        if selected_team != "..."
            df_keep_year = df_keep_year[df_keep_year[!,:Team] .== selected_team, :] # On garde dans le DF que les données de l'année sélectionnée
        end 
        ### On garde que les saisons      
        df_keep_year = unique(df_keep_year[!, "Season"])
        df_keep_year = sort(df_keep_year)
        return [(label = i, value = i) for i in pushfirst!(df_keep_year, "...")]
    else 
        return [(label = i, value = i) for i in sort(unique_season)]
    end
end

### Garder les équipes nuage de points
callback!(
    app,
    Output("dropdown_team2", "options"),
    Input("dropdown_year3", "value"),
) do selected_year
    if selected_year != "..." 
        df_keep_year = df
        ### Filtre saison
        if selected_year != "..."
            df_keep_year = df_keep_year[df_keep_year[!,:Season] .== selected_year, :] # On garde dans le DF que les données de l'année sélectionnée
        end
        ### On garde que les équipe
        df_keep_year = unique(df_keep_year[!, "Team"])
        df_keep_year = sort(df_keep_year)
        return [(label = i, value = i) for i in pushfirst!(df_keep_year, "...")]
    else
        return [(label = i, value = i) for i in sort(unique_team)]
    end
end

###### Nuage de point
callback!(
    app,
    Output("scatter_plot", "figure"),
    Input("dropdown_variable1_scatter", "value"),
    Input("dropdown_variable2_scatter", "value"),
    Input("dropdown_year3", "value"),
    Input("dropdown_team2", "value"),
    Input("dropdown_norm", "value"),
) do var1, var2, selected_year, selected_team, norm
    df_scatter = df_graphe
    ### Filtre équipe
    if selected_team != "..."
        df_scatter = df_scatter[df_scatter[!,:Team] .== selected_team, :] 
    end
    ### Filtre saison
    if selected_year != "..." 
        df_scatter = df_scatter[df_scatter[!,:Season] .== selected_year, :]
    end
    ### Données pour les variables
    df_var1 = df_scatter[!, var1]
    df_var2 = df_scatter[!, var2]
    if norm == "YES"
        if var1 == "Points_avg" || var1 == "Rebound_avg" || var1 == "Assist_avg"
            df_var1 = df_scatter[!, var1] .* ((2 .* maximum(df_scatter[!, :usg_pct])) .- df_scatter[!, :usg_pct])
        elseif var2 == "Points_avg" || var2 == "Rebound_avg" || var2 == "Assist_avg"
            df_var2 = df_scatter[!, var2] .* ((2 .* maximum(df_scatter[!, :usg_pct])) .- df_scatter[!, :usg_pct])
        end
    end
    cor_scatter = Statistics.cor(df_var1, df_var2)
    title_link = "The correlation between " * var1 * " and " * var2 * " is " * string(round(cor_scatter, digits=3))

    return Plot(
        df_var1,
        df_var2,
        Layout(
            xaxis_title = var1,
            yaxis_title = var2,
            hovermode = "closest",
            title = attr(
                text = title_link,
                x = 0.5,
                xanchor = "center",
                size = 16
            ),
        ),
        kind = "scatter",
        text = var1 * " knowing " * var2,
        mode = "markers",
    )
end

##### Information about player 1
callback!(
    app,
    Output("player_info_1", "children"),
    Input("dropdown_player", "value"),
) do selected_player
    df_player = df
    df_player = df_player[df_player[!, :Player] .== selected_player, :]
    nb_seasons = size(df_player, 1)
    season_played = unique(df_player[!, "Season"])
    if nb_seasons > 1
        return (selected_player * " have played " * string(nb_seasons) * " seasons in NBA, from " * string(season_played[1]) * " to " * string(season_played[end]))
    else 
        return (selected_player * " have played 1 season in NBA. It was season : " * string(season_played[1]) * ".")
    end
end

##### Information about player 2
callback!(
    app,
    Output("player_info_2", "children"),
    Input("dropdown_player", "value"),
) do selected_player
    df_player2 = df
    df_player2 = df_player2[df_player2[!,:Player] .== selected_player, :]
    height = unique(df_player2[!, "Height"])
    weight = unique(df_player2[!, "Weight"])
    return (selected_player * " is " * string(round(height[1], digits = 2)) * "cm tall and weighs " * string(round(weight[1], digits = 2)) * "kg.")
end

##### Information about player 3
callback!(
    app,
    Output("player_info_3", "children"),
    Input("dropdown_player", "value"),
) do selected_player
    df_player3 = df
    df_player3 = df_player3[df_player3[!,:Player] .== selected_player, :]
    pts = round(mean(df_player3[!, "Points_avg"]), digits = 2)
    reb = round(mean(df_player3[!, "Rebound_avg"]), digits = 2)
    ast = round(mean(df_player3[!, "Assist_avg"]), digits = 2)
    return ("During his career " * selected_player * " scored on average " * string(pts) * " points, " * string(reb) * " rebounds and " * string(ast) * " assists.")
end


# Run le serveur
run_server(app, "0.0.0.0", debug=true)