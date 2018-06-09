exe_diff <- function(df, target){
  df %>%
    dplyr::mutate(diff_1 = get(target) - lag(get(target), n = 1, 0)) %>%
    dplyr::mutate(diff_3 = get(target) - lag(get(target), n = 3, 0)) %>%
    dplyr::mutate(diff_12 = get(target) - lag(get(target), n = 12, 0)) %>%
    dplyr::mutate(diff_24 = get(target) - lag(get(target), n = 24, 0)) %>%
    dplyr::mutate(diff_48 = get(target) - lag(get(target), n = 48, 0)) %>%
    dplyr::mutate(diff_72 = get(target) - lag(get(target), n = 72, 0)) -> df
  
  target <- paste0("SMA_3_",target)

  df %>%
    dplyr::mutate(diff_1_SMA_3 = get(target) - lag(get(target), n = 1, 0)) %>%
    dplyr::mutate(diff_3_SMA_3 = get(target) - lag(get(target), n = 3, 0)) %>%
    dplyr::mutate(diff_12_SMA_3 = get(target) - lag(get(target), n = 12, 0)) %>%
    dplyr::mutate(diff_24_SMA_3 = get(target) - lag(get(target), n = 24, 0)) %>%
    dplyr::mutate(diff_48_SMA_3 = get(target) - lag(get(target), n = 48, 0)) %>%
    dplyr::mutate(diff_72_SMA_3 = get(target) - lag(get(target), n = 72, 0)) -> df

  return(df)
}