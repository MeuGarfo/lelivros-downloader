#!/bin/bash
# lelivros-downloader.sh
# description:
# script that downloads all e-books from https://lelivros.pro website

FILE_EXTENSION="pdf"
MAIN_URI="https://lelivros.pro"
CATEGORIES=(
"administracao"
"artes"
"autoajuda"
"aventura"
'biografias-e-memorias'
"ciencias"
"concurso-publico"
"contos-e-cronicas"
"cicionarios-e-manuais-convers"
"direito"
"diversos"
"economia"
"ensaios"
"ficção-cientifica"
"ficção-fantastica"
"ficção-supense"
"filosofia"
"geografia-e-historia"
"humor"
"infanto-juvenil"
"linguistica"
"medicina"
"poesia"
"policial"
"psicologia"
"regimes"
"religiao"
"romance"
"teoria-e-critica"
"terror-e-suspense"
"turismo"
)
SCRIPT_DIR=$(pwd)
BOOKS_DIR=$SCRIPT_DIR"/"books
PAGE_URI_FILE="page_temp.txt"
BOOKS_URI_FILE="books_temp.txt"
BOOK_URI_FILE="book_temp.txt"
BOOK_URI_REGEX_PATTERN=$MAIN_URI"/book/[a-zA-Z0-9-]*/"
FILE_LINK="file_links.txt"
FILE_EXTENSION="pdf"
FILE_LINK_REGEX_PATTERN="http://ler-agora.jegueajato.com/.*\."$FILE_EXTENSION

prepare_directories(){
	for category in ${CATEGORIES[@]}
	do
		if [ ! -d $BOOKS_DIR"/"${category} ]
		then
			mkdir -p $BOOKS_DIR"/"${category}
		fi
	done
}

collect_file_links() {
	for category in ${CATEGORIES[@]}
	do
		cd $BOOKS_DIR/${category}

		CATEGORY_URI=$MAIN_URI"/categoria/"$category
		echo $CATEGORY_URI

		i=1
		SUCCESS=0
		while [ $SUCCESS -eq 0 ] 
		do
			PAGE_URI=$CATEGORY_URI"/page/"$i
			echo $PAGE_URI

			wget -q $PAGE_URI --output-document=$PAGE_URI_FILE

			if [ $? -eq 0 ]
			then
				cat $PAGE_URI_FILE | grep -o $BOOK_URI_REGEX_PATTERN | uniq > $BOOKS_URI_FILE
				for BOOK_LINK in $(cat $BOOKS_URI_FILE)
				do
					echo $BOOK_LINK
					wget -q $BOOK_LINK --output-document=$BOOK_URI_FILE
					if [ $? -eq 0 ]
					then
						FILE_LINK_NAME=$(cat $BOOK_URI_FILE | grep -o $FILE_LINK_REGEX_PATTERN | uniq | sed 's/ /%20/g')
						echo $FILE_LINK_NAME
						echo $FILE_LINK_NAME >> $FILE_LINK
					fi
				done
				i=$(expr $i + 1)
			fi
		done
	done
}

download_links(){
	for category in ${CATEGORIES[@]}
	do
		cd $BOOKS_DIR/${category}
		if [ -e $FILE_LINK ]
		then
			for link in $(cat $FILE_LINK)
			do
				FILE_NAME=$(echo $link | sed 's/http:\/\/.*\///g' | sed 's/?chave.*//g')"."$FILE_EXTENSION
				FINAL_FILE_NAME=$(echo $FILE_NAME | sed 's/%20/ /g')
				if [ ! -e "$FINAL_FILE_NAME" ]
				then
					echo Downloading [$link]
					wget -q $link --output-document=$FILE_NAME
					mv "$FILE_NAME" "$FINAL_FILE_NAME"
				else
					echo "File [$FINAL_FILE_NAME] already exist."
				fi
			done		
		fi
	done
}

prepare_directories
#collect_file_links
download_links