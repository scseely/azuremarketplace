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
        authentication_token = req_body.get('authentication_token')
        bearer = req_body.get('bearer')
        subscription_id = req_body.get('subscription_id')
    
    api = azure_marketplace_api()
    retval = api.list_subscription_operations(subscription_id)
    json_string = json.dumps(retval, default=lambda o: o.__dict__)
    return func.HttpResponse(json_string, mimetype='application/json')
