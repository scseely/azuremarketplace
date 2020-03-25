import logging
import json

import azure.functions as func
import sys
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
        json_string = json.dumps(retval, default=lambda o: o.__dict__)
        return func.HttpResponse(json_string, mimetype='application/json')
    else:
        return func.HttpResponse(
             "Please pass the subscription_id in the request body",
             status_code=400
        )
