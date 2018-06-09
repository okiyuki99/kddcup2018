# この辺工夫したいな
exe_holtwinters <- function(df, freq){
  na_approx <- function(x){na.approx(zoo(x))}
  HW <- function(x){HoltWinters(ts(x, frequency = freq), alpha = NULL, beta = NULL, gamma = NULL, seasonal = c("additive"))}
  df.clean <- df
  for(v in c("PM2.5","PM10","NO2","CO","O3","SO2")){
    if(v %in% names(df)){
      tryCatch({
        ret <- HW(na_approx(df[,v]))
        df.hw <- data.frame(hw_xhat = ret$fitted[,1], 
                            hw_level = ret$fitted[,2], 
                            hw_trend = ret$fitted[,3], 
                            hw_season = ret$fitted[,4])
        names(df.hw) <- paste(v,names(df.hw),sep="_")
        tmp <- data.frame(V1 = rep(NA, nrow(df.clean) - nrow(df.hw)), 
                          V2 = rep(NA, nrow(df.clean) - nrow(df.hw)), 
                          V3 = rep(NA, nrow(df.clean) - nrow(df.hw)), 
                          V4 = rep(NA, nrow(df.clean) - nrow(df.hw)))
        names(tmp) <- names(df.hw)
        df.hw <- bind_rows(tmp, df.hw)
        df.clean <- bind_cols(df.clean, df.hw)
      },
      error = function(e) {
        message("ERROR!")
        message(e)
      })
    }
  }
  return(df.clean)
}
