exec < neleus-keywords
while read line
do
  echo ~/paracode/third_party/jdk1.6.0_24/bin/java -jar ~/paracode/poseidon/neleus/neleus.jar $@ -k \'$line\'
  ~/paracode/third_party/jdk1.6.0_24/bin/java -jar ~/paracode/poseidon/neleus/neleus.jar $@ -k \'$line\'
  sleep 5
done
