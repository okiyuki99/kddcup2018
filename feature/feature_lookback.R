exe_lookback <- function(df, target){
  df %>%
    dplyr::mutate(look_back1 = lag(get(target), n = 1, 0)) %>% 
    dplyr::mutate(look_back2 = lag(get(target), n = 2, 0)) %>% 
    dplyr::mutate(look_back3 = lag(get(target), n = 3, 0)) %>% 
    dplyr::mutate(look_back4 = lag(get(target), n = 4, 0)) %>% 
    dplyr::mutate(look_back5 = lag(get(target), n = 5, 0)) %>% 
    dplyr::mutate(look_back6 = lag(get(target), n = 6, 0)) %>% 
    dplyr::mutate(look_back7 = lag(get(target), n = 7, 0)) %>% 
    dplyr::mutate(look_back8 = lag(get(target), n = 8, 0)) %>% 
    dplyr::mutate(look_back9 = lag(get(target), n = 9, 0)) %>% 
    dplyr::mutate(look_back10 = lag(get(target), n = 10, 0)) %>% 
    dplyr::mutate(look_back11 = lag(get(target), n = 11, 0)) %>% 
    dplyr::mutate(look_back12 = lag(get(target), n = 12, 0)) %>% 
    dplyr::mutate(look_back13 = lag(get(target), n = 13, 0)) %>% 
    dplyr::mutate(look_back14 = lag(get(target), n = 14, 0)) %>% 
    dplyr::mutate(look_back15 = lag(get(target), n = 15, 0)) %>% 
    dplyr::mutate(look_back16 = lag(get(target), n = 16, 0)) %>% 
    dplyr::mutate(look_back17 = lag(get(target), n = 17, 0)) %>% 
    dplyr::mutate(look_back18 = lag(get(target), n = 18, 0)) %>% 
    dplyr::mutate(look_back19 = lag(get(target), n = 19, 0)) %>% 
    dplyr::mutate(look_back20 = lag(get(target), n = 20, 0)) %>% 
    dplyr::mutate(look_back21 = lag(get(target), n = 21, 0)) %>% 
    dplyr::mutate(look_back22 = lag(get(target), n = 22, 0)) %>% 
    dplyr::mutate(look_back23 = lag(get(target), n = 23, 0)) %>% 
    dplyr::mutate(look_back24 = lag(get(target), n = 24, 0)) -> df
  return(df)
}