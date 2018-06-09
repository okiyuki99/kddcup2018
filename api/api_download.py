import os,requests,argparse,datetime

parser = argparse.ArgumentParser()
parser.add_argument('--city', nargs='+', default=["bj", "ld", "bj_grid", "ld_grid"], choices = ["bj", "ld", "bj_grid", "ld_grid"])
parser.add_argument('--data', nargs='+', default=["airquality", "meteorology", "forecast"], choices = ["airquality", "meteorology", "forecast"])
#parser.add_argument('--data', nargs='+', default=["airquality", "meteorology"], choices = ["airquality", "meteorology", "forecast"])
parser.add_argument('--start_time', default='2018-04-01-0', type=str)
parser.add_argument('--end_time', default='2018-04-01-23', type=str)
args = parser.parse_args()

# create dir
input_api = "/mnt/data/kddcup2018/input_api/"+args.start_time+"_"+args.end_time
if not os.path.isdir(input_api) : os.makedirs(input_api, exist_ok = True)

for city in args.city :
    for data in args.data :
        if (city in ["bj","ld"] and data == "airquality") or (city in ["bj", "bj_grid"]  and data == "meteorology") or (city == "ld_grid" and data == "meteorology") :
            url = "https://biendata.com/competition/"+data+"/"+city+"/"+args.start_time+"/"+args.end_time+"/2k0d1d8"
            print("URL:"+url)
            respones= requests.get(url)
            filename = input_api+"/"+city+"_"+data+".csv"
            print(filename)
            with open (filename,'w') as f:
                f.write(respones.text)
        if city in ["bj","ld"] and data == "forecast" :
            end_time_1hour = datetime.datetime.strptime(args.end_time, "%Y-%m-%d-%H") - datetime.timedelta(hours=1)
            end_time_1hour = datetime.datetime.strftime(end_time_1hour, "%Y-%m-%d-%H")
            url = "http://kdd.caiyunapp.com/competition/"+data+"/"+city+"/"+end_time_1hour+"/2k0d1d8"
            print("URL:"+url)
            respones= requests.get(url)
            filename = input_api+"/"+city+"_"+data+".csv"
            print(filename)
            with open (filename,'w') as f:
                f.write(respones.text)
