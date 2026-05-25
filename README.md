# Service Orders App

Mini projeto de estudo criado para praticar desenvolvimento full stack com Python, FastAPI, SQL e Flutter.

A proposta é simular um sistema corporativo simples de ordens de serviço, com cadastro, listagem, atualização de status e exclusão de registros.

O projeto foi criado como estudo direcionado para uma vaga com foco em Flutter, Python, SQL, APIs REST e sistemas corporativos.

## Status atual do projeto

O projeto possui um backend em FastAPI e uma interface em Flutter Web consumindo a API.

### Backend

- API REST com FastAPI
- CRUD de ordens de serviço
- Validação de dados com Pydantic
- Persistência com SQLAlchemy
- Banco SQLite em arquivo para desenvolvimento local
- Documentação automática via Swagger/OpenAPI

### Flutter

- Listagem de ordens de serviço
- Cadastro de nova ordem
- Atualização de status da ordem
- Consumo de API REST com pacote `http`
- Interface simples usando Material Design

### Fluxo implementado

1. O usuário cria uma ordem de serviço pelo Flutter.
2. O app envia um `POST` para a API.
3. A API valida os dados e salva no banco.
4. O app recarrega a lista.
5. O usuário pode iniciar, concluir ou cancelar a ordem.
6. O app envia um `PUT` para atualizar o status.

## Tecnologias usadas

### Backend

- Python
- FastAPI
- SQLAlchemy
- Pydantic
- SQLite
- Swagger/OpenAPI

### Frontend/Mobile

- Flutter
- Dart
- Material Design
- HTTP package

### Ferramentas

- Git
- GitHub
- VS Code

## Estrutura do projeto

```text
service-order-app/
  backend/
    app/
      main.py
      database.py
      models.py
      schemas.py
      routes.py
    requirements.txt

  mobile/
    service_order_mobile/
      lib/
        main.dart

  README.md