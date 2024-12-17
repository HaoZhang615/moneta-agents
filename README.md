# Moneta - an AI-Agentic Assistant for Insurance and Banking

Moneta is an AI-powered assistant designed to empower insurance and banking advisors. This Solution Accelerator provides a chat interface where advisors can interact with various AI agents specialized in different domains such as insurance policies, CRM, product information, funds, CIO insights, and news.

You can choose chich Agentic orchestration framework the Solution uses behind the scene by setting the approriate env variable. Choose from: 
* [Semantic Kernel](https://learn.microsoft.com/en-us/semantic-kernel/overview/) 
* [Microsoft GBB AI EMEA - Vanilla Agents](https://github.com/Azure-Samples/genai-vanilla-agents) 

## Prerequisites

* Docker
* uv

## Features

- Agentic framework selection Support: Switch between Semantic Kernel and experimental MSFT GBB Vanilla Agents
- Multi-Use Case Support: Switch between insurance and banking use cases
- Agent Collaboration: Agents collaborate to provide the best answers
- Azure AD Authentication: Secure login with Microsoft Azure Active Directory
- Conversation History: Access and continue previous conversations

## Implementation Details
- Python 3.12 or higher
- Streamlit (frontend app - chatGPT style)
- Microsoft Authentication Library (MSAL - if using authentication - optional)
- Azure AD application registration (if using authentication - optional)
- An Azure Container App hosting backend API endpoint
- CosmosDB to store user conversations and history

## Use Cases

### Insurance (SK)

- `CRM`: simulate fetching clients information from a CRM (DB, third-party API etc)
- `Policies RAG`: vector search with AI Search on various public available policy documents (product information)
- `Responder`: collects previous agents replies and respond to the user

### Banking (SK)

- `CRM`: simulate fetching clients information from a CRM (DB, third-party API etc)
- `Funds and ETF RAG`: vector search with AI Search on few funds and ETF factsheets (product information)
- `CIO`: vector search with AI Search on in-house investments view and recommendations
- `News`: RSS online feed search on stock news
- `Responder`: collects previous agents replies and respond to the user

Note: GBB Vanilla agents are similar but differs a bit (no responder agent)

## Project structure

- src
  - backend
    - gbb
      - agents
        - fsi_banking # agents files
        - fsi_insurance # agents files
      - genai_vanilla_agents # the framework source
    - sk
      - agents
        - banking # agents files
        - insurance # agents files
      - orchestrators
      - skills
    - app.py # esposes API

- frontend
  - app.py # streamlit app

- infra
  - bicep file
  - infra modules


### Azure deployment (automated)

To configure, follow these steps:

1. Make sure you AZ CLI is logged in in the right tenant. Optionally:

    ```shell
    az login --tenant your_tenant.onmicrosoft.com
    ```

1. Create a new azd environment:

    ```shell
    azd env new
    ```

    This will create a folder under `.azure/` in your project to store the configuration for this deployment. You may have multiple azd environments if desired.

1. Set the `AZURE_AUTH_TENANT_ID` azd environment variable to the tenant ID you want to use for Entra authentication:

    ```shell
    azd env set AZURE_AUTH_TENANT_ID $(az account show --query tenantId -o tsv)
    ```

1. Login to the azd CLI with the Entra tenant ID:

    ```shell
    azd auth login --tenant-id $(azd env get-value AZURE_AUTH_TENANT_ID)
    ```

1. Proceed with AZD deployment:

    ```shell
    azd up
    ```

### Data indexing 
You can index your data located under the data folder by executing first the `data_upload.py` and then `data_indexing.py`:
```bash
python3 ./scripts/data_upload.py
python3 ./scripts/data_indexing.py
```
Each subfolder of the data folder will be a seperate index. 
If you are using managed identity make sure to assign the following roles to the AI Search: Cognitive Service OpenAI user, Storage Blob Data Reader.
Assign the following roles to the user (yourself): Cognitive Service OpenAI user, Storage Blob Data Contributor, Search Service Data Contributor and Search Service Contributor. 

### Docker deployment (local) - backend

The python project is managed by pyproject.toml and [uv package manager](https://docs.astral.sh/uv/getting-started/installation/).
Install uv prior executing.

To run locally:

mind the env.sample file

```shell
cd src/backend
uv sync
./.venv/bin/python app.py
```

### Docker deployment (local) - frontend

- create a .env file following the env.sample in the project frontend directory and set the following environment variables: 

Mandatory variables (use `DISABLE_LOGIN=True` for local dev and to bypass MSAL auth):
```
DISABLE_LOGIN=<Set to `True` to disable login>
```

For enabling auth you need to have an app registration:
```
AZ_REG_APP_CLIENT_ID=<Your Azure Registered App Client ID>
AZ_TENANT_ID=<Your Azure Tenant ID>
WEB_REDIRECT_URI=<Your Redirect URI>
```

### Running the App (local)

The python project is managed by pyproject.toml and [uv package manager](https://docs.astral.sh/uv/getting-started/installation/).
Install uv prior executing.

To run locally:

mind the env.sample file

```shell
cd src/frontend
uv sync
streamlit run app.py
```

Note: the web app is deployed with DISABLE_LOGIN=true configuration bypassing MSAL

### Usage

1. **Login**: Click on "Log in with Microsoft" to authenticate via Azure AD (automatically skipped if `DISABLE_LOGIN=True`)
2. **Select Use Case**: Choose between `fsi_insurance` and `fsi_banking` from the sidebar
3. **Start a Conversation**: Click "Start New Conversation" or select an existing one
4. **Chat**: Use the chat input to ask questions. Predefined questions are available in a dropdown
5. **Agents Online**: View the available agents for the selected use case
6. **Chat Histories**: View and reload your past conversations
