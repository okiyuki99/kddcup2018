import os,datetime,sys,joblib,argparse,json
from itertools import product
from tqdm import tqdm
sys.path.append("utils/")
from var import CITYS,TARGETS,STATIONS
from util_ml import *
from submit import *
from notify import *
sys.path.append("models/")
from xgb import *

def main(**kg) :
    print(datetime.datetime.now().strftime('%Y/%m/%d %H:%M:%S'),"START",json.dumps(kg, sort_keys = True))
    df = pd.read_csv(kg["dir_feature"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+".tsv", sep = "\t", dtype = {'date' : str}, parse_dates=[0])

    if kg["station"] == 'zhiwuyuan_aq' :
        df = df[["date",kg["target"]]]
        df = df.dropna()
        #S = 48
        #alp = 2/(1+S)
        alp = 0.0408
        df['ema'] = df[kg['target']].ewm(alpha = alp).mean()
        y_test_predict = np.array(df[df["date"] <=  datetime.datetime.strptime("2017-11-23 23", '%Y-%m-%d %H')]["ema"].tail(48))
        df_test = create_submit_file_each(y_test_predict, kg["target"], kg["station"])

        # save
        if not os.path.isdir(kg["dir_result"]) : os.makedirs(kg["dir_result"], exist_ok = True) 
        pd.DataFrame.to_csv(df_test, kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_test_predict.csv", index=False, header=True)

        print(datetime.datetime.now().strftime('%Y/%m/%d %H:%M:%S'),"END",json.dumps(kg, sort_keys = True))
        return(np.nan)
 
    else :
        y_train_end = datetime.datetime.strftime(np.max(df["date"]), "%Y-%m-%d-%H")
        y_test_end = kg["para_y_test_end"]
        zurashi_time = getZurashiTime(df, y_test_end)
        #print("zurashi_time",str(zurashi_time))

        X_train, columns, y_train = create_train_multi_x(df, kg["target"], kg["para_training_hour"], y_train_end, zurashi_time)
        #print(X_train.shape, y_train.shape, len(columns))

        X_test = pd.DataFrame.as_matrix(df[df["date"] == y_train_end].drop(["date", kg["target"]], axis = 1))

        y_test_predict = []
        if not kg["is_novalid"] : 
            df_valid = pd.DataFrame()

        for i in tqdm(range(48)) :
            X_train_iter = X_train[i]
            X_train_iter, y_train_iter = prep_na(X_train_iter, y_train, kg["para_nan_method"])
            X_train_iter, X_test_iter = prep_scale(X_train_iter, X_test, kg["para_x_prep_method"])
            y_train_iter = prep_log1p(y_train_iter) 

            if not kg["is_novalid"] :
                if kg["para_valid_method"] == "m1" :
                    X_train_iter, y_train_iter, X_valid, y_valid = create_valid_data(X_train_iter, y_train_iter, zurashi_time, kg["para_valid_method"])
                elif kg["para_valid_method"] == "m2" :
                    X_train_iter, y_train_iter, X_valid, y_valid = create_valid_data(X_train_iter, y_train_iter, zurashi_time, kg["para_valid_method"], i = i, y_train_end = y_train_end, df = df, target = kg["target"])
                #X_valid = np.array([X_train_iter[-1,:]])
                #X_train_iter = X_train_iter[0:(X_train_iter.shape[0]- zurashi_time + i), :]
                #y_valid = np.array([y_train_iter[-1]])
                #y_train_iter = y_train_iter[0:(y_train_iter.shape[0]- zurashi_time + i)]

            #print("X_train",i,":",X_train_iter.shape, " y_train :", y_train_iter.shape)
            #if not kg["is_novalid"] :
            #    print("X_valid",i,":",X_valid.shape, " y_valid :", y_valid.shape)
            #print("X_test : ", X_test_iter.shape)

            if kg["is_novalid"] : 
                d_train, d_valid, d_test = xgb_create_dmatrix(X_train_iter, y_train_iter, np.array([]), np.array([]), X_test_iter)
            else :
                d_train, d_valid, d_test = xgb_create_dmatrix(X_train_iter, y_train_iter, X_valid, y_valid, X_test_iter)

            base_score = xgb_base_score(y_train_iter, kg["xg_base_score_method"])

            del X_train_iter, y_train_iter, X_test_iter

            params, num_boost_round, early_stopping_round, maximize, verbose_level = xgb_set_parameter(kg["xg_eta"], kg["xg_min_child_weight"], kg["xg_max_depth"], kg["xg_gamma"], kg["xg_subsample"], kg["xg_colsample_bytree"], kg["xg_seed"], base_score, kg["num_boost_round"], kg["early_stopping_round"], kg["xg_maximize"], kg["xg_verbose_level"])

            model, eval_result, fscore = xgb_run(d_train, d_valid, columns, params, num_boost_round, early_stopping_round, maximize, verbose_level)
 
            if not os.path.isdir(kg["dir_result"]) : 
                os.makedirs(kg["dir_result"], exist_ok = True) 

            if not kg["is_novalid"] :
                df_valid_tmp = pd.DataFrame({"y_predict" : np.exp(model.predict(d_valid)) - 1, "y_true" : np.exp(y_valid) - 1})
                df_valid = pd.concat([df_valid, df_valid_tmp], ignore_index = True, axis=0)

            y_test_predict.extend(np.exp(model.predict(d_test)) - 1)

            # xgb save
            if not os.path.isdir(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_eval_result") : 
                os.makedirs(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_eval_result", exist_ok = True)
                xgb_save_eval_result(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_eval_result"+"/"+str(i)+".json", eval_result)
            if not os.path.isdir(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_fscore") : 
                os.makedirs(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_fscore", exist_ok = True)
                xgb_save_importance_json(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_fscore"+"/"+str(i)+".json",fscore)
                xgb_save_importance_png(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_fscore"+"/"+str(i)+".png", fscore)

        if not kg["is_novalid"] :
            df_valid = df_valid[::-1].reset_index(drop=True)
            valid_smape = smape(df_valid["y_true"], df_valid["y_predict"])
            #print('Valid SMAPE: %.3f - %s_%s_%s' % (valid_smape, kg["city"], kg["target"], kg["station"]))

        df_test = create_submit_file_each(np.array(y_test_predict)[::-1], kg["target"], kg["station"])

        # save
        with open(kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_args.json", 'w') as f:
            json.dump(kg, f, ensure_ascii=False, sort_keys=True)
        if not kg["is_novalid"] :
            pd.DataFrame.to_csv(df_valid, kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_valid_predict_"+('%03.3f' % valid_smape)+".csv", index=False, header=True)    
        pd.DataFrame.to_csv(df_test, kg["dir_result"]+"/"+kg["city"]+"_"+kg["target"]+"_"+kg["station"]+"_test_predict.csv", index=False, header=True)

        # Fin
        print(datetime.datetime.now().strftime('%Y/%m/%d %H:%M:%S'),"END",json.dumps(kg, sort_keys = True))
        
        if kg["is_novalid"] :
            return 0
        else :
            return valid_smape

# ========================================
# multi exe
# ========================================
def multi_main(n_jobs, citys, targets, stations, dir_feature, para_create_method, para_training_hours, para_y_test_end, para_nan_methods, para_x_prep_methods, para_valid_methods, xg_etas, xg_min_child_weights, xg_max_depth, xg_gammas, xg_subsamples, xg_colsample_bytrees, xg_seeds, xg_base_score_methods, num_boost_rounds, early_stopping_rounds, xg_maximizes, xg_verbose_levels, is_latest, is_novalid, is_submit) :
    if is_latest :
        dir_feature = getLatestData(dir_feature)
    for (para_create_method, para_training_hour, para_nan_method, para_x_prep_method, para_valid_method, xg_eta, xg_min_child_weight, xg_max_depth, xg_gamma, xg_subsample, xg_colsample_bytree, xg_seed, xg_base_score_method, num_boost_round, early_stopping_round, xg_maximize, xg_verbose_level) \
        in product(para_create_method, para_training_hours, para_nan_methods, para_x_prep_methods, para_valid_methods, xg_etas, xg_min_child_weights, xg_max_depth, xg_gammas, xg_subsamples, xg_colsample_bytrees, xg_seeds, xg_base_score_methods, num_boost_rounds, early_stopping_rounds, xg_maximizes, xg_verbose_levels) :
        dir_result = dir_feature+"/xg2_"+datetime.datetime.now().strftime('%Y%m%d%H%M%S')
        list_valid_smape = []
        for city in citys :
            result = joblib.Parallel(n_jobs=n_jobs)(joblib.delayed(main)(\
                city = city, target = target, station = station, dir_feature = dir_feature, dir_result = dir_result, \
                para_create_method = para_create_method, para_training_hour = para_training_hour, para_y_test_end = para_y_test_end, \
                para_nan_method = para_nan_method, para_x_prep_method = para_x_prep_method, para_valid_method = para_valid_method, \
                xg_eta = xg_eta, xg_min_child_weight = xg_min_child_weight, xg_max_depth = xg_max_depth, xg_gamma = xg_gamma, xg_subsample = xg_subsample, xg_colsample_bytree = xg_colsample_bytree, xg_seed = xg_seed, xg_base_score_method = xg_base_score_method, num_boost_round = num_boost_round, early_stopping_round = early_stopping_round, xg_maximize = xg_maximize, xg_verbose_level = xg_verbose_level, \
                is_latest = is_latest, is_novalid = is_novalid) \
                for (target, station) in product(targets[city], stations[city]))
            if not is_novalid :
                list_valid_smape.extend(result)
        if not is_novalid :
            avg = np.nanmean(list_valid_smape)
            sd = np.nanstd(list_valid_smape)

        # submission file
        if is_novalid : 
            new_dir_result = dir_result+"_novalid"
        else :
            new_dir_result = dir_result+"_"+('%03.3f' % avg)+"_"+('%03.3f' % sd)
        os.rename(dir_result, new_dir_result)
        create_submission(new_dir_result, is_submit = is_submit)
        #for (target, station, para_look_back, para_train_start, para_nan_method, para_x_prep_method, para_valid_size, xg_eta, xg_min_child_weight, xg_max_depth, xg_gamma, xg_subsample, xg_colsample_bytree, xg_seed, xg_base_score_method, num_boost_round, early_stopping_round, xg_maximize, xg_verbose_level) in product(targets[city], stations[city], para_look_backs, para_train_starts, para_nan_methods, para_x_prep_methods, para_valid_sizes, xg_etas, xg_min_child_weights, xg_max_depth, xg_gammas, xg_subsamples, xg_colsample_bytrees, xg_seeds, xg_base_score_methods, num_boost_rounds, early_stopping_rounds, xg_maximizes, xg_verbose_levels))
			
# ========================================
# main 
# ========================================
if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--n_jobs', default=1, type=int)
    parser.add_argument('--citys', nargs='+', default = CITYS, choices = ["bei", "lon"])
    parser.add_argument('--targets', nargs='+', default = TARGETS, choices = ["PM2.5", "PM10", "O3"], required = False)
    parser.add_argument('--stations', nargs='+', default = STATIONS, required = False)
    parser.add_argument('--dir_feature', type=str, required = True)
    parser.add_argument('--para_create_method', nargs='+', default = ["m3"], type = str)
    parser.add_argument('--para_training_hours', nargs='+', default = [671], type=int)
    parser.add_argument('--para_y_test_end', type = str)
    parser.add_argument('--para_nan_methods', nargs='+', default = ["m1"], type = str)
    parser.add_argument('--para_x_prep_methods', nargs='+', default = ["m1"], type = str)
    parser.add_argument('--para_valid_methods', nargs='+', default = ["m2"], type = str)
    parser.add_argument('--xg_etas', nargs='+', default = [0.01], type = float) #fix
    parser.add_argument('--xg_min_child_weights', nargs='+', default = [1.0], type = float)
    parser.add_argument('--xg_max_depths', nargs='+', default = [4], type = int) # fix
    parser.add_argument('--xg_gammas', nargs='+', default = [0], type = float)
    parser.add_argument('--xg_subsamples', nargs='+', default = [0.8], type = float) # fix
    parser.add_argument('--xg_colsample_bytrees', nargs='+', default = [0.6], type = float)
    parser.add_argument('--xg_seeds', nargs='+', default = [1234], type=int)
    parser.add_argument('--xg_base_score_methods', nargs='+', default = ["m5"]) #fix
    parser.add_argument('--xg_num_boost_rounds', nargs='+', default = [50], type=int) #fix
    parser.add_argument('--xg_early_stopping_rounds', nargs='+', default = [300], type=int)
    parser.add_argument('--xg_maximizes', nargs='+', default = [True], type=bool) #fix
    parser.add_argument('--xg_verbose_levels', nargs='+', default = [50], type=int)
    parser.add_argument('--is_latest', action = "store_true", default=False)
    parser.add_argument('--is_novalid', action = "store_true", default=False)
    parser.add_argument('--is_submit', action = "store_true", default=False)
    args = parser.parse_args()

    print(' '.join(sys.argv))

    # START
    FILENAME = os.path.basename(__file__)
    UNAME = os.uname()[1]
    TIME_START = datetime.datetime.now().strftime('%Y/%m/%d %H:%M')    

    multi_main(args.n_jobs, args.citys, args.targets, args.stations, args.dir_feature, args.para_create_method, args.para_training_hours, args.para_y_test_end, args.para_nan_methods, args.para_x_prep_methods, args.para_valid_methods, args.xg_etas, args.xg_min_child_weights, args.xg_max_depths, args.xg_gammas, args.xg_subsamples, args.xg_colsample_bytrees, args.xg_seeds, args.xg_base_score_methods, args.xg_num_boost_rounds, args.xg_early_stopping_rounds, args.xg_maximizes, args.xg_verbose_levels, args.is_latest, args.is_novalid, args.is_submit)

    # END
    TIME_END = datetime.datetime.now().strftime('%Y/%m/%d %H:%M')
    notify_slack("@motoyuki "+TIME_START+"-"+TIME_END+" "+UNAME+" "+FILENAME)
