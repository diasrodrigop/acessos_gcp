## Script de Gerenciamento de Permissões de Projetos - IAM

Este script é utilizado para gerenciar as permissões de usuários em projetos do Google Cloud Platform (GCP) usando o Identity and Access Management (IAM). A principal funcionalidade deste script é manter os usuários com as roles necessárias previamente fornecidas, removendo quaisquer permissões setadas manualmente na GCP.

### Requisitos

- É necessário ter o SDK do Google Cloud Platform (`gcloud`) instalado e configurado corretamente.
- Os arquivos de entrada devem estar no formato adequado:
  - `projetos.txt`: arquivo contendo a lista de projetos do GCP, um por linha.
  - `usuarios_permitidos.txt`: arquivo contendo a lista de usuários permitidos, um por linha e mantendo o padrão *"user:nomedouser@dominio.com.br"* ou *"group:nomedogrupo@dominio.com.br"*.
  - `data.json`: arquivo contendo as roles e projetos atribuídas a cada usuário para reajuste dos acessos no seguinte padrão:
    ```
    [
      {
        "user":"usuario@dominio.com.br",
        "roles":"roles/role.nova1,roles/role.nova2",
        "projetos":"project-id-1,project-id-2"
      },
      {
        "user":"usuario2@dominio.com.br",
        "roles":"roles/role.nova3,roles/role.nova4",
        "projetos":"project-id-3,project-id-4"
      }
    ]
    ```
  *Obs.: As roles devem seguir o padrão da GCP, você pode consultar [aqui](https://cloud.google.com/iam/docs/understanding-roles) a sintaxe correta a ser utilizada.*

- Certifique-se de ter permissões suficientes para gerenciar as permissões dos projetos.

### Como usar o script

1. Faça o download do script `gcp.sh` para o seu sistema.

2. Certifique-se de ter os arquivos de entrada `projetos.txt`, `usuarios_permitidos.txt` e `data.json` preparados corretamente.

3. Abra um terminal e navegue até o diretório onde o script `gcp.sh` foi salvo.

4. Execute o seguinte comando para dar permissão de execução ao script:
  ```chmod +x gcp.sh``` 

5. Agora você pode executar o script com os seguintes comandos:

- Para executar o script no modo de simulação `(DRY-RUN)`, ou seja, apenas exibindo as ações sem fazer alterações reais nos projetos:
  ```
  ./gcp.sh --dry-run
  ```

- Para executar o script realizando as alterações reais nos projetos:
  ```
  ./gcp.sh
  ```

6. O script iniciará a verificação e gerenciamento das permissões de usuários nos projetos, exibindo as ações realizadas ou que seriam realizadas no modo de simulação `(DRY-RUN)`. Além disso, ele gerará um arquivo de relatório chamado `relatorio-IAM.csv`, contendo um registro das ações executadas.

### Observações

- Certifique-se de fornecer os arquivos de entrada `projetos.txt`, `usuarios_permitidos.txt` e `data.json` corretamente, seguindo o formato adequado.
- O script usará o SDK do Google Cloud Platform (`gcloud`) para gerenciar as permissões dos projetos. Certifique-se de ter o SDK instalado e configurado corretamente.
- É importante revisar o arquivo de relatório `relatorio-IAM.csv` para verificar as ações executadas pelo script e suas respectivas informações.

### Atenção

- Use este script com cuidado e verifique sempre as ações que serão realizadas antes de executá-lo.
- Certifique-se de ter as permissões necessárias para gerenciar as permissões dos projetos do GCP.
- Este script é fornecido como exemplo e pode ser adaptado ou estendido de acordo com as necessidades específicas do seu ambiente.

### Rollback de permissões

Caso seja necessário alterar as permissões de volta para o valor anterior, basta filtrar o usuário e projeto na planilha importada no Google Sheets, que a role que estava configurada anteriormente será exibida. Após coletar a role, basta adicionar novamente via Console da GCP, ou rodar o comando abaixo:

```
gcloud projects add-iam-policy-binding NOME-DO-PROJETO-brlm --member="user:usuario@leroymerlin.com.br" --role="roles/role.antiga" 
``` 