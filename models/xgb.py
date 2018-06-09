import json
import numpy as np
import xgboost as xgb
import matplotlib
try:
    matplotlib.use('Agg')
except Exception:
    raise

def xgb_create_dmatrix(X_train, y_train, X_valid, y_valid, X_test):
    d_train = xgb.DMatrix(X_train, label=y_train, missing = np.nan)
    d_test = xgb.DMatrix(X_test, missing = np.nan)
    if X_valid.shape[0] > 0 :
        d_valid = xgb.DMatrix(X_valid, label=y_valid, missing = np.nan)
    else :
        d_valid = None
    return d_train, d_valid, d_test

def xgb_set_parameter(eta, mcw, md, g, s, c, seed, b, n, e, m, v) :
    xgb_params = {}
    xgb_params["objective"] = 'reg:linear'
    xgb_params["nthread"] = 8
    xgb_params["silent"] = True
    xgb_params["eval_metric"] = 'mae'
    xgb_params["eta"] = eta
    xgb_params["min_child_weight"] = mcw
    xgb_params["max_depth"] = md
    xgb_params["gamma"] = g
    xgb_params["subsample"] = s
    xgb_params["colsample_bytree"] = c
    xgb_params["seed"] = seed
    xgb_params["base_score"] = b
    num_boost_round = n
    early_stopping_rounds = e
    maximize = m
    verbose_eval = v
    return xgb_params, num_boost_round, early_stopping_rounds, maximize, verbose_eval

def xgb_base_score(y, method):
    if method == "m1" :
        return np.mean(y)
    elif method == "m2" :
        return np.median(y)
    elif method == "m3" :
        return np.mean(y[-24:])
    elif method == "m4" :
        return np.median(y[-24:])
    elif method == "m5" :
        return np.median(y[-12:])
    elif method == "m6" :
        return np.median(y[-6:])
    elif method == "m7" :
        return np.median(y[-3:])

def xgb_run(d_train, d_valid, columns, params, num_boost_round, early_stopping_rounds, maximize, verbose_eval):
    if d_valid == None :
        evals = [(d_train, 'train')]
    else :
        evals = [(d_train, 'train'), (d_valid, 'valid')]

    evals_result = {}
    xgb_model = xgb.train(
        params = params, 
        dtrain = d_train,
        num_boost_round =  num_boost_round, 
        evals = evals,
        maximize = maximize,
        early_stopping_rounds = early_stopping_rounds,
        evals_result = evals_result,
        verbose_eval = verbose_eval)
  
    mapper = {'f{0}'.format(i): v for i, v in enumerate(columns)}
    mapped = {mapper[k]: v for k, v in xgb_model.get_fscore().items()}

    return xgb_model, evals_result, mapped

def xgb_save_importance_json(filename, fscore) :
    with open(filename, 'w') as f:
        json.dump(fscore, f, ensure_ascii=False, sort_keys=True)

def xgb_save_importance_png(filename, fscore) :
    ax = xgb.plot_importance(fscore)
    ax.figure.savefig(filename, bbox_inches='tight')

def xgb_save_eval_result(filename, eval_result) :
    with open(filename, 'w') as f:
        json.dump(eval_result, f, ensure_ascii=False, sort_keys=True)
