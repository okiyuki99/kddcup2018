# coding: utf-8
import requests,argparse

def submission_post(submit_filepath, description = "sample submission", filename = "submission.csv"):
    files={'files': open(submit_filepath,'rb')}
    data = {
        "user_id": "MO",
        "team_token": "YOUR TOKEN",
        "description": description,
        "filename": filename,
    }
    url = 'https://biendata.com/competition/kdd_2018_submit/'
    response = requests.post(url, files=files, data=data)
    print(response.text)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--submit_filepath', type=str, required = True)
    parser.add_argument('--description', default='sample submission', type=str)
    parser.add_argument('--filename', default='submission.csv', type=str)
    args = parser.parse_args()
    submission_post(args.submit_filepath, args.description, args.filename)
