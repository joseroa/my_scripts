#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Uso: $0 bucket_origen directorio_origen directorio_destino"
    exit 1
fi

bucket_origen="$1"
directorio_origen="$2/"
directorio_destino="$3/"

# Obtener la lista de objetos en formato JSON
objetos_json=$(aws s3api list-objects --bucket "$bucket_origen" --prefix "$directorio_origen" --output json)

# Procesar los nombres de archivo y copiarlos al directorio destino
echo "$objetos_json" | jq -r '.Contents[].Key' | while read -r archivo; do
    nombre_archivo=$(basename "$archivo")  # Obtener solo el nombre del archivo
    nuevo_nombre=$(echo "$nombre_archivo" | sed 's/ /_/g')  # Reemplazar espacios por guiones bajos
    aws s3 cp "s3://$bucket_origen/$archivo" "s3://$bucket_origen/$directorio_destino$nuevo_nombre"
done
