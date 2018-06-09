trancateTime <- function(df, date){
  #df$year <- lubridate::year(df[[date]])
  df$month <- lubridate::month(df[[date]])
  df$day <- lubridate::day(df[[date]])
  df$hour <- lubridate::hour(df[[date]])
  df$wday <- lubridate::wday(df[[date]], label = F)
  
  df$week_num_of_year <- lubridate::week(df[[date]])
  df$week_num_of_month <- ceiling(df$day / 7)
  df$day_num_of_year <- lubridate::yday(df[[date]])
  return(df)
}
