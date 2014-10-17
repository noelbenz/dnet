
if [ -e "bin/dirc" ]
then
	rm -f bin/dirc
fi

gdc -o bin/dirc main.d

bin/dirc

