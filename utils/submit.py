import sys,datetime,re
import pandas as pd
from var import CITYS,STATIONS
sys.path.append("api/")
from api_submit import submission_post

def create_submit_file_each(y_predict, t, s) :
    df = pd.DataFrame({"test_id" : s, t : y_predict})
    df["row_number"] = range(0,48)
    df["test_id"] = df["test_id"]+"#"+df["row_number"].astype(str)
    df = df[["test_id",t]]
    return(df)

def merge_same_city(df_predict1, df_predict2, *args) :
    # lon 
    if len(args) == 0 :
        df = pd.merge(df_predict1, df_predict2, on='test_id', how='inner')
        df["O3"] = 0
        assert df.shape[0] == 48, "df.shape[0] is not 48"
        df = df[["test_id","PM2.5","PM10","O3"]]
    # bei
    else :
        df = pd.merge(df_predict1, df_predict2, on='test_id', how='inner')
        df = pd.merge(df, args[0], on = 'test_id', how = 'inner')
        assert df.shape[0] == 48, "df.shape[0] is not 48"
        df = df[["test_id","PM2.5","PM10","O3"]]
    return(df)

def create_submission(DIR_RESULT, is_submit = False) :
    df_submit = pd.DataFrame()
    for c in CITYS  :
        for s in STATIONS[c] :
            if c == "bei" :
                df_predict1 = pd.read_csv(DIR_RESULT+"/"+c+"_PM2.5_"+s+"_test_predict.csv")
                df_predict2 = pd.read_csv(DIR_RESULT+"/"+c+"_PM10_"+s+"_test_predict.csv")
                df_predict3 = pd.read_csv(DIR_RESULT+"/"+c+"_O3_"+s+"_test_predict.csv")
                df_predict = merge_same_city(df_predict1, df_predict2, df_predict3)
            elif c == "lon" : 
                df_predict1 = pd.read_csv(DIR_RESULT+"/"+c+"_PM2.5_"+s+"_test_predict.csv")
                df_predict2 = pd.read_csv(DIR_RESULT+"/"+c+"_PM10_"+s+"_test_predict.csv")
                df_predict = merge_same_city(df_predict1, df_predict2)
            df_submit = pd.concat([df_submit, df_predict], ignore_index = True, axis=0)
    df_submit["test_id"] = df_submit["test_id"].str.replace('aotizhongxin_aq', 'aotizhongx_aq')
    df_submit["test_id"] = df_submit["test_id"].str.replace('fengtaihuayuan_aq', 'fengtaihua_aq')
    df_submit["test_id"] = df_submit["test_id"].str.replace('miyunshuiku_aq', 'miyunshuik_aq')
    df_submit["test_id"] = df_submit["test_id"].str.replace('nongzhanguan_aq', 'nongzhangu_aq')
    df_submit["test_id"] = df_submit["test_id"].str.replace('wanshouxigong_aq', 'wanshouxig_aq')
    df_submit["test_id"] = df_submit["test_id"].str.replace('xizhimenbei_aq', 'xizhimenbe_aq')
    df_submit["test_id"] = df_submit["test_id"].str.replace('yongdingmennei_aq', 'yongdingme_aq')

    # negative valuee check
    if sum(df_submit["PM2.5"] < 0) > 0 :
        df_submit.loc[df_submit["PM2.5"] < 0, "PM2.5"] = 0.0001
    if sum(df_submit["PM10"] < 0) > 0 :
        df_submit.loc[df_submit["PM10"] < 0, "PM10"] = 0.0001
    if sum(df_submit["O3"] < 0) > 0 :
        df_submit.loc[df_submit["O3"] < 0, "O3"] = 0.0001

    # save
    pd.DataFrame.to_csv(df_submit, DIR_RESULT+"/submission.csv", index=False, header=True, encoding='utf-8')
 
    if is_submit == True :
        description = str.replace(DIR_RESULT, "/mnt/data/kddcup2018/","")
        description = re.sub("_[0-9]{14}","", description)
        submission_post(DIR_RESULT+"/submission.csv", description, "submission.csv")

