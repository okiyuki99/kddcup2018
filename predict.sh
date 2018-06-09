HOUR=`date +%H`
echo "${HOUR}"
TEST_END=`date -d "2 days" +%Y-%m-%d-23`
RAND=`od -vAn --width=4 -tu4 -N4 </dev/urandom`
RAND2=`od -vAn --width=4 -tu4 -N4 </dev/urandom`
RAND=`expr $RAND % 10000 + 1`
RAND2=`expr $RAND2 % 10000 + 1`

# parameter check
#if [ "${HOUR}" -eq "00"  -o "${HOUR}" -eq "10" ]; then
#  echo "Check traning hours"
#  DATE=`date +%Y-%m-%d`
#  echo "${DATE}"
#  python3 exe_xgboost2.py --n_jobs 6 --dir_feature /mnt/data/kddcup2018/feature_05 --para_training_hours 671 1007 1343 1679 2015 --para_y_test_end ${TEST_END} --xg_etas 0.01 --xg_colsample_bytrees 0.6 --xg_max_depths 4 --xg_num_boost_rounds 200 --xg_early_stopping 300 --xg_seeds "${RAND}" --is_latest
#fi

#if [ "${HOUR}" -eq "02"  -o "${HOUR}" -eq "12" ]; then
#  echo "Check depth trees"
#  DATE=`date +%Y-%m-%d`
#  echo "${DATE}"
#  python3 exe_xgboost2.py --n_jobs 6 --dir_feature /mnt/data/kddcup2018/feature_05 --para_training_hours 1007 --para_y_test_end ${TEST_END} --xg_etas 0.01 --xg_colsample_bytrees 0.6 --xg_max_depths 3 4 5 6 7 --xg_num_boost_rounds 200 --xg_early_stopping 300 --xg_seeds "${RAND}" --is_latest
#fi

#if [ "${HOUR}" -eq "04"  -o "${HOUR}" -eq "14" ]; then
#  echo "Check num boost rounds"
#  DATE=`date +%Y-%m-%d`
#  echo "${DATE}"
#  python3 exe_xgboost2.py --n_jobs 6 --dir_feature /mnt/data/kddcup2018/feature_05 --para_training_hours 1007 --para_y_test_end ${TEST_END} --xg_etas 0.01 --xg_colsample_bytrees 0.6 --xg_max_depths 4 --xg_num_boost 100 150 200 250 300 --xg_early_stopping 300 --xg_seeds "${RAND}" --is_latest
#fi

#if [ "${HOUR}" -eq "06"  -o "${HOUR}" -eq "16" ]; then
#  echo "Check colsample bytrees"
#  DATE=`date +%Y-%m-%d`
#  echo "${DATE}"
#  python3 exe_xgboost2.py --n_jobs 6 --dir_feature /mnt/data/kddcup2018/feature_05 --para_training_hours 1007 --para_y_test_end ${TEST_END} --xg_etas 0.01 --xg_colsample_bytrees 0.5 0.6 0.7 0.8 0.9 --xg_max_depths 4 --xg_num_boost 200 --xg_early_stopping 300 --xg_seeds "${RAND}" --is_latest
#fi

#if [ "${HOUR}" -eq "08" ]; then
#  echo "Check subsamples"
#  DATE=`date +%Y-%m-%d`
#  echo "${DATE}"
#  python3 exe_xgboost2.py --n_jobs 6 --dir_feature /mnt/data/kddcup2018/feature_05 --para_training_hours 1007 --para_y_test_end ${TEST_END} --xg_etas 0.01 --xg_subsamples 0.6 0.7 0.8 0.9 1.0 --xg_colsample_bytrees 0.6 --xg_max_depths 4 --xg_num_boost 200 --xg_early_stopping 300 --xg_seeds "${RAND}" --is_latest
#fi

# ensemble 
PTH=1007
XMD=5
XNBR=250
XCB=0.6
XS=0.9

if [ "${HOUR}" -eq "18" -o "${HOUR}" -eq "19" -o "${HOUR}" -eq "20" -o "${HOUR}" -eq "21" -o "${HOUR}" -eq "22" -o "${HOUR}" -eq "23" ]; then
  DATE=`date +%Y-%m-%d`
  echo "${DATE}"
  python3 exe_xgboost2.py --n_jobs 6 --dir_feature /mnt/data/kddcup2018/feature_05 --para_training_hours ${PTH} --para_y_test_end ${TEST_END} --xg_etas 0.01 --xg_subsamples ${XS} --xg_colsample_bytrees ${XCB} --xg_max_depths ${XMD} --xg_num_boost_rounds ${XNBR} --xg_early_stopping 300 --xg_seeds ${RAND} --is_novalid --is_latest

  if [ "${HOUR}" -eq "20" ]; then
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_a"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-20 /mnt/data/kddcup2018/feature_05/"${DATE}"-19 /mnt/data/kddcup2018/feature_05/"${DATE}"-18 -dir_result ${DIR_RESULT} --method a --is_search
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_g"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-20 /mnt/data/kddcup2018/feature_05/"${DATE}"-19 /mnt/data/kddcup2018/feature_05/"${DATE}"-18 --dir_result ${DIR_RESULT} --method g --is_search
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_w"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-20 /mnt/data/kddcup2018/feature_05/"${DATE}"-19 /mnt/data/kddcup2018/feature_05/"${DATE}"-18 --dir_result ${DIR_RESULT} --method w --weight 0.6 0.2 0.2 --is_search
  fi

  if [ "${HOUR}" -eq "21" ]; then
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_a"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 --dir_result ${DIR_RESULT} --method a --is_search
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_g"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 --dir_result ${DIR_RESULT} --method g --is_search
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_w"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 --dir_result ${DIR_RESULT} --method w --weight 0.7 0.3 --is_search
  fi

  if [ "${HOUR}" -eq "22" ]; then
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_a"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-22 /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 --dir_result ${DIR_RESULT} --method a --is_search
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_g"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-22 /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 --dir_result ${DIR_RESULT} --method g --is_search
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_w"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-22 /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 --dir_result ${DIR_RESULT} --method w --weight 0.5 0.3 0.2 --is_search
  fi

  if [ "${HOUR}" -eq "23" ]; then
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_a"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-23 /mnt/data/kddcup2018/feature_05/"${DATE}"-22 /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 --dir_result ${DIR_RESULT} --method a --is_search

    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_a2"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-23 /mnt/data/kddcup2018/feature_05/"${DATE}"-22 /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 /mnt/data/kddcup2018/feature_05/"${DATE}"-19 /mnt/data/kddcup2018/feature_05/"${DATE}"-18 --dir_result ${DIR_RESULT} --method a --is_search

    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_w"
    python3 create_ensemble.py /mnt/data/kddcup2018/feature_05/"${DATE}"-23 /mnt/data/kddcup2018/feature_05/"${DATE}"-22 /mnt/data/kddcup2018/feature_05/"${DATE}"-21 /mnt/data/kddcup2018/feature_05/"${DATE}"-20 /mnt/data/kddcup2018/feature_05/"${DATE}"-19 /mnt/data/kddcup2018/feature_05/"${DATE}"-18 --dir_result ${DIR_RESULT} --method w --weight 0.4 0.3 0.1 0.1 0.05 0.05 --is_search

    # submit ensemble
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_a"
    python3 api/api_submit.py --submit_filepath ${DIR_RESULT}/submission.csv --description ensemble/${DATE}/ci_${HOUR}_a
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_a2"
    python3 api/api_submit.py --submit_filepath ${DIR_RESULT}/submission.csv --description ensemble/${DATE}/ci_${HOUR}_a2
    DIR_RESULT="/mnt/data/kddcup2018/ensemble/${DATE}/ci_${HOUR}_w"
    python3 api/api_submit.py --submit_filepath ${DIR_RESULT}/submission.csv --description ensemble/${DATE}/ci_${HOUR}_w
  fi
fi
