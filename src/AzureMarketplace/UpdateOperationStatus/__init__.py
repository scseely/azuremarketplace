import logging
import json
import azure.functions as func
import os
from Shared.AzureMarketplaceApi import azure_marketplace_api


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('UpdateOperationStatus: Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        pass
    else:
        subscription_id = req_body.get('subscription_id')
        operation_id = req_body.get('operation_id')
        plan_id = req_body.get('plan_id')
        quantity = req_body.get('quantity')
        success = req_body.get('success')
    
    api = azure_marketplace_api()
    if api.update_operation_status(subscription_id, operation_id, plan_id, quantity, success):
        return func.HttpResponse("updated")
    else: 
        return func.HttpResponse(
            "Failed. See logs for details",
            status_code = 500
        )
    
