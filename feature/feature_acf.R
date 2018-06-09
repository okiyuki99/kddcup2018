exe_acf <- function(df, target){
  x <- acf(rev(df[,target]), plot = F, lag.max = nrow(df))$acf
  df <- mutate(df, target_acf = rev(x))
  return(df)
}
