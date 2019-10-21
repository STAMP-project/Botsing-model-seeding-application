INPUT=inputs.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; }
LIMIT=15

while read application package version crashes
do
	echo "application : $application"
	echo "package : $package"
	echo "version : $version"

  IFS='|' read -ra logs <<< "$crashes"

  for i in "${!logs[@]}"; do
			temp=$(echo "${logs[$i]}" | tr -d '\r')
      logs[$i]=../crashes/$application/$temp/$temp.log
  done

  json_string=$(python python/jj.py "${logs[@]}")

  java -d64 -Xmx10000m -jar botsing-model-generation.jar -projectCP "../bins/$application/$version/bin" -projectPackage "$package" -crashes "$json_string" -outDir "../analysis-result/$application/$application-$version" > "logs/$application-$version-out.txt" 2> "logs/$application-$version-err.txt" &

  while (( $(pgrep -l java | wc -l) >= $LIMIT ))
    do
                sleep 1
    done
done < $INPUT
