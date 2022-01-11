# Microsoft-Graph-API-Custom-Connector
This connectors allows you to parse data directly from Graph API by running a REST query in one of the Graph API endpoints.

# Pre-equisites
 - Visual Studio 2019
 - Power Query SDK: https://marketplace.visualstudio.com/items?itemName=Dakahn.PowerQuerySDK
 - Application registered in Azure with Graph API Delegated permission for the API you will query from Power BI. Along side the permissions, go to Authentication tab in the application registration page and add the platform Desktop & Mobile with the following call back URL: https://oauth.powerbi.com/views/oauthredirect.html
 
# Setup
1. Open this project in Visual Studio
2. Replace the guid in client_id text file with the guid of the application registered in Azure
3. Open file Microsoft_Graph_API_Custom_Connector.pq, go to line 16 and ajust scopes with all the scopes your're intended to use
4. Set build mode to release and build the solution.
5. Copy the file \bin\Release\Microsoft Graph API Custom Connector.mez into \Documents\Power BI Desktop\Custom Connectors.
6. Make sure to select the following option in Power BI Desktop in order to allow uncertified connectors: File > Options and Settings > Options > Security > under Data Extensions, select (Not Recommended) Allow any extension to load without validation or warning. Re-open Power BI Desktop to apply.
7. Got to Get data > More... > search for graph and select the connector "Microsoft Graph API Custom Connector (Beta)" > click on Connect
8. Click on Continue
9. In the Query field, type the query according your needs, for example: users?$select=userPrincipalName,jobTitle,department
10. Click Ok.
11. Click on Sign in and authenticate with a user that has privileges to access the data from the given API.
12. Click on Connect to run the query.
