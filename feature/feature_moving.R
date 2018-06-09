exe_moving <- function(df){
  # 移動平均
  SMA_na <- function(x, tau){
    length <- length(x)
    is.na <- ifelse(is.na(x),0,1)
    x.comp <- ifelse(is.na(x),0,x)
    x.1 <- x.comp
    x.2 <- is.na
    for(i in 1:(tau-1)){ # before
      x.1 <- x.1 + c(rep(0,i), x.comp[1:(length - i)])
      x.2 <- x.2 + c(rep(0,i), is.na[1:(length - i)])
    }
    return(x.1/x.2)
  }
  SMA_na_3 <- function(x){SMA_na(x, 3)}
  SMA_na_24 <- function(x){SMA_na(x, 24)}
  SMA_na_48 <- function(x){SMA_na(x, 48)}
  
  # 移動Median
  SMM_na <- function(x, tau){RcppRoll::roll_median(x, n = tau, align="right", fill=NA)}
  SMM_na_3 <- function(x){SMM_na(x, 3)}
  SMM_na_24 <- function(x){SMM_na(x, 24)}
  SMM_na_48 <- function(x){SMM_na(x, 48)}
  
  # 移動Variance
  SMV_na <- function(x, tau){RcppRoll::roll_var(x, n = tau, align="right", fill=NA)}
  SMV_na_3 <- function(x){SMV_na(x, 3)}
  SMV_na_24 <- function(x){SMV_na(x, 24)}
  SMV_na_48 <- function(x){SMV_na(x, 48)}
  
  # 移動Min
  SMin_na <- function(x, tau){RcppRoll::roll_min(x, n = tau, align="right", fill=NA)}
  SMin_na_3 <- function(x){SMin_na(x, 3)}
  SMin_na_24 <- function(x){SMin_na(x, 24)}
  SMin_na_48 <- function(x){SMin_na(x, 48)}
  
  # 移動Max
  SMax_na <- function(x, tau){RcppRoll::roll_max(x, n = tau, align="right", fill=NA)}
  SMax_na_3 <- function(x){SMax_na(x, 3)}
  SMax_na_24 <- function(x){SMax_na(x, 24)}
  SMax_na_48 <- function(x){SMax_na(x, 48)}
  
  # 移動90% うまくいかない
  #qu90 <- function(x){quantile(x, probs = 0.9)}
  #SMQu90_na <- function(x, tau){RcppRoll::rollit(fun = qu90, x, n = tau, align="right", fill=NA)}
  
  # 移動Skewness 歪度
  # 移動kurtosis 尖度
  
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMA_na_3) -> tmp.1
  names(tmp.1) <- paste("SMA_3", names(tmp.1), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMA_na_24) -> tmp.2
  names(tmp.2) <- paste("SMA_24", names(tmp.2), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMA_na_48) -> tmp.3
  names(tmp.3) <- paste("SMA_48", names(tmp.3), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMM_na_3) -> tmp.4
  names(tmp.4) <- paste("SMM_3", names(tmp.4), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMM_na_24) -> tmp.5
  names(tmp.5) <- paste("SMM_24", names(tmp.5), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMM_na_48) -> tmp.6
  names(tmp.6) <- paste("SMM_48", names(tmp.6), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMV_na_3) -> tmp.7
  names(tmp.7) <- paste("SMV_3", names(tmp.7), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMV_na_24) -> tmp.8
  names(tmp.8) <- paste("SMV_24", names(tmp.8), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMV_na_48) -> tmp.9
  names(tmp.9) <- paste("SMV_48", names(tmp.9), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMin_na_3) -> tmp.10
  names(tmp.10) <- paste("SMMin_3", names(tmp.10), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMin_na_24) -> tmp.11
  names(tmp.11) <- paste("SMMin_24", names(tmp.11), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMin_na_48) -> tmp.12
  names(tmp.12) <- paste("SMMin_48", names(tmp.12), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMax_na_3) -> tmp.13
  names(tmp.13) <- paste("SMMax_3", names(tmp.13), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMax_na_24) -> tmp.14
  names(tmp.14) <- paste("SMMax_24", names(tmp.14), sep = "_")
  df %>%
    select(-date) %>%
    mutate_at(vars(matches("PM2.5|PM10|NO2|CO|O3|SO2")), SMax_na_48) -> tmp.15
  names(tmp.15) <- paste("SMMax_48", names(tmp.15), sep = "_")
  
  df <- bind_cols(df, tmp.1)
  df <- bind_cols(df, tmp.2)
  df <- bind_cols(df, tmp.3)
  df <- bind_cols(df, tmp.4)
  df <- bind_cols(df, tmp.5)
  df <- bind_cols(df, tmp.6)
  df <- bind_cols(df, tmp.7)
  df <- bind_cols(df, tmp.8)
  df <- bind_cols(df, tmp.9)
  df <- bind_cols(df, tmp.10)
  df <- bind_cols(df, tmp.11)
  df <- bind_cols(df, tmp.12)
  df <- bind_cols(df, tmp.13)
  df <- bind_cols(df, tmp.14)
  df <- bind_cols(df, tmp.15)
  return(df)
}

