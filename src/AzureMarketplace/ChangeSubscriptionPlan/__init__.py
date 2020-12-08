import logging
import json

import azure.functions as func
import sys
import os
sys.path.append(os.path.abspath(""))
from Shared.AzureMarketplaceApi import azure_marketplace_api

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ChangeSubscriptionPlan    : Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        pass
    else:
        subscription_id = req_body.get('subscription_id')
        plan_id = req_body.get('plan_id')

    if subscription_id:
        api = azure_marketplace_api()
        retval = api.change_subscription_plan(subscription_id, plan_id)
        if (retval == False):
            return func.HttpResponse("Failed to update plan.",
            status_code=500)
        
        return func.HttpResponse(retval, mimetype='application/json')
    else:
        return func.HttpResponse(
             "Please pass the subscription_id in the request body",
             status_code=400
        )
