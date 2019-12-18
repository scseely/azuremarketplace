import logging
import json
import azure.functions as func
import os
from Shared.AzureMarketplaceApi import azure_marketplace_api

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ListSubscriptions: Python HTTP trigger function processed a request.')

    api = azure_marketplace_api()
    retval = api.list_subscriptions()
    json_string = json.dumps(retval, default=lambda o: o.__dict__)
    return func.HttpResponse(json_string, mimetype='application/json')
    