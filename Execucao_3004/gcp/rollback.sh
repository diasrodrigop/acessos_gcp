#!/bin/bash

# Nome do arquivo de entrada
arquivo="relatorio-IAM.csv"


echo "Usuario,Role,Ação,Projeto" > rollback.csv

# Loop para ler cada linha do arquivo
while IFS= read -r linha; do
  user=$(echo $linha | cut -d"," -f1)
  role=$(echo $linha | cut -d"," -f2)
  project=$(echo $linha | cut -d"," -f4)

  echo "User: $user"
  echo "Role: $role"
  echo "Project: $project"

  gcloud projects add-iam-policy-binding $project --member=$user --role=$role --no-user-output-enabled

  echo "$user,$role,Rollback de permissão,$project" >> rollback.csv
  echo "===================================================="
done < "$arquivo"
