import logging
import json
import azure.functions as func
import os
import sys
sys.path.append(os.path.abspath(""))
from Shared.AzureMarketplaceApi import azure_marketplace_api

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ListSubscriptions: Python HTTP trigger function processed a request.')

    api = azure_marketplace_api()
    retval = api.list_subscriptions()
    return func.HttpResponse(retval, mimetype='application/json')
    