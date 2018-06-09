exe_stl <- function(df, freq){
  STL <- function(x, freq){stl(ts(x, frequency = freq), s.window = "periodic")}
  for(v in c("PM2.5","PM10","NO2","CO","O3","SO2")){
    if(v %in% names(df)){
      stl.decomposition <- STL(df[,v], freq)
      df.stl <- data.frame(stl_season = as.numeric(stl.decomposition$time.series[, "seasonal"]),
                           stl_trend = as.numeric(stl.decomposition$time.series[, "trend"]),
                           stl_remainder = as.numeric(stl.decomposition$time.series[, "remainder"]), stringsAsFactors = F)
      names(df.stl) <- paste(v,names(df.stl),sep="_")
      df.clean <- bind_cols(df.clean, df.stl)
    }
  }
  return(df.clean)
}
