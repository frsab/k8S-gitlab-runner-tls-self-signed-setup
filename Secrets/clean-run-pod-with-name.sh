#!/bin/bash

# Vérification du nombre de paramètres
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <param1> <param2>"
  exit 1
fi

# Récupération des paramètres
param1=$1
param2=$2

echo "Paramètre 1: $param1"
echo "Paramètre 2: $param2"
