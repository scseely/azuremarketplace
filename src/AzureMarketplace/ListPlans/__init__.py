import logging
import json
import azure.functions as func
import os
import sys
sys.path.append(os.path.abspath(""))
from Shared.AzureMarketplaceApi import azure_marketplace_api

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ListPlans: Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        pass
    else:
        subscription_id = req_body.get('subscription_id')

    if subscription_id:
        api = azure_marketplace_api()
        retval = api.list_available_plans(subscription_id)
        return func.HttpResponse(retval, mimetype='application/json')
    else:
        return func.HttpResponse(
             "Please pass the authentication_token from an EasyAuth login in the request body",
             status_code=400
        )