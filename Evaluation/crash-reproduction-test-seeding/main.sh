INPUT=inputs.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; }
LIMIT=50

job_list=()
min_prob="0.2"

counter=0
while read execution_idx application case version classpath package stacktrace_path fixed fixed_version buggy_frame p_functional_mocking functional_mocking_percent p_reflection_on_private reflection_start_percent search_budget population p_object_pool p_model_pool_target_init p_model_pool_non_target_init seed_clone seed_mutations test_dir
do
  if [[ "$counter" -eq "0" ]]; then
    counter=1
    continue
  fi

  valid_frames=$(python python/get-valid-frames.py $application $package $case)
  IFS='|' read -ra valid_frames_arr <<< "$valid_frames"

  for frame in "${!valid_frames_arr[@]}"; do
    task_json=$(python python/task_to_string.py $application $version $case ${valid_frames_arr[$frame]} $execution_idx $search_budget $p_object_pool $seed_clone $seed_mutations)
    job_list+=($task_json)
  done
done < $INPUT
echo "The number of tasks is "${#job_list[@]}""
counter=0
for t in ${job_list[@]}; do
  ((counter++))
  application=$(python python/get_from_json.py $t "application")
  version=$(python python/get_from_json.py $t "version")
  case=$(python python/get_from_json.py $t "case")
  frame=$(python python/get_from_json.py $t "frame")
  execution_idx=$(python python/get_from_json.py $t "execution_idx")
  search_budget=$(python python/get_from_json.py $t "search_budget")
  p_object_pool=$(python python/get_from_json.py $t "p_object_pool")
  seed_clone=$(python python/get_from_json.py $t "seed_clone")
  seed_mutations=$(python python/get_from_json.py $t "seed_mutations")
  ## collecting junits
  target_class=$(python python/get_target_class.py $application $case $frame)
  junits=$(python python/collect-junits.py $application $version $target_class)
  if [[ -z "$junits" ]]; then
    if [ "$min_prob" == "$seed_clone" ]; then
      echo "Task#$counter is frame level $frame of issue $case. This crash happened in $application version $version. task configurations -> execution_idx: $execution_idx, search budget: $search_budget"

      ## Start the search process:
      java -d64 -Xmx4000m -jar ../lib/botsing-reproduction.jar -project_cp "../bins/$application/$version/bin/" -crash_log "../crashes/$application/$case/$case.log" -target_frame $frame -Dsearch_budget=$search_budget -Dstopping_condition=MAXFITNESSEVALUATIONS -Dreset_static_fields=FALSE -Dvirtual_fs=TRUE -Dmax_recursion=50 -Dvirtual_net=FALSE -Dreplace_calls=FALSE -Duse_separate_classloader=FALSE -Dtest_dir="results/$case-$seed_clone-$frame-$execution_idx" > "logs/$case-$seed_clone-$frame-$execution_idx-out.txt" 2> "logs/$case-$seed_clone-$frame-$execution_idx-err.txt" &
      pid=$!
      echo $pid
      . parsing.sh $pid $execution_idx $application $case $version $frame $search_budget $p_object_pool $seed_clone $seed_mutations &
      . observer.sh $pid &
    fi

  else
    echo "Task#$counter is frame level $frame of issue $case. This crash happened in $application version $version. task configurations -> execution_idx: $execution_idx, search budget: $search_budget, junits: $junits, p_object_pool: "$p_object_pool", seed_clone: $seed_clone, seed_mutations: $seed_mutations"

    ## Start the search process:
    java -d64 -Xmx4000m -jar ../lib/botsing-reproduction.jar -project_cp "../bins/$application/$version/bin/" -crash_log "../crashes/$application/$case/$case.log" -target_frame $frame -Dsearch_budget=$search_budget -Dstopping_condition=MAXFITNESSEVALUATIONS -Dreset_static_fields=FALSE -Dvirtual_fs=TRUE -Dmax_recursion=50 -Dvirtual_net=FALSE -Dreplace_calls=FALSE -Duse_separate_classloader=FALSE -Dcarve_object_pool=TRUE -Dp_object_pool=$p_object_pool -Dseed_clone=$seed_clone -Dseed_mutations=$seed_mutations -Dselected_junit="$junits" -Dtest_dir="results/$case-$seed_clone-$frame-$execution_idx" > "logs/$case-$seed_clone-$frame-$execution_idx-out.txt" 2> "logs/$case-$seed_clone-$frame-$execution_idx-err.txt" &

    pid=$!
    echo $pid
    . parsing.sh $pid $execution_idx $application $case $version $frame $search_budget $p_object_pool $seed_clone $seed_mutations &
    . observer.sh $pid &
  fi

  while (( $(pgrep -l java | wc -l) >= $LIMIT ))
    do
                sleep 1
    done
done
