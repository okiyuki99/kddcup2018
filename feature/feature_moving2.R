exe_moving2 <- function(df){
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
  SMA_na_2 <- function(x){SMA_na(x, 2)}
  SMA_na_3 <- function(x){SMA_na(x, 3)}
  SMA_na_6 <- function(x){SMA_na(x, 6)}
  SMA_na_12 <- function(x){SMA_na(x, 12)}
  SMA_na_18 <- function(x){SMA_na(x, 18)}
  SMA_na_24 <- function(x){SMA_na(x, 24)}
  SMA_na_48 <- function(x){SMA_na(x, 48)}
  
  # 移動Median
  SMM_na <- function(x, tau){RcppRoll::roll_median(x, n = tau, align="right", fill=NA)}
  SMM_na_2 <- function(x){SMM_na(x, 2)}
  SMM_na_3 <- function(x){SMM_na(x, 3)}
  SMM_na_6 <- function(x){SMM_na(x, 6)}
  SMM_na_12 <- function(x){SMM_na(x, 12)}
  SMM_na_18 <- function(x){SMM_na(x, 18)}
  SMM_na_24 <- function(x){SMM_na(x, 24)}
  SMM_na_48 <- function(x){SMM_na(x, 48)}
  
  # 移動Variance
  SMV_na <- function(x, tau){RcppRoll::roll_var(x, n = tau, align="right", fill=NA)}
  SMV_na_2 <- function(x){SMV_na(x, 2)}
  SMV_na_3 <- function(x){SMV_na(x, 3)}
  SMV_na_6 <- function(x){SMV_na(x, 6)}
  SMV_na_12 <- function(x){SMV_na(x, 12)}
  SMV_na_18 <- function(x){SMV_na(x, 18)}
  SMV_na_24 <- function(x){SMV_na(x, 24)}
  SMV_na_48 <- function(x){SMV_na(x, 48)}
  
  # 移動Min
  SMin_na <- function(x, tau){RcppRoll::roll_min(x, n = tau, align="right", fill=NA)}
  SMin_na_2 <- function(x){SMin_na(x, 2)}
  SMin_na_3 <- function(x){SMin_na(x, 3)}
  SMin_na_6 <- function(x){SMin_na(x, 6)}
  SMin_na_12 <- function(x){SMin_na(x, 12)}
  SMin_na_18 <- function(x){SMin_na(x, 18)}
  SMin_na_24 <- function(x){SMin_na(x, 24)}
  SMin_na_48 <- function(x){SMin_na(x, 48)}
  
  # 移動Max
  SMax_na <- function(x, tau){RcppRoll::roll_max(x, n = tau, align="right", fill=NA)}
  SMax_na_2 <- function(x){SMax_na(x, 2)}
  SMax_na_3 <- function(x){SMax_na(x, 3)}
  SMax_na_6 <- function(x){SMax_na(x, 6)}
  SMax_na_12 <- function(x){SMax_na(x, 12)}
  SMax_na_18 <- function(x){SMax_na(x, 18)}
  SMax_na_24 <- function(x){SMax_na(x, 24)}
  SMax_na_48 <- function(x){SMax_na(x, 48)}
  
  # 移動90% うまくいかない
  #qu90 <- function(x){quantile(x, probs = 0.9)}
  #SMQu90_na <- function(x, tau){RcppRoll::rollit(fun = qu90, x, n = tau, align="right", fill=NA)}
  
  # 移動Skewness 歪度
  # 移動kurtosis 尖度

  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMA_na_2) -> tmp
  names(tmp) <- paste("SMA_2", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMA_na_3) -> tmp
  names(tmp) <- paste("SMA_3", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMA_na_6) -> tmp
  names(tmp) <- paste("SMA_6", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMA_na_12) -> tmp
  names(tmp) <- paste("SMA_12", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMA_na_18) -> tmp
  names(tmp) <- paste("SMA_18", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMA_na_24) -> tmp
  names(tmp) <- paste("SMA_24", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMA_na_48) -> tmp
  names(tmp) <- paste("SMA_48", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)

  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMM_na_2) -> tmp
  names(tmp) <- paste("SMM_2", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
    
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMM_na_3) -> tmp
  names(tmp) <- paste("SMM_3", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMM_na_6) -> tmp
  names(tmp) <- paste("SMM_6", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMM_na_12) -> tmp
  names(tmp) <- paste("SMM_12", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMM_na_18) -> tmp
  names(tmp) <- paste("SMM_18", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)  
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMM_na_24) -> tmp
  names(tmp) <- paste("SMM_24", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMM_na_48) -> tmp
  names(tmp) <- paste("SMM_48", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMV_na_2) -> tmp
  names(tmp) <- paste("SMV_2", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMV_na_3) -> tmp
  names(tmp) <- paste("SMV_3", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMV_na_6) -> tmp
  names(tmp) <- paste("SMV_6", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMV_na_12) -> tmp
  names(tmp) <- paste("SMV_12", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMV_na_18) -> tmp
  names(tmp) <- paste("SMV_18", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMV_na_24) -> tmp
  names(tmp) <- paste("SMV_24", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMV_na_48) -> tmp
  names(tmp) <- paste("SMV_48", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMin_na_2) -> tmp
  names(tmp) <- paste("SMMin_2", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMin_na_3) -> tmp
  names(tmp) <- paste("SMMin_3", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMin_na_6) -> tmp
  names(tmp) <- paste("SMMin_6", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMin_na_12) -> tmp
  names(tmp) <- paste("SMMin_12", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMin_na_18) -> tmp
  names(tmp) <- paste("SMMin_18", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMin_na_24) -> tmp
  names(tmp) <- paste("SMMin_24", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMin_na_48) -> tmp
  names(tmp) <- paste("SMMin_48", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)

  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMax_na_2) -> tmp
  names(tmp) <- paste("SMMax_2", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMax_na_3) -> tmp
  names(tmp) <- paste("SMMax_3", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMax_na_6) -> tmp
  names(tmp) <- paste("SMMax_6", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMax_na_12) -> tmp
  names(tmp) <- paste("SMMax_12", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMax_na_18) -> tmp
  names(tmp) <- paste("SMMax_18", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMax_na_24) -> tmp
  names(tmp) <- paste("SMMax_24", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  df %>%
    select(-date) %>%
    transmute_at(vars(matches("^(PM2.5|PM10|NO2|CO|O3|SO2)$")), SMax_na_48) -> tmp
  names(tmp) <- paste("SMMax_48", names(tmp), sep = "_")
  df <- bind_cols(df, tmp)
  
  return(df)
}
