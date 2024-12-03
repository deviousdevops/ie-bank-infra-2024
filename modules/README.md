# Azure Infrastructure Bicep Modules

This repository contains a set of Bicep files that automate the deployment of various Azure resources. Each Bicep module is designed to deploy a specific set of resources with configurable parameters. Below is a description of each module, along with the parameters used.

## Table of Contents
- [postgresql-server.bicep](#postgresql-serverbicep)
- [key-vault.bicep](#key-vaultbicep)
- [log-analytics.bicep](#log-analyticsbicep)
- [static-web-app.bicep](#static-web-appbicep)
- [app-insights.bicep](#app-insightsbicep)
- [app-service.bicep](#app-servicebicep)
- [container-registry.bicep](#container-registrybicep)
- [storage.bicep](#storagebicep)

---

## postgresql-server.bicep

### Function:
This Bicep file automates the deployment of a PostgreSQL Flexible Server on Azure. It configures firewall rules, admin settings, diagnostic settings, and alerting for failed connections to the PostgreSQL server.

### Parameters:
- `location` (string): The Azure region where the PostgreSQL server will be deployed.
- `serverName` (string): The name of the PostgreSQL server.
- `databaseName` (string): The name of the PostgreSQL database.
- `postgreSQLAdminServicePrincipalObjectId` (string): The object ID of the service principal that will have admin access to the PostgreSQL server.
- `postgreSQLAdminServicePrincipalName` (string): The name of the service principal that will have admin access.
- `workspaceResourceId` (string): The resource ID of the Log Analytics workspace for diagnostic settings.

### Resources Deployed:
- PostgreSQL Flexible Server
- Firewall rule to allow all Azure services
- Service Principal as PostgreSQL Administrator
- Diagnostic settings for PostgreSQL
- Alert for failed connections

---

## key-vault.bicep

### Function:
This Bicep file automates the creation of an Azure Key Vault. It stores sensitive information, such as admin passwords and container registry credentials, and configures access policies for Azure services like GitHub Actions. It also configures diagnostic settings for the Key Vault.

### Parameters:
- `location` (string): The Azure region where the Key Vault will be deployed.
- `name` (string): The name of the Key Vault.
- `adminPassword` (secure string): The admin password that will be stored in the Key Vault.
- `registryName` (string): The name of the container registry, for storing credentials.
- `objectId` (string): The object ID of the user or service principal that will have access to the Key Vault.
- `githubActionsPrincipalId` (string): The principal ID for the GitHub Actions service principal.
- `workspaceResourceId` (string): The resource ID of the Log Analytics workspace for diagnostic settings.

### Resources Deployed:
- Azure Key Vault
- Secrets (Admin password, registry credentials)
- Role assignment for GitHub Actions to access Key Vault secrets
- Diagnostic settings for Key Vault

---

## log-analytics.bicep

### Function:
This Bicep file deploys a Log Analytics workspace in Azure. It configures retention days for logs based on the environment type (production or non-production).

### Parameters:
- `location` (string): The Azure region where the Log Analytics workspace will be deployed.
- `name` (string): The name of the Log Analytics workspace.
- `environmentType` (string): The environment type, either 'prod' or 'nonprod'. This influences the log retention days.
- `retentionDays` (int): The retention days for logs (90 for production, 30 for non-production).

### Resources Deployed:
- Log Analytics Workspace with configurable retention days

---

## static-web-app.bicep

### Function:
This Bicep file automates the deployment of an Azure Static Web App. It configures the SKU (pricing tier) based on the environment type (production or non-production) and connects it to a repository.

### Parameters:
- `location` (string): The Azure region where the Static Web App will be deployed.
- `name` (string): The name of the Static Web App.
- `environmentType` (string): The environment type, either 'prod' or 'nonprod'. This determines the SKU.
- `sku` (string): The SKU of the Static Web App (either 'Standard' for production or 'Free' for non-production).
- `repositoryToken` (string): The token for connecting the Static Web App to the source repository.

### Resources Deployed:
- Azure Static Web App

---

## app-insights.bicep

### Function:
This Bicep file deploys Application Insights for monitoring and logging. It also creates an alert for login response time that exceeds a threshold.

### Parameters:
- `location` (string): The Azure region where the Application Insights resource will be deployed.
- `name` (string): The name of the Application Insights resource.
- `applicationType` (string): The type of application being monitored (e.g., 'web', 'other').
- `environmentType` (string): The environment type (e.g., 'prod', 'nonprod'). It affects retention days.
- `appServicePlanSkuName` (string): SKU type based on environment type (e.g., 'B1' for prod, 'B1' for non-prod).

### Resources Deployed:
- Application Insights
- Metric Alert for login response time

---

## app-service.bicep

### Function:
This Bicep file deploys both the frontend and backend Azure App Services, along with related configurations such as app settings, diagnostic settings, and role-based access control (RBAC).

### Parameters:
- `location` (string): The Azure region where the App Services will be deployed.
- `appServicePlanName` (string): The name of the App Service Plan.
- `appServiceAppName` (string): The name of the frontend app service.
- `appServiceAPIAppName` (string): The name of the backend app service.
- `appServiceAPIEnvVarENV` (string): Environment variable for the API.
- `appServiceAPIEnvVarDBHOST` (string): Database host for the API.
- `appServiceAPIEnvVarDBNAME` (string): Database name for the API.
- `appServiceAPIEnvVarDBPASS` (secure string): Database password for the API.
- `appServiceAPIDBHostDBUSER` (string): Database user for the API.

### Resources Deployed:
- Frontend and backend App Services
- Diagnostic settings for both App Services

---

## container-registry.bicep

### Function:
This Bicep file deploys an Azure Container Registry (ACR) and configures diagnostic settings for it.

### Parameters:
- `location` (string): The Azure region where the Container Registry will be deployed.
- `name` (string): The name of the Container Registry.
- `sku` (string): The SKU of the Container Registry (e.g., 'Basic', 'Standard', 'Premium').
- `workspaceResourceId` (string): The resource ID of the Log Analytics workspace for diagnostic settings.

### Resources Deployed:
- Azure Container Registry
- Diagnostic settings for the Container Registry

---

## storage.bicep

### Function:
This Bicep file deploys an Azure Storage Account with configurable replication type based on environment (production or non-production).

### Parameters:
- `location` (string): The Azure region where the Storage Account will be deployed.
- `storageAccountName` (string): The name of the Storage Account.
- `environmentType` (string): The environment type, either 'prod' or 'nonprod'. This affects the SKU used for the Storage Account.

### Resources Deployed:
- Azure Storage Account

---

### Usage:
To deploy any of these modules, simply call the desired module within a main Bicep file or use it directly in your Azure CLI or PowerShell environment. You can pass the parameters during deployment using a parameters file.
