
if [ -e "bin/dirc" ]
then
	rm -f bin/dirc
fi

gdc -o bin/dirc main.d net.d

bin/dirc server &
bin/dirc client &
wait

