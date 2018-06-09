import os,sys,datetime,argparse
import numpy as np
import pandas as pd
from scipy.stats.mstats import gmean

def main(inputs, dir_result, method, **kg) :
    # create dir_result
    print(dir_result)
    if not os.path.isdir(dir_result) :
        os.makedirs(dir_result, exist_ok = True)
        os.chmod(dir_result, 0o770)

    # save command
    with open(os.path.join(dir_result, 'command.txt'), 'w') as f:
        f.write(' '.join(sys.argv))
        os.chmod(dir_result+"/command.txt", 0o770)

    # Read data from submission files
    df_target1 = None
    df_target2 = None
    df_target3 = None
    ind = "test_id"

    for result in inputs :
        filename = result+"/submission.csv"
        print('Read from {}'.format(result))
        df = pd.read_csv(filename)
        print(df.head(3))
    
        df = df.set_index(ind)
    
        if df_target1 is None:
            df_target1 = df[["PM2.5"]]
        else :
            df_target1 = pd.concat([df_target1, df[["PM2.5"]]], axis=1, join='inner')
    
        if df_target2 is None:
            df_target2 = df[["PM10"]]
        else :
            df_target2 = pd.concat([df_target2, df[["PM10"]]], axis=1, join='inner')
    
        if df_target3 is None:
            df_target3 = df[["O3"]]
        else :
            df_target3 = pd.concat([df_target3, df[["O3"]]], axis=1, join='inner')

    # Calculate the mean
    if method in ['a', 'arithmetic']:
        print('Calculate the Arithmetic mean')
        df_target1 = df_target1.mean(axis=1)
        df_target2 = df_target2.mean(axis=1)
        df_target3 = df_target3.mean(axis=1)
        df_submit = pd.concat([df_target1, df_target2, df_target3], axis=1, join='inner')
        df_submit.columns = ["PM2.5","PM10","O3"]
        df_submit = df_submit.reset_index()
    elif method in ['g', 'geometric']:
        print('Calculate the Geometric mean')
        df_submit = pd.DataFrame({'test_id' : df_target1.index, 'PM2.5' : gmean(df_target1, axis=1), 'PM10' : gmean(df_target2, axis=1), 'O3' : gmean(df_target3, axis=1)})
        df_submit = df_submit[["test_id", "PM2.5", "PM10", "O3"]] 
    elif method in ['w', 'weighted']:
        print('Calculate the Weighted arithmetic mean')
        if len(inputs) != len(kg["weight"]):
            raise ValueError('# of args.input is not equal to # of args.weight')
        weight = np.array(kg["weight"]) / sum(kg["weight"])
        df_target1 = (df_target1 * weight).sum(axis = 1)
        df_target2 = (df_target2 * weight).sum(axis = 1)
        df_target3 = (df_target3 * weight).sum(axis = 1)
        df_submit = pd.concat([df_target1, df_target2, df_target3], axis=1, join='inner')
        df_submit.columns = ["PM2.5","PM10","O3"]
        df_submit = df_submit.reset_index()
    else:
        raise

    # Create ensembled submission file
    pd.DataFrame.to_csv(df_submit, dir_result+"/submission.csv", index=False, header=True, encoding='utf-8')   
    os.chmod(dir_result+"/submission.csv", 0o770)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('inputs', nargs='+')
    parser.add_argument('--dir_result')
    parser.add_argument('--method', '-m', default='arithmetic',
                        choices=['a', 'g', 'w', 'arithmetic', 'geometric', 'weighted'])
    parser.add_argument('--weight', '-w', nargs='+', type=float)
    parser.add_argument('--is_search', action = "store_true", default=False)
    args = parser.parse_args()

    # set dir_result
    if args.dir_result == None:
        dir_result = "/mnt/data/kddcup2018/ensemble/"+datetime.datetime.now().strftime('%Y-%m-%d')+"/"+datetime.datetime.now().strftime('%H%M%S')
    else :
        dir_result = args.dir_result

    # set inputs
    if args.is_search :
        inputs = []
        for path in args.inputs :
            files = os.listdir(path)
            files_dir = [f for f in files if os.path.isdir(os.path.join(path, f))]
            inputs_dir = [os.path.join(path, f) for f in files_dir]
            inputs.extend(inputs_dir)
    else :
        inputs = args.inputs

    # start main
    if args.method in ['w', 'weighted'] :
        print("inputs:", inputs)
        print("weight", args.weight)
        main(inputs, dir_result, args.method, weight = args.weight)
    else :
        print("inputs:", inputs)
        main(inputs, dir_result, args.method)
