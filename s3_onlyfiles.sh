#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 bucket_origen directorio_origen"
    exit 1
fi

bucket_origen="$1"
directorio_origen="$2/"

# Obtener la lista de objetos en formato JSON
objetos_json=$(aws s3api list-objects --bucket "$bucket_origen" --prefix "$directorio_origen" --output json)

# Procesar los nombres de archivo y copiar los archivos con espacios
echo "$objetos_json" | jq -r '.Contents[].Key' | while read -r archivo; do
    if [[ "$archivo" == *" "* ]]; then
        nuevo_nombre=$(basename "$archivo" | sed 's/ /_/g')  # Reemplazar espacios por guiones bajos
        aws s3 cp "s3://$bucket_origen/$archivo" "s3://$bucket_origen/$directorio_origen$nuevo_nombre"
    fi
done