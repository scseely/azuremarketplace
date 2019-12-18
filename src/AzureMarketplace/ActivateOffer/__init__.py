import logging
import json
import azure.functions as func
import os
from Shared.AzureMarketplaceApi import azure_marketplace_api

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ActivateOffer: Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        pass
    else:
        authentication_token = req_body.get('authentication_token')
        bearer = req_body.get('bearer')
        subscription_id = req_body.get('subscription_id')
        plan_id = req_body.get('plan_id')

    if authentication_token:
        api = azure_marketplace_api()
        api.activate(bearer, authentication_token, subscription_id, plan_id)
        return func.HttpResponse("all is fine")
    else:
        return func.HttpResponse(
             "Please pass the authentication_token from an EasyAuth login in the request body",
             status_code=400
        )