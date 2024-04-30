#!/bin/bash

# Arquivo contendo a lista de projetos
projetos="projetos.txt"

# Arquivo contendo a lista de usuários permitidos
usuarios_permitidos="usuarios_permitidos.txt"

# Arquivo contendo a lista de usuários a serem removidos
usuarios_removidos="usuarios_removidos.txt"

# Minha org
dominio="leroymerlin.com.br"

# Arquivo de relatório
relatorio="relatorio-IAM.csv"

# Definir a variável dry_run como false por padrão
dry_run=false

json_path="data.json"
total_usuarios=$(jq length $json_path)
qtd_usuarios=0

# Verifica se o parâmetro --dry-run foi fornecido
if [[ $* == *--dry-run* ]]; then
  dry_run=true
fi

# Função para alterar a permissão do usuário para Viewer no projeto
function remover_permissoes_usuario() {
  local projeto=$1
  local usuario=$2
  
  user_name=$(echo $usuario | cut -d',' -f1)
  user_role=$(echo $usuario | cut -d',' -f2)

  exibir_acao "Removendo permissões do $usuario no projeto $projeto"

  if "$dry_run"; then
    echo "$usuario,(DRY-RUN) Permissões removidas,$projeto" >> "$relatorio"
  else
    # Adicione aqui a lógica para alterar a permissão do usuário para Viewer no projeto
    gcloud projects remove-iam-policy-binding "$projeto" --member="$user_name" --role="$user_role" --condition=None --no-user-output-enabled
    echo "$usuario,Permissões removidas,$projeto" >> "$relatorio"
  fi
}

function set_roles() {
  if "$dry_run"; then
    projects=()
    while IFS= read -r line; do
      projects+=("$line")
    done < "projetos.txt"

    for project in "${projects[@]}"; do
      users=$(jq --arg project "$project" '.[$project] // empty | .[]' "$json_path" -c)

      if [ "$users" != "null" ]; then # Iterate through users
        while read -r user; do
          roles=$(echo "$user" | jq -r '.roles | split(",")[]')
          usermail=$(echo "$user" | jq -r .user)
          for role in $roles; do
            exibir_acao "(DRY-RUN) Permissões do usuário $usermail atualizadas para $role no projeto $project"
            echo "user:$usermail,$role,(DRY-RUN) Permissões atualizadas,$project"  >> "$relatorio"
          done
        done <<< "$users"
      else
        echo "(DRY-RUN) No users found for project $project."
      fi
    done
  else
    projects=()
    while IFS= read -r line; do
      projects+=("$line")
    done < "projetos.txt"

    for project in "${projects[@]}"; do
      users=$(jq --arg project "$project" '.[$project] // empty | .[]' "$json_path" -c)

      if [ "$users" != "null" ]; then # Iterate through users
        while read -r user; do
          roles=$(echo "$user" | jq -r '.roles | split(",")[]')
          usermail=$(echo "$user" | jq -r .user)
          for role in $roles; do
            gcloud projects add-iam-policy-binding "$project" --member="user:$usermail" --role="$role" --condition=None --no-user-output-enabled
            echo "user:$usermail,$role,Permissões atualizadas,$project"  >> "$relatorio"
          done
        done <<< "$users"
      else
        echo "No users found for project $project."
      fi
    done
  fi
}

# Limpar o relatório no início de cada execução
echo "Usuário,Role,Ação,Projeto" > "$relatorio"

# Função para exibir ação com a marca "(DRY-RUN)"
function exibir_acao() {
  local acao=$1
  if "$dry_run"; then
    echo "(DRY-RUN) $acao"
  else
    echo "$acao"
  fi
}

#Loop para percorrer a lista de projetos
while read -r projeto; do
  echo -e "\nAnalisando projeto: $projeto\n"
  
  # Obtém a lista de usuários no projeto
  usuarios=$(gcloud projects get-iam-policy "$projeto" --flatten="bindings[].members" --format="csv(bindings.members,bindings.role)" | grep "$dominio")

  # Loop para percorrer a lista de usuários
  while IFS= read -r usuario; do
    # Verifica se o usuário está na lista de usuários permitidos
    permitido=false
    removido=false

    if grep -q $(echo ${usuario} | cut -d',' -f1) "$usuarios_permitidos"; then
      permitido=true
    fi

    if grep -q $(echo ${usuario} | cut -d',' -f1) "$usuarios_removidos"; then
      removido=true
    fi

    if "$permitido"; then
      exibir_acao "Usuário $usuario é permitido no projeto $projeto"
      echo "$usuario,Nenhuma ação realizada,$projeto" >> "$relatorio"
    else
      remover_permissoes_usuario "$projeto" "$usuario"
    fi
  done <<< "$usuarios"
done < "$projetos"

set_roles