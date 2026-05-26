# Service Orders App

Mini projeto de estudo criado para praticar desenvolvimento full stack com Python, FastAPI, PostgreSQL e Flutter.

A proposta é simular um sistema corporativo simples de ordens de serviço, com cadastro, listagem, edição, atualização de status, filtros e exclusão segura de registros.

O projeto foi criado como estudo direcionado para uma vaga com foco em Flutter, Python, SQL, PostgreSQL, APIs REST e sistemas corporativos.

## Status atual do projeto

O projeto possui um backend em FastAPI conectado a PostgreSQL e uma interface em Flutter Web consumindo a API.

O backend também pode ser executado com Docker Compose, subindo automaticamente a API e um banco PostgreSQL em containers.

### Backend

- API REST com FastAPI
- CRUD de ordens de serviço
- Validação de dados com Pydantic
- Persistência com SQLAlchemy
- Banco PostgreSQL
- Configuração de banco via variável de ambiente
- Registro de data de criação e última edição
- Documentação automática via Swagger/OpenAPI
- Execução opcional com Docker Compose

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
- Docker
- Docker Compose

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
    Dockerfile
    .dockerignore
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

  docker-compose.yml
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

## Como rodar o backend manualmente

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

## Como rodar com Docker

O backend também pode ser executado com Docker Compose, subindo automaticamente a API FastAPI e um banco PostgreSQL em containers.

Essa opção evita a necessidade de configurar manualmente o PostgreSQL local para testar o projeto.

### Pré-requisitos

- Docker Desktop instalado
- Docker Compose disponível
- Docker Desktop em execução

Verifique a instalação:

```powershell
docker --version
docker compose version
```

### Subir API + PostgreSQL

Na raiz do projeto, execute:

```powershell
docker compose up --build
```

Isso irá:

- baixar a imagem do PostgreSQL;
- construir a imagem da API FastAPI;
- criar um volume para persistir os dados do banco;
- expor a API em `http://127.0.0.1:8000`;
- expor o PostgreSQL do container na porta local `5433`.

A documentação Swagger ficará disponível em:

```text
http://127.0.0.1:8000/docs
```

### Portas usadas

| Serviço | Porta local | Porta no container |
|---|---:|---:|
| FastAPI | 8000 | 8000 |
| PostgreSQL Docker | 5433 | 5432 |

> A porta `5433` foi usada para o PostgreSQL do Docker para evitar conflito com uma instalação local do PostgreSQL usando a porta padrão `5432`.

### Testar a API

Com os containers rodando, é possível testar:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/service-orders
```

Se o banco estiver vazio, o retorno esperado é:

```json
[]
```

### Parar os containers

```powershell
docker compose down
```

### Parar e apagar os dados do banco Docker

```powershell
docker compose down -v
```

> Use `-v` com cuidado, pois ele remove o volume do PostgreSQL e apaga os dados salvos no banco Docker.

### Ver containers ativos

```powershell
docker compose ps
```

### Ver logs da API

```powershell
docker compose logs api
```

### Observação sobre o banco

O banco usado pelo Docker é separado do PostgreSQL local. Portanto, dados criados no PostgreSQL local não aparecem automaticamente no banco Docker, e vice-versa.

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

## Como testar no Android via USB

Também é possível testar o app em um dispositivo Android físico usando Flutter e ADB.

### Pré-requisitos

- Android Studio instalado
- Android SDK configurado
- Dispositivo Android com modo desenvolvedor ativado
- Depuração USB ativada
- Celular conectado ao PC via USB

Verifique se o Flutter reconhece o dispositivo:

```powershell
flutter devices
```

### Rodar o backend

Em um terminal, execute a API manualmente:

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --reload
```

Ou, se estiver usando Docker:

```powershell
docker compose up
```

A API deve estar disponível em:

```text
http://127.0.0.1:8000
```

### Encaminhar a porta da API para o celular

Como o app usa `http://127.0.0.1:8000`, no Android físico é necessário usar `adb reverse` para redirecionar a porta do celular para a API local do computador.

```powershell
adb reverse tcp:8000 tcp:8000
```

Se o `adb` não estiver no PATH, use o caminho completo do SDK:

```powershell
F:\DevTools\Android\Sdk\platform-tools\adb.exe reverse tcp:8000 tcp:8000
```

Para conferir:

```powershell
adb reverse --list
```

Depois, no navegador do celular, é possível testar:

```text
http://127.0.0.1:8000/docs
```

Se o Swagger abrir no celular, a ponte USB está funcionando.

### Rodar o app no celular

Em outro terminal:

```powershell
cd mobile/service_order_mobile
flutter run
```

O app será instalado em modo debug no dispositivo Android conectado.

> Observação: o `adb reverse` funciona para testes via USB. Para distribuir um APK independente, seria necessário apontar o app para uma API acessível pela rede ou por um servidor publicado.

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
