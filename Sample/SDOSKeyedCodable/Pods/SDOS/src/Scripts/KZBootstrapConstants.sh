#!/bin/bash
export LANG=es_ES.UTF-8

function usage()
{
    echo "Los valores válidos son los siguientes:"
    echo ""
    echo "-o directorio de salida para los ficheros generados"
    echo "-i ruta del fichero para a partir del cual se generarán las constantes"
    echo "-prefix Prefijo de los ficheros generados"
    echo ""
}

#variables por defecto
default_value="##--default_bash_value--##"

output_folder="./App/Others/AutoGenerate/"
input_file="./App/Configuration/Properties/KZBEnvironments.plist"
prefixFileName=""

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
    				output_folder=$2
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
    				input_file=$2
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
          *)
          echo "ERROR: unknown parameter \"$PARAM\""
          usage
          exit 1
          ;;
    esac
done

if [[ $output_folder != */ ]]
then
	aux=$(echo "/")
	output_folder=$output_folder$aux
	aux=
fi
mkdir -p $output_folder

aux=$(echo "${prefixFileName}KZBootstrapConstants.h")
output_interface=$output_folder$aux
aux=$(echo "${prefixFileName}KZBootstrapConstants.m")
output_implementation=$output_folder$aux
aux=

echo '//  FICHERO AUTOGENERADO - NO MODIFICAR' > $output_interface
echo "//  ${prefixFileName}KZBootstrapConstants.h" >> $output_interface
echo '//' >> $output_interface
echo "//  Created by SDOS" >> $output_interface
echo '//' >> $output_interface
echo '' >> $output_interface
echo '@import SDOSKZBootstrap;' >> $output_interface
echo '' >> $output_interface
#----------------

strVariable=$(echo 'cat /plist/dict/key/text()' | xmllint --shell "$input_file" | awk -F'[="]' '!/>/{print $(NF-1)}')
strVariable=$(echo "$strVariable" | sed s/-------/\|\|\|/g)
strVariable=${strVariable// /####}
arrayVariables=(${strVariable//####|||/})

interfaceMethods="@interface ${prefixFileName}KZBootstrapConstants : NSObject"$'\n'$'\n'
implementationMethods="@implementation ${prefixFileName}KZBootstrapConstants"$'\n'$'\n'
for i in ${!arrayVariables[@]}
do
	varNombreReal=${arrayVariables[i]//####/ }
	varNombreConstante=$(echo "${arrayVariables[i]}" | sed s/@2x//g | sed s/-/_/g | sed s/####/_/g | sed s/[:space:]+/_/g)

	if [[ $varNombreConstante == "KZBEnvironments" ]]
	then
	  continue;
	fi
	echo "#define KZ_$varNombreConstante [KZBootstrap envVariableForKey:@\"$varNombreReal\"]" >> $output_interface
  interfaceMethods="$interfaceMethods+ (NSString *) constKZ_$varNombreConstante;"$'\n'
  implementationMethods="$implementationMethods"$'\n'"+ (NSString *) constKZ_$varNombreConstante{"$'\n'""$'\t'"return KZ_$varNombreConstante;"$'\n'"}"$'\n'
done

interfaceMethods="$interfaceMethods"$'\n'"@end"
implementationMethods="$implementationMethods"$'\n'"@end"

echo '' >> $output_interface


echo "$interfaceMethods" >> $output_interface


echo '//  FICHERO AUTOGENERADO - NO MODIFICAR' > $output_implementation
echo "//  ${prefixFileName}KZBootstrapConstants.m" >> $output_implementation
echo '//' >> $output_implementation
echo "//  Created by SDOS" >> $output_implementation
echo '//' >> $output_implementation
echo '' >> $output_implementation

echo "$implementationMethods" >> $output_implementation
#----------------