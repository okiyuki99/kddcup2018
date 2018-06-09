exe_na_prep <- function(df){
  na_approx <- function(x){as.numeric(na.approx(zoo(x)))}
  df %>%
    mutate_at(vars(-matches("date")), funs(na_approx)) -> df
  return(df)
}
