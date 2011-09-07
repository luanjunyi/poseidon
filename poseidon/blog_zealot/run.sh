exec < "zealot-keywords"


while read line
do
  exec 3< "fingerprints"
  while read fp <&3
  do
      if [ -n "$line" -a -n "$fp" ]; then
          echo python2.6 ~/paracode/poseidon/blog_zealot/blog_zealot.py $@ -k \'$line\' -f \'$fp\'
          python2.6 ~/paracode/poseidon/blog_zealot/blog_zealot.py "$@" -k "$line" -f "$fp"
          sleep 5
      fi
  done
done
