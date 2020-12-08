import logging
import json
import azure.functions as func
import os
import sys
sys.path.append(os.path.abspath(""))
from Shared.EnvironmentVariables import environment_variables
from Shared.AzureMarketplaceApi import azure_marketplace_api

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ActivateOffer: Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        pass
    else:
        subscription_id = req_body.get('subscription_id')
        plan_id = req_body.get('plan_id')

    if subscription_id:
        api = azure_marketplace_api()
        success = api.activate(subscription_id, plan_id)
        if (success):
            return func.HttpResponse("all is fine")
        else:
            return func.HttpResponse("this didn't work", 
                status_code=400)
    else:
        return func.HttpResponse(
             "Please pass the authentication_token from an EasyAuth login in the request body",
             status_code=400
        )