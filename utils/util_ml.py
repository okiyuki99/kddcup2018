import os,datetime,time
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler,RobustScaler

def smape(y_true, y_pred):
    return np.mean((np.abs(y_pred - y_true) * 200/ (np.abs(y_pred) + np.abs(y_true))))

def getSeqDatetime(start, end, m = "1hour"):
    start = datetime.datetime.strptime(start, '%Y-%m-%d-%H')
    end = datetime.datetime.strptime(end, '%Y-%m-%d-%H')
    start_min = time.mktime(start.timetuple())
    end_min = time.mktime(end.timetuple())
    if m == '1hour' :
        minutes_diff = int((end_min - start_min) / (60*60)) + 1
        seq_datetime = np.array([start + datetime.timedelta(hours=i) for i in range(minutes_diff)])
    return(seq_datetime)

def create_train_dataset(df, method, start_time, end_time, look_back, zurashi_time, target) :
    if method == "m1" :
        X_train, y_train = create_dataset1(df, start_time, end_time, look_back, zurashi_time, "train", "y")
        return X_train, y_train
    elif method == "m2" :
        X_train, columns, y_train = create_dataset2(df, start_time, end_time, look_back, zurashi_time, "train", target)
        return X_train, columns, y_train
    elif method == "m3" :
        X_train, columns, y_train  = create_dataset3(df, start_time, end_time, look_back, zurashi_time, "train", target)
        #return X_train, columns, y_train, X_train_end_time, X_train_start_time, y_train_end_time, y_train_start_time 
        return X_train, columns, y_train

def create_test_dataset(df, method, start_time, end_time, look_back, target) :
    if method == "m1" :
        X_test = create_dataset1(df, start_time, end_time, look_back, None, "test", "y")
    elif method == "m2" :
        X_test = create_dataset2(df, start_time, end_time, look_back, None, "test", target)
    elif method == "m3" :
        X_test = create_dataset3(df, start_time, end_time, look_back, None, "test", target)
    return X_test

def create_dataset1(df, start_time, end_time, look_back, zurashi_time, train_test, target) :
    X, Y = [], []
    seq_date = getSeqDatetime(start_time, end_time)
    if train_test == "train":
        for d in seq_date :
            if not df[df["date"] == d].shape[0] == 0 : 
                Y.append(np.array(df[df["date"] == d][target])[0])
                df_tmp = df[df["date"] < (d - datetime.timedelta(hours=zurashi_time))]
                df_tmp = df_tmp[~np.isnan(df_tmp[target])]
                df_tmp = df_tmp.tail(look_back)
                X.append(df_tmp[target])
        return np.array(X), np.array(Y)
    elif train_test == "test" :
        for d in seq_date :
            df_tmp = df[df["date"] <= d]
            df_tmp = df_tmp[~np.isnan(df_tmp[target])]
            df_tmp = df_tmp.tail(look_back)
            X.append(df_tmp[target])
        return np.array(X)

def create_dataset2(df, start_time, end_time, look_back, zurashi_time, train_test, target) :
    seq_date = getSeqDatetime(start_time, end_time)
    start_time = datetime.datetime.strptime(start_time, '%Y-%m-%d-%H')
    end_time = datetime.datetime.strptime(end_time, '%Y-%m-%d-%H')

    if train_test == "train":
        all_dates = list(df["date"])
        df_training = df[(df["date"] >= start_time)  & (df["date"] <= end_time)]
        training_dates = list(df_training["date"])
        training_exist_dates = [d for d in training_dates if (d in all_dates) and (d - datetime.timedelta(hours = zurashi_time)) in all_dates]
        columns = []
        # Y
        train_y_dates = training_exist_dates
        Y = list(df[df["date"].isin(train_y_dates)][target])

        # X
        X = []
        train_X_dates = [d - datetime.timedelta(hours = zurashi_time) for d in training_exist_dates]

        df_target = df[["date",target]]
        for d in train_X_dates :
            df_tmp = df_target[df_target["date"] <= d]
            df_tmp = df_tmp.drop(["date"], axis = 1)
            df_tmp = df_tmp.tail(look_back)
            X.append(np.array(df_tmp).reshape(-1))
        X = np.array(X)
        columns = ["loop_back"+str(i) for i in range(look_back)]
        
        df_non_target = df[df["date"].isin(train_X_dates)]
        df_non_target = df_non_target.drop(["date",target], axis = 1)
        columns.extend(list(df_non_target.columns))
        X = np.hstack((X, pd.DataFrame.as_matrix(df_non_target)))
        return(X, columns, np.array(Y))

    elif train_test == "test":
        # X
        X_target = []
        df_target = df[["date",target]]
        for d in seq_date :
            df_tmp = df_target[df_target["date"] <= d]
            df_tmp = df_tmp.drop(["date"], axis = 1)
            df_tmp = df_tmp.tail(look_back)
            X_target.append(np.array(df_tmp).reshape(-1))
        X_target = np.array(X_target)
        X_non_target = []
        for d in seq_date :
            df_non_target = df[df["date"] <= d].tail(1)
            df_non_target = df_non_target.drop(["date",target], axis = 1)
            X_non_target.append(np.array(df_non_target).reshape(-1))
        X_non_target = np.array(X_non_target)
        X = np.hstack((X_target, X_non_target))
        return X

def create_dataset3(df, start_time, end_time, look_back, zurashi_time, train_test, target) :
    seq_date = getSeqDatetime(start_time, end_time)
    start_time = datetime.datetime.strptime(start_time, '%Y-%m-%d-%H')
    end_time = datetime.datetime.strptime(end_time, '%Y-%m-%d-%H')

    if train_test == "train":
        all_dates = list(df["date"])
        df_training = df[(df["date"] >= start_time)  & (df["date"] <= end_time)]
        training_dates = list(df_training["date"])
        training_exist_dates = [d for d in training_dates if (d in all_dates) and (d - datetime.timedelta(hours = zurashi_time)) in all_dates]
        # Y
        train_y_dates = training_exist_dates
        df_y = df[df["date"].isin(train_y_dates)]
        Y = list(df_y[target])

        #y_train_end_time = df_y["date"][df_y.shape[0]-1]
        #y_train_end_time = datetime.datetime.strftime(y_train_end_time, "%Y-%m-%d-%H")
        #y_train_start_time = df_y["date"][0]
        #y_train_start_time = datetime.datetime.strftime(y_train_start_time, "%Y-%m-%d-%H")

        # X
        X = []
        train_X_dates = [d - datetime.timedelta(hours = zurashi_time) for d in training_exist_dates]
        df_non_target = df[df["date"].isin(train_X_dates)]

        #X_train_end_time = df_non_target["date"][df_non_target.shape[0]-1]
        #X_train_end_time = datetime.datetime.strftime(X_train_end_time, "%Y-%m-%d-%H")
        #X_train_start_time = df_non_target["date"][0]
        #X_train_start_time = datetime.datetime.strftime(X_train_start_time, "%Y-%m-%d-%H")

        df_non_target = df_non_target.drop(["date",target], axis = 1)
        columns = list(df_non_target.columns)
        X = pd.DataFrame.as_matrix(df_non_target)
        
        #return X, columns, np.array(Y), X_train_end_time, X_train_start_time, y_train_end_time, y_train_start_time
        return X, columns, np.array(Y)

    elif train_test == "test":

        # X
        X = []
        for d in seq_date :
            df_non_target = df[df["date"] <= d].tail(1)
            df_non_target = df_non_target.drop(["date",target], axis = 1)
            X.append(np.array(df_non_target).reshape(-1))
        X = np.array(X)
        return X

# y times 48
def create_train(df, target, training_hours, end_time, zurashi_time):
    y_list = []
    for i in range(48) :
        end_time_new = datetime.datetime.strptime(end_time, "%Y-%m-%d-%H") - datetime.timedelta(hours=i)
        end_time_new = datetime.datetime.strftime(end_time_new, "%Y-%m-%d-%H")        
        start_time = datetime.datetime.strptime(end_time_new, "%Y-%m-%d-%H")  - datetime.timedelta(hours=training_hours)
        start_time = datetime.datetime.strftime(start_time, "%Y-%m-%d-%H")
        print("y_train:", start_time, "-", end_time_new)
        df_y = df[(df["date"] >= start_time)  & (df["date"] <= end_time_new)]
        y = list(df_y[t])
        y_list.append(y)
    y = np.array(y_list).transpose()
    
    x_train_end = end_time_new = datetime.datetime.strptime(end_time, "%Y-%m-%d-%H") - datetime.timedelta(hours=zurashi_time)
    x_train_end = datetime.datetime.strftime(x_train_end, "%Y-%m-%d-%H")        
    x_train_start = datetime.datetime.strptime(x_train_end, "%Y-%m-%d-%H")  - datetime.timedelta(hours=training_hours)
    x_train_start = datetime.datetime.strftime(x_train_start, "%Y-%m-%d-%H")
    print("X_train : ", x_train_start, "-", x_train_end) 
    df_training = df[(df["date"] >= x_train_start)  & (df["date"] <= x_train_end)]
    df_training = df_training.drop(["date",target], axis = 1)
    columns = list(df_training.columns)
    X = pd.DataFrame.as_matrix(df_training)
    return(X, y)

# x time 48
def create_train_multi_x(df, target, training_hours, end_time, zurashi_time):
    start_time = datetime.datetime.strptime(end_time, "%Y-%m-%d-%H")  - datetime.timedelta(hours=training_hours)
    start_time = datetime.datetime.strftime(start_time, "%Y-%m-%d-%H")
    print("y_train:", start_time, "-", end_time)
    df_y = df[(df["date"] >= start_time)  & (df["date"] <= end_time)]
    y = np.array(df_y[target]) 
 
    X_list = []
    for i in range(48):
        x_train_end = datetime.datetime.strptime(end_time, "%Y-%m-%d-%H") - datetime.timedelta(hours=zurashi_time - i)
        x_train_end = datetime.datetime.strftime(x_train_end, "%Y-%m-%d-%H")        
        x_train_start = datetime.datetime.strptime(x_train_end, "%Y-%m-%d-%H")  - datetime.timedelta(hours=training_hours)
        x_train_start = datetime.datetime.strftime(x_train_start, "%Y-%m-%d-%H")
        print("X_train_",i,":", x_train_start, "-", x_train_end) 
        df_training = df[(df["date"] >= x_train_start)  & (df["date"] <= x_train_end)]
        df_training = df_training.drop(["date",target], axis = 1)
        X = pd.DataFrame.as_matrix(df_training)
        X_list.append(X)
    X = np.array(X_list)
    columns = list(df_training.columns)
    return(X, columns, y)

# na omit
def prep_na(X_train, y_train, method) :
    if method == "m1" :
        is_nan_train = ~np.isnan(X_train).any(axis=1) & ~np.isnan(y_train)
        X_train = X_train[is_nan_train]
        y_train = y_train[is_nan_train]
    return X_train, y_train

# mean = 0 and sd = 1
def prep_scale(X_train, X_test, method) :
    if method == "m1" :
        sc = StandardScaler()
        sc.fit(np.vstack(([X_train, X_test])))
        X_train = sc.transform(X_train)
        X_test = sc.transform(X_test)
    elif method == "m2" :
        X_train[X_train <= -0.9] = -0.9
        X_test[X_test <= -0.9] = -0.9
        X_train = np.log1p(X_train)
        X_test = np.log1p(X_test)
    elif method == "m3" :
        rs = RobustScaler(quantile_range=(25.0, 75.0))
        rs.fit(np.vstack(([X_train, X_test])))
        X_train = rs.transform(X_train)
        X_test = rs.transform(X_test)
    return X_train, X_test

# np.log1p and treat minus value 
def prep_log1p(y) :
    y[y <= -0.9] = -0.9
    y = np.log1p(y)
    return y

# train -> train and valid
def create_train_valid(X_train, y_train, valid_diff_size) :
    valid_size = 48
    X_valid, y_valid = X_train[-valid_size:], y_train[-valid_size:]
    X_train, y_train = X_train[0:int(len(X_train)-valid_size-valid_diff_size)], y_train[0:int(len(y_train)-valid_size-valid_diff_size)]
    return(X_train, y_train, X_valid, y_valid)

def create_valid_data(X_train_iter, y_train_iter, zurashi_time, method, **kg):
    if method == "m1" :
        X_valid = np.array([X_train_iter[-1,:]])
        X_train_iter = X_train_iter[0:(X_train_iter.shape[0]- zurashi_time + i), :]
        y_valid = np.array([y_train_iter[-1]])
        y_train_iter = y_train_iter[0:(y_train_iter.shape[0]- zurashi_time + i)]
    elif method == "m2" :
        y_valid = np.array([y_train_iter[-48+kg["i"]]])
        y_train_iter = y_train_iter[0:(y_train_iter.shape[0]-48-zurashi_time)]
        y_train_end_new = datetime.datetime.strptime(kg["y_train_end"], "%Y-%m-%d-%H") - datetime.timedelta(hours=zurashi_time)
        y_train_end_new = datetime.datetime.strftime(y_train_end_new, "%Y-%m-%d-%H")        
        X_valid = pd.DataFrame.as_matrix(kg["df"][kg["df"]["date"] == y_train_end_new].drop(["date",kg["target"]], axis = 1))  
        X_train_iter = X_train_iter[0:(X_train_iter.shape[0]-48-zurashi_time), :]
    return X_train_iter, y_train_iter, X_valid, y_valid
   
def getLatestData(DIR_FEATURE) :
    CURRENT_TIME = datetime.datetime.utcnow()
    CURRENT_HOUR = datetime.datetime.strftime(CURRENT_TIME, "%Y-%m-%d-%H")
    DIR_LATEST = DIR_FEATURE+"/"+CURRENT_HOUR
    while True :
        if os.path.isdir(DIR_LATEST) :
            break
        CURRENT_HOUR = datetime.datetime.strptime(CURRENT_HOUR, "%Y-%m-%d-%H") - datetime.timedelta(hours=1)
        CURRENT_HOUR = datetime.datetime.strftime(CURRENT_HOUR, "%Y-%m-%d-%H")
        DIR_LATEST = DIR_FEATURE+"/"+CURRENT_HOUR
    return(DIR_LATEST)

def getParaDates(df, TRAINING_HOUR = 7*8*24 - 1) :
    y_test_end_time = datetime.datetime.strftime(np.max(df["date"]) + datetime.timedelta(days=2), "%Y-%m-%d")+"-23"
    zurashi_time = (datetime.datetime.strptime(y_test_end_time, "%Y-%m-%d-%H") - np.max(df["date"]))
    zurashi_time = (zurashi_time / 3600).seconds
    X_test_end_time = datetime.datetime.strftime(np.max(df["date"]),"%Y-%m-%d-%H")
    X_test_start_time = datetime.datetime.strftime((datetime.datetime.strptime(X_test_end_time, "%Y-%m-%d-%H") - datetime.timedelta(hours = 47)),"%Y-%m-%d-%H")
    y_train_end_time = X_test_end_time
    y_train_start_time = datetime.datetime.strptime(y_train_end_time, "%Y-%m-%d-%H") - datetime.timedelta(hours=TRAINING_HOUR)
    y_train_start_time = datetime.datetime.strftime(y_train_start_time, "%Y-%m-%d-%H")
    return y_train_start_time, y_train_end_time, X_test_start_time, X_test_end_time, zurashi_time

def getZurashiTime(df, y_test_end) :
    zurashi_time = (datetime.datetime.strptime(y_test_end, "%Y-%m-%d-%H") - np.max(df["date"]))
    zurashi_time = (zurashi_time / 3600).seconds
    return zurashi_time
