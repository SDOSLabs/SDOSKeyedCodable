#!/bin/bash
export LANG=es_ES.UTF-8

export LANG=es_ES.UTF-8

function usage()
{
    echo "Los valores válidos son los siguientes:"
    echo ""
    echo "-o directorio de salida para los ficheros generados"
    echo "-i ruta de la carpeta a partir del cual se generarán las constantes"
    echo "-prefix Prefijo de los ficheros generados"
    echo "--skip-segue-constants Indica si el script no debe generar las constantes de los segues"
    echo ""
}

#variables por defecto
default_value="##--default_bash_value--##"

output_folder_h="./App/Others/AutoGenerate/"
output_folder_m="./App/Others/AutoGenerate/"
output_folder_temp=
input_folder="./App"
prefixFileName=""
skipSegueConstants=false

argumentos=""
for var in "$@"
do
    argumentos=$(echo "$argumentos $var")
done
while [[ $1 == -* ]]; do
    case "$1" in
      	-h|--help|-\?) usage; exit 0;;
     	-o) if (($# > 1)); then
			if [ $2 != $default_value ]
			then
            	output_folder_h=$2
            	output_folder_m=$2
			fi
			shift 2
          else 
            echo "-o requires an argument" 1>&2
            usage
            exit 1
          fi ;;
    	-i) if (($# > 1)); then
			if [ $2 != $default_value ]
			then
				input_folder=$2;
			fi
			shift 2
          else 
            echo "-i requires an argument" 1>&2
            usage
            exit 1
          fi ;;
      	-prefix) if (($# > 1)); then
			if [ $2 != $default_value ]
			then
				prefixFileName=$2;
			fi
			shift 2
          else 
            echo "-prefix requires an argument" 1>&2
            usage
            exit 1
          fi ;;
          --skip-segue-constants) 
			skipSegueConstants=true	
			shift 1 
			;;
       *)
        echo "ERROR: unknown parameter \"$PARAM\""
        usage
        exit 1
        ;;
    esac
done

if [[ $output_folder_h != */ ]]
then
	aux=$(echo "/")
	output_folder_h=$output_folder_h$aux
	aux=
fi
mkdir -p $output_folder_h

output_folder_temp=$output_folder_h
aux=$(echo "tmp")
output_folder_temp=$output_folder_temp$aux
aux=
mkdir -p $output_folder_temp

aux=$(echo "${prefixFileName}StoryboardConstants.h")
output_folder_h=$output_folder_h$aux
aux=

if [[ $output_folder_m != */ ]]
then
	aux=$(echo "/")
	output_folder_m=$output_folder_m$aux
	aux=
fi
mkdir -p $output_folder_m

aux=$(echo "${prefixFileName}StoryboardConstants.m")
output_folder_m=$output_folder_m$aux
aux=

if [[ $input_folder != */ ]]
then
	aux=$(echo "/")
	input_folder=$input_folder$aux
	aux=
fi

echo '//  FICHERO AUTOGENERADO - NO MODIFICAR' > $output_folder_h
echo "//  ${prefixFileName}StoryboardConstants.h" >> $output_folder_h
echo '//' >> $output_folder_h
echo "//  Created by SDOS" >> $output_folder_h
echo '//' >> $output_folder_h
echo '' >> $output_folder_h
echo '#import <Foundation/Foundation.h>' >> $output_folder_h
echo '' >> $output_folder_h

echo '//  FICHERO AUTOGENERADO - NO MODIFICAR' > $output_folder_m
echo "//  ${prefixFileName}StoryboardConstants.m" >> $output_folder_m
echo '//' >> $output_folder_m
echo "//  Created by SDOS" >> $output_folder_m
echo '//' >> $output_folder_m
echo '' >> $output_folder_m
echo '#import <Foundation/Foundation.h>' >> $output_folder_m
echo '#import <UIKit/UIKit.h>' >> $output_folder_m
echo '' >> $output_folder_m


DIR="${BASH_SOURCE%/*}"
arguments=""
for i in $(find $input_folder -name "*.storyboard")
do
	if [[ $i == *"/Pods/"* ]]
	then
	  continue;
	fi
	nombreSB=$(echo "$i" | rev | cut -d'/' -f 1 | cut -d'.' -f 2 | rev)
	echo "extern NSString * const SBName$nombreSB;" >> $output_folder_h
	echo '' >> $output_folder_h
	echo "NSString * const SBName$nombreSB = @\"$nombreSB\";" >> $output_folder_m
	echo '' >> $output_folder_m

	if [ $skipSegueConstants == false ]
	then
	  "${DIR}/seguecode" -o $output_folder_temp -s $i
	fi
done

aux=$(echo "/StoryboardConstantes.h")
output_folder_temp_file=$output_folder_temp$aux
aux=

/usr/local/bin/sbconstants $output_folder_temp_file -s $input_folder

for i in $(find $output_folder_temp -name "*.h")
do
	if [[ $i == *"/Pods/"* ]]
	then
	  continue;
	fi
	nombreSB=$(echo "$i" | rev | cut -d'/' -f 1 | cut -d'.' -f 2 | rev)
	cat "$i" >> $output_folder_h
	echo '' >> $output_folder_h
done

for i in $(find $output_folder_temp -name "*.m")
do
	if [[ $i == *"/Pods/"* ]]
	then
	  continue;
	fi
	nombreSB=$(echo "$i" | rev | cut -d'/' -f 1 | cut -d'.' -f 2 | rev)
	cat "$i" | sed '/^#import/ d' >> $output_folder_m
	echo '' >> $output_folder_m
done

rm -rf $output_folder_temp