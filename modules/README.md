# **Azure Bicep Modules**

This folder contains reusable Bicep modules for deploying and managing Azure resources. Each module is designed for a specific resource or group of related resources, following best practices for modularity and reusability.

---

## **Module Structure**

Each module in this folder is named based on the resource or functionality it provisions. Below is a list of the available modules:

### **1. Alerts Module**
- **File:** `alerts.bicep`
- **Description:** Provisions Azure Monitor alerts and an action group integrated with a Logic App for Slack notifications.
- **Parameters:**
  - `logicAppId`: Resource ID of the Logic App used for alert notifications.
  - `appInsightsId`: Resource ID of the Application Insights instance.
  - `appServicePlanId`: Resource ID of the App Service Plan.
  - `webAppId`: Resource ID of the Web App.
- **Output:**
  - None.

---

### **2. App Service Module**
- **File:** `app-service.bicep`
- **Description:** Deploys an Azure App Service Plan and App Services (Web App and API).
- **Parameters:**
  - `location`: Azure region for deployment.
  - `appServicePlanName`: Name of the App Service Plan.
  - Additional parameters for App Service configuration.
- **Output:**
  - `appServiceAppHostName`: Hostname of the deployed Web App.
  - `appServicePlanId`: Resource ID of the App Service Plan.

---

### **3. Key Vault Module**
- **File:** `key-vault.bicep`
- **Description:** Provisions an Azure Key Vault and stores secrets for other resources like deployment tokens.
- **Parameters:**
  - `location`: Azure region for deployment.
  - `name`: Name of the Key Vault.
  - `adminPassword`: Secure admin password to store in the Key Vault.
  - `registryName`: Name of the container registry.
- **Output:**
  - `keyVaultUri`: URI of the Key Vault.

---

### **4. Logic App Module**
- **File:** `logic-app.bicep`
- **Description:** Deploys a Logic App to process alerts and send notifications to Slack.
- **Parameters:**
  - `location`: Azure region for deployment.
  - `name`: Name of the Logic App.
  - `slackWebhookUrl`: Secure Slack webhook URL for notifications.
- **Output:**
  - `logicAppId`: Resource ID of the Logic App.

---

### **5. PostgreSQL Module**
- **File:** `postgresql.bicep`
- **Description:** Deploys a PostgreSQL Flexible Server, including firewall rules, Active Directory administrators, and diagnostic settings.
- **Parameters:**
  - `location`: Azure region for deployment.
  - `serverName`: Name of the PostgreSQL server.
  - `databaseName`: Name of the database.
  - Additional parameters for server configuration.
- **Output:**
  - `postgresqlServerFqdn`: Fully qualified domain name of the PostgreSQL server.
  - `databaseName`: Name of the PostgreSQL database.
  - `serverId`: Resource ID of the PostgreSQL server.

---

### **6. Static Web App Module**
- **File:** `static-web-app.bicep`
- **Description:** Deploys an Azure Static Web App with integration to store the deployment token in Key Vault.
- **Parameters:**
  - `location`: Azure region for deployment.
  - `name`: Name of the Static Web App.
  - `environmentType`: Deployment environment (`dev`, `uat`, `prod`).
  - `keyVaultName`: Name of the Key Vault.
- **Output:**
  - `staticWebAppUrl`: Default hostname of the Static Web App.

---

## **Usage Instructions**

1. **Prerequisites:**
   - Ensure you have the Azure CLI and Bicep CLI installed and authenticated.
   - Review the parameters required for each module and adjust values as needed.

2. **How to Deploy:**
   - Use the following command to deploy a module:
     ```bash
     az deployment group create --resource-group <RESOURCE_GROUP> --template-file <MODULE_FILE.bicep> --parameters <PARAMETERS_FILE.json>
     ```

3. **Parameter Files:**
   - Create a JSON file for parameter values specific to your environment (e.g., `parameters.dev.json`).

4. **Example Parameter File:**
   ```json
   {
     "location": "eastus",
     "name": "example-name",
     "environmentType": "dev",
     "keyVaultName": "example-keyvault"
   }
