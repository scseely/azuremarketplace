import logging
import json
import azure.functions as func
import os
import sys
sys.path.append(os.path.abspath(""))
from Shared.AzureMarketplaceApi import azure_marketplace_api


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ListSubscriptionOperations: Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        pass
    else:
        subscription_id = req_body.get('subscription_id')
    
    api = azure_marketplace_api()
    retval = api.list_subscription_operations(subscription_id)
    return func.HttpResponse(retval, mimetype='application/json')
