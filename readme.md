# AzTeamsautomapper

This script was made as an instant Teams/Sharepoint Onedrive sync mapping tool. The tool is based on my (fairly outdated) blog from 3 years ago that you can find [here](https://www.cyberdrain.com/automatically-mapping-sharepoint-sites-in-the-onedrive-for-business-client/)

The idea is to create a fast method to map all Onedrive and sharepoint sites a user has access too.

Unfortunately the onedrive automatic mapping structure isn’t where it should be yet. For example the GPO/intune method for automatic mapping configuration can take up to 8 hours to apply on any client.

During migrations and new deployments this is pretty much unacceptable. To make sure that mapping would be instant I’ve decided to create two scripts; One Azure Function which I’ve called AzMapper, and another client based script that connects to this function. 

The function uses Microsoft Graph to extract all sites a user has access to. 

# Installation instructions

AzMapper requires you to create an Azure Function. To do that follow this [manual](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function) and replace the script with "AzMapperFunction.ps1".

This script is compatible with the [Secure Application Model](https://www.cyberdrain.com/connect-to-exchange-online-automated-when-mfa-is-enabled-using-the-secureapp-model/), and as such it can check all of your partner tenants too. Meaning you’ll only need to host a single version.

for more information visit my blog post about this [here](https://www.cyberdrain.com/automating-with-powershell-teams-automapping/)
# Usage

To check if the Function is working, change the following URL to your environment:

    https://azmapper.azurewebsites.net/api/AzOneMap?code=verylongapicodehere==&Tenantid=TENANTIDHERE&Username=USERNAMEHERE

to map the sites, use AzMapperClient.ps1 as a logon script, executed script, etc etc.

# Contributions

Feel free to send pull requests or fill out issues when you encounter them. I'm also completely open to adding direct maintainers/contributors and working together! :)

# Future plans

None :) This does anything I want, you want more, send in a feature request! :)