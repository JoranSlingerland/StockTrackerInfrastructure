# StockTracker Project - Frontend infrastructure

![Azure Deployment](https://github.com/JoranSlingerland/StockTrackerInfrastructure/actions/workflows/deploy-to-azure.yml/badge.svg) ![Bicep build](https://github.com/JoranSlingerland/StockTrackerInfrastructure/actions/workflows/bicep-build.yml/badge.svg) ![Maintained](https://img.shields.io/badge/Maintained-Yes-%2331c553) ![License](https://img.shields.io/github/license/JoranSlingerland/StockTracker?color=%2331c553) ![Issues](https://img.shields.io/github/issues/JoranSlingerland/StockTrackerinfrastructure)

The target of this project is to get data about your stock portfolio and make this viewable in a web application.

## Related repos

The project consists of three repositories:

| Name                                                                             | Notes                                       | Language |
| -------------------------------------------------------------------------------- | ------------------------------------------- | -------- |
| [API](https://github.com/JoranSlingerland/StockTracker)                          | This repo which will be used to gather data | Python   |
| [Frontend](https://github.com/JoranSlingerland/StockTracker-frontend)            | Frontend repo which will create the website | React    |
| [Infrastructure](https://github.com/JoranSlingerland/StockTrackerInfrastructure) | Code to deploy all resouces to Azure        | Bicep    |

Please check the API repo for more information. Or deploy the resouces with the button below:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgist.githubusercontent.com%2FJoranSlingerland%2Fa9087b977db092d71212e442dd5c5975%2Fraw%2FStocktrackerBuild)
