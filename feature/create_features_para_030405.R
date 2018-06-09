# Feature Hourly Create 5
source("utils/library.R")
source("feature/feature_moving2.R")
source("feature/feature_holtwinters.R")
source("feature/feature_naimpute.R")
source("feature/feature_acf.R")
source("feature/feature_lookback.R")
source("feature/feature_diff.R")
source("feature/feature_stl.R")
source("feature/feature_weather_encoder.R")

library(doParallel)
library(foreach)
library(TTR)
library(zoo)
DIR_INPUT_CLEAN <- "/mnt/data/kddcup2018/input_clean"
DIR_API_INPUT <- "/mnt/data/kddcup2018/input_api"

## Load Original Data
df.bei.aq.weather <- readRDS(paste0(DIR_INPUT_CLEAN,"/original_bei_aq_weather.RDS"))
df.lon.aq1.weather <- readRDS(paste0(DIR_INPUT_CLEAN,"/original_lon_aq1_weather.RDS"))
df.bei.obs.nearest <- readRDS(paste0(DIR_INPUT_CLEAN,"/bei_obs_nearest.RDS"))
df.bei.grid.nearest <- readRDS(paste0(DIR_INPUT_CLEAN,"/bei_grid_nearest.RDS"))
df.lon.grid.nearest <- readRDS(paste0(DIR_INPUT_CLEAN,"/lon_grid_nearest.RDS"))

## Laod API Data AQ on the fly
### データAPIの後に実行必須
API_ENDTIME <- format(Sys.time(), "%Y-%m-%d-%H") #CIなら 
#API_ENDTIME <- format(Sys.time() - 9 * 60 * 60, "%Y-%m-%d-%H") #手元
SPAN <- paste0("2018-03-31-00_",API_ENDTIME)
df.api.bei.aq <- fread(paste0(DIR_API_INPUT,"/",SPAN,"/bj_airquality.csv"), header = T)
df.api.ld.aq <- fread(paste0(DIR_API_INPUT,"/",SPAN,"/ld_airquality.csv"), header = T)
print(SPAN)
names(df.api.bei.aq)[3:9] <- c("utc_time","PM2.5","PM10","NO2","CO","O3","SO2")
names(df.api.ld.aq)[3:9] <- c("utc_time","PM2.5","PM10","NO2","CO","O3","SO2")
df.api.bei.aq %<>% select(-id)
df.api.ld.aq %<>% select(-id, -CO, -O3, -SO2)
df.api.bei.aq %<>% mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S"))
df.api.ld.aq %<>% mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S"))

## Load API Data Meo on the fly
df.api.bei.obs.meo <- fread(paste0(DIR_API_INPUT,"/",SPAN,"/bj_meteorology.csv"), header = T)
df.api.bei.grid.meo <- fread(paste0(DIR_API_INPUT,"/",SPAN,"/bj_grid_meteorology.csv"), header = T)
df.api.ld.grid.meo <- fread(paste0(DIR_API_INPUT,"/",SPAN,"/ld_grid_meteorology.csv"), header = T)
names(df.api.bei.grid.meo)[2:3] <- c("stationName", "utc_time")
names(df.api.bei.obs.meo)[2:3] <- c("stationName", "utc_time")
names(df.api.ld.grid.meo)[2:3] <- c("stationName", "utc_time")
df.api.bei.obs.meo %<>% select(-id)
df.api.bei.grid.meo %<>% select(-id)
df.api.ld.grid.meo %<>% select(-id)
df.api.bei.obs.meo %<>% mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S"))
df.api.bei.grid.meo %<>% mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S"))
df.api.ld.grid.meo %<>% mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S"))

## Bind API AQ and Meo
df.api.bei.aq %>%
  inner_join(df.bei.grid.nearest, by = "station_id") %>%
  left_join(df.api.bei.grid.meo, by = c("nearest" = "stationName", "utc_time")) %>%
  select(-nearest) %>%
  rename(grid1_temperature = "temperature",
         grid1_pressure = "pressure",
         grid1_humidity = "humidity",
         grid1_wind_direction = "wind_direction",
         grid1_wind_speed = "wind_speed",
         grid1_weather = "weather") -> df.api.bei.aq.weather

df.api.bei.aq.weather %>%
  inner_join(df.bei.obs.nearest, by = "station_id") %>%
  left_join(df.api.bei.obs.meo, by = c("nearest" = "stationName", "utc_time")) %>%
  select(-nearest) %>%
  rename(obs1_temperature = "temperature",
         obs1_pressure = "pressure",
         obs1_humidity = "humidity",
         obs1_wind_direction = "wind_direction",
         obs1_wind_speed = "wind_speed",
         obs1_weather = "weather") -> df.api.bei.aq.weather

df.api.ld.aq %>%
  inner_join(df.lon.grid.nearest, by = "station_id") %>%
  left_join(df.api.ld.grid.meo, by = c("nearest" = "stationName", "utc_time")) %>%
  select(-nearest) %>%
  rename(grid1_temperature = "temperature",
         grid1_pressure = "pressure",
         grid1_humidity = "humidity",
         grid1_wind_direction = "wind_direction",
         grid1_wind_speed = "wind_speed",
         grid1_weather = "weather") -> df.api.ld.aq.weather

## Bind
df.bei.aq <- bind_rows(df.bei.aq.weather, df.api.bei.aq.weather) %>% unique() %>% arrange(station_id)
df.lon.aq1 <- bind_rows(df.lon.aq1.weather, filter(df.api.ld.aq.weather, station_id %in% unique(df.lon.aq1.weather$station_id))) %>% unique() %>% arrange(station_id)

## filter > 2017-3-31 23:59:59
## 全データだと、HoltWintersでエラーがでる
## In HoltWinters(ts(x, frequency = freq), alpha = NULL, beta = NULL,  :
## optimization difficulties: ERROR: ABNORMAL_TERMINATION_IN_LNSRCH
df.bei.aq <- filter(df.bei.aq, utc_time >= as.POSIXct("2017/09/30 23:59:59", "UTC"))
df.lon.aq1 <- filter(df.lon.aq1, utc_time >= as.POSIXct("2017/09/30 23:59:59", "UTC"))

## Setting
CITYS <- c("bei","lon")
DATAS <- list("bei" = df.bei.aq, "lon" = df.lon.aq1)
TARGETS <- list("bei" = c("PM2.5","PM10","O3"), "lon" = c("PM2.5","PM10"))
STATIONS <- list("bei" = unique(df.bei.aq$station_id), "lon" = unique(df.lon.aq1$station_id))

## create feature
DIR_OUTPUT_03 <- paste0("/mnt/data/kddcup2018/feature_03/",API_ENDTIME)
dir.create(DIR_OUTPUT_03, recursive = T, showWarnings = F)
Sys.chmod(DIR_OUTPUT_03, mode = "0770", use_umask = FALSE)

DIR_OUTPUT_04 <- paste0("/mnt/data/kddcup2018/feature_04/",API_ENDTIME)
dir.create(DIR_OUTPUT_04, recursive = T, showWarnings = F)
Sys.chmod(DIR_OUTPUT_04, mode = "0770", use_umask = FALSE)

DIR_OUTPUT_05 <- paste0("/mnt/data/kddcup2018/feature_05/",API_ENDTIME)
dir.create(DIR_OUTPUT_05, recursive = T, showWarnings = F)
Sys.chmod(DIR_OUTPUT_05, mode = "0770", use_umask = FALSE)

cl <- makeCluster(6)
registerDoParallel(cl)

# train test
for(c in CITYS){
  df <- DATAS[[c]]
  tt <- TARGETS[[c]]
  ss <- STATIONS[[c]]
  for(t in tt){
    foreach(s = ss, .errorhandling = 'pass', .packages = c("dplyr","lubridate","zoo")) %dopar% {
      print(paste(c,t,s))
      # 時系列変数の選択
      if(c == "lon"){
        df %>%
          filter(station_id == s) %>%
          select(-station_id) %>%
          mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S")) %>%
          arrange(utc_time) %>%
          rename(date = "utc_time") -> df.clean
        #rename(quo(t) = "y") %>% target value を y に変えようと思ったけど、別にいいか
        if(s == "MY7" || s == "KF1"){ # MY7, KF1 のNO2がすべてNullなので
          df.clean <- dplyr::select(df.clean, -NO2)
        }
        
      }else{
        if(t == "PM2.5"){
          df %>%
            filter(station_id == s) %>%
            select(-station_id, -O3) %>%
            mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S")) %>%
            arrange(utc_time) %>%
            rename(date = "utc_time") -> df.clean
        }else if(t == "PM10"){
          df %>%
            filter(station_id == s) %>%
            select(-station_id, -O3) %>%
            mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S")) %>%
            arrange(utc_time) %>%
            rename(date = "utc_time") -> df.clean
        }else if(t == "O3"){
          df %>%
            filter(station_id == s) %>%
            select(-station_id) %>%
            select(utc_time, O3, NO2) %>%
            mutate(utc_time = parse_date_time(utc_time, "%Y-%m-%d %H:%M:%S")) %>%
            arrange(utc_time) %>%
            rename(date = "utc_time") -> df.clean
        }
      }
      
      # 存在しない日付を挿入
      df.dates <- data.frame(date = seq(min(df.clean$date), max(df.clean$date), by = "1 hour"), stringsAsFactors = F)
      df.clean <- left_join(df.dates, df.clean, by = "date")
      
      # 同じ日付のデータがあれば、下を取る
      df.clean %>%
        group_by(date) %>% 
        filter(row_number()==n()) %>%
        ungroup(date) %>% 
        as.data.frame() -> df.clean
      
      # Weather Label Encoder 
      df.clean <- exe_weather_label_encode(df.clean)
      
      # NA imputation 
      if(s != "zhiwuyuan_aq"){
        ## head 1 prep
        df.clean %>% head(1) -> tmp
        if(nrow(na.omit(tmp)) == 0){
          for(i in names(tmp)){
            if(is.na(tmp[,i])){
              tmp[,i] <- median(df.clean[,i], na.rm=T)
            }
          }
        }
        df.clean %<>% tail(-1) %>% bind_rows(tmp, .)
        ## tail 1 prep
        df.clean %>% tail(1) -> tmp
        if(nrow(na.omit(tmp)) == 0){
          for(i in names(tmp)){
            if(is.na(tmp[,i])){
              tmp[,i] <- median(df.clean[(nrow(df.clean)-48):nrow(df.clean),i], na.rm=T) # 直近48時点のMedianでImpute
            }
            if(is.na(tmp[,i])){
              tmp[,i] <- zoo::na.locf(df.clean[,i])[nrow(df.clean)] # 直近の値でimpute 
            }
          }
        }
        df.clean %<>% head(-1) %>% bind_rows(., tmp)
        
        # 線形補完
        df.clean <- exe_na_prep(df.clean)
      }
      
      # Look back
      df.clean <- exe_lookback(df.clean, t)
      
      # 移動平均系
      df.clean <- exe_moving2(df.clean)
      
      # HoltWinners
      df.clean <- exe_holtwinters(df.clean, 24)
      
      # 自己相関係数
      if(s != "zhiwuyuan_aq"){
        df.clean <- exe_acf(df.clean, t)
      }
      
      # diff 
      df.clean <- exe_diff(df.clean, t)
      
      # STL
      if(s != "zhiwuyuan_aq"){
        df.clean <- exe_stl(df.clean, 24)
      }
      
      # re filter 
      df.clean <- filter(df.clean, date >= as.POSIXct("2017/10/31 23:59:59", "UTC"))
      
      # add hour and week of (2017+2018) 
      df.clean %<>%
        mutate(hour = hour(date)) %>%
        mutate(year = year(date)) %>%
        mutate(week_of_201718 = week(date)) %>%
        mutate(week_of_201718 = ifelse(.$year == 2018, .$week_of_201718 + 53, .$week_of_201718)) %>%
        select(-year)
      
      # na check
      print(paste(c,t,s, "NAs :", is.na(df.clean)%>%sum))
      
      # save 5
      filename <- paste0(DIR_OUTPUT_05,"/",c,"_",t,"_",s,".tsv")
      write.table(df.clean, filename, sep = "\t", quote = F, row.names = F)
      Sys.chmod(filename, mode = "0770", use_umask = FALSE)
      
      df.clean %>%
        select(-contains("obs1_")) %>%
        select(-contains("grid1_")) -> df.clean
      
      # save 4
      filename <- paste0(DIR_OUTPUT_04,"/",c,"_",t,"_",s,".tsv")
      write.table(df.clean, filename, sep = "\t", quote = F, row.names = F)
      Sys.chmod(filename, mode = "0770", use_umask = FALSE)
      
      df.clean %>%
        select(-contains("_stl_")) %>%
        select(-contains("diff_")) -> df.clean
      
      # save 3
      filename <- paste0(DIR_OUTPUT_03,"/",c,"_",t,"_",s,".tsv")
      write.table(df.clean, filename, sep = "\t", quote = F, row.names = F)
      Sys.chmod(filename, mode = "0770", use_umask = FALSE)
    }
  }
}

stopCluster(cl)
