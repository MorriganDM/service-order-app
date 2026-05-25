# Service Orders App

Mini projeto de estudo criado para praticar desenvolvimento full stack com Python, FastAPI, PostgreSQL e Flutter.

A proposta é simular um sistema corporativo simples de ordens de serviço, com cadastro, listagem, edição, atualização de status, filtros e exclusão segura de registros.

O projeto foi criado como estudo direcionado para uma vaga com foco em Flutter, Python, SQL, PostgreSQL, APIs REST e sistemas corporativos.

## Status atual do projeto

O projeto possui um backend em FastAPI conectado a PostgreSQL e uma interface em Flutter Web consumindo a API.

### Backend

- API REST com FastAPI
- CRUD de ordens de serviço
- Validação de dados com Pydantic
- Persistência com SQLAlchemy
- Banco PostgreSQL
- Configuração de banco via variável de ambiente
- Registro de data de criação e última edição
- Documentação automática via Swagger/OpenAPI

### Flutter

- Listagem de ordens de serviço
- Filtros por status
- Cadastro de nova ordem
- Edição de ordem existente
- Atualização de status da ordem
- Modal de detalhes
- Exclusão com confirmação
- Exclusão permitida apenas para ordens concluídas ou canceladas
- Consumo de API REST com pacote `http`
- Interface usando Material Design
- Código organizado em `models`, `services`, `pages` e `widgets`

## Fluxo implementado

O sistema permite criar uma ordem de serviço, acompanhar seu status e realizar ações conforme o estado atual do registro.

- Ordens abertas podem ser iniciadas, editadas ou canceladas.
- Ordens em andamento podem ser concluídas, editadas ou canceladas.
- Ordens concluídas ou canceladas podem ser excluídas com confirmação.
- A API registra a data de criação e a última edição da ordem.
- O app Flutter consome a API REST e atualiza a interface após cada operação.

## Tecnologias usadas

### Backend

- Python
- FastAPI
- SQLAlchemy
- Pydantic
- PostgreSQL
- Psycopg
- Python Dotenv
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
- PowerShell

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
    .env.example
    requirements.txt

  mobile/
    service_order_mobile/
      lib/
        main.dart
        models/
          service_order.dart
        services/
          service_orders_api.dart
        pages/
          service_orders_page.dart
        widgets/
          service_order_card.dart
          create_service_order_dialog.dart
          edit_service_order_dialog.dart
          service_order_details_dialog.dart
          status_chip.dart
          priority_chip.dart
          info_text.dart
          detail_row.dart
          label_chip.dart

  docs/
    screenshots/

  README.md
```

## Screenshots

### Flutter Web

Tela principal com listagem, filtros por status, ações condicionais e registro de criação/última edição.

<img src="docs/screenshots/flutter-list.png" alt="Flutter app listando ordens de serviço" width="900">

### Fluxos principais

| Criação de ordem | Edição de ordem |
|---|---|
| <img src="docs/screenshots/create-order.png" alt="Modal de criação de ordem" width="420"> | <img src="docs/screenshots/edit-order.png" alt="Modal de edição de ordem" width="420"> |

| Detalhes da ordem | Exclusão com confirmação |
|---|---|
| <img src="docs/screenshots/details-dialog.png" alt="Modal de detalhes da ordem" width="420"> | <img src="docs/screenshots/delete-confirmation.png" alt="Confirmação de exclusão segura" width="420"> |

### API FastAPI / Swagger

Documentação automática da API com endpoints REST para criação, listagem, busca, atualização e exclusão de ordens de serviço.

<img src="docs/screenshots/swagger.png" alt="Swagger da API FastAPI" width="900">

## Como configurar o banco PostgreSQL

Crie um banco PostgreSQL para o projeto.

Exemplo usando `psql`:

```sql
CREATE USER service_orders_user WITH PASSWORD 'service_orders_password';

CREATE DATABASE service_orders_db OWNER service_orders_user;

GRANT ALL PRIVILEGES ON DATABASE service_orders_db TO service_orders_user;
```

Depois, crie um arquivo `.env` dentro da pasta `backend/`, usando como base o arquivo `.env.example`.

Exemplo:

```env
DATABASE_URL=postgresql+psycopg://service_orders_user:service_orders_password@localhost:5432/service_orders_db
```

> O arquivo `.env` contém configuração local e não deve ser enviado para o GitHub.

## Como rodar o backend

Entre na pasta do backend:

```powershell
cd backend
```

Crie e ative o ambiente virtual:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

Instale as dependências:

```powershell
pip install -r requirements.txt
```

Execute a API:

```powershell
python -m uvicorn app.main:app --reload
```

Acesse a documentação Swagger:

```text
http://127.0.0.1:8000/docs
```

## Como rodar o Flutter Web

Com o backend rodando, abra outro terminal e entre na pasta do app Flutter:

```powershell
cd mobile/service_order_mobile
```

Execute no Chrome:

```powershell
flutter run -d chrome
```

O app Flutter consome a API local em:

```text
http://127.0.0.1:8000/service-orders
```

## Endpoints principais

| Método | Rota | Descrição |
|---|---|---|
| GET | `/service-orders` | Lista todas as ordens de serviço |
| POST | `/service-orders` | Cria uma nova ordem de serviço |
| GET | `/service-orders/{service_order_id}` | Busca uma ordem por ID |
| PUT | `/service-orders/{service_order_id}` | Atualiza dados ou status da ordem |
| DELETE | `/service-orders/{service_order_id}` | Exclui uma ordem de serviço |

## Observações

Este projeto usa PostgreSQL como banco principal e mantém a configuração de conexão fora do código-fonte por meio de variável de ambiente.

O arquivo `.env.example` serve como referência para configuração local, enquanto o arquivo `.env` real deve permanecer fora do versionamento.