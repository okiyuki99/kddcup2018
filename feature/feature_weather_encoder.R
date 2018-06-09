exe_weather_label_encode <- function(df){
  if("obs1_weather" %in% names(df)){
    df$obs1_weather <- match(df$obs1_weather, unique(df$obs1_weather))
  }
  if("grid1_weather" %in% names(df)){
    df$grid1_weather <- match(df$grid1_weather, unique(df$grid1_weather))
  }
  return(df)
}