import logging
import json
import azure.functions as func
import os
import sys
sys.path.append(os.path.abspath(""))
from Shared.EasyAuth import easy_auth
from Shared.AzureMarketplaceApi import azure_marketplace_api
from Shared.EnvironmentVariables import environment_variables



class resolve_bearer_result:
    
    def __init__(self, resolve_result, easy_auth_result):
        self.resolve_result = resolve_result
        self.easy_auth_result = easy_auth_result


def get_easy_auth_info(token):
    environment = environment_variables()
    auth = easy_auth(environment.app_service_url, token)
    auth_info = auth.auth_me()

    return auth_info


async def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('ResolveBearer: Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        pass
    else:
        authentication_token = req_body.get('authentication_token')
        bearer = req_body.get('bearer')

    if authentication_token:
        api = azure_marketplace_api()
        data = await api.resolve(bearer, authentication_token)
        easy_auth = get_easy_auth_info(authentication_token)
        retval = resolve_bearer_result(data, easy_auth)
        json_string = json.dumps(retval, default=lambda o: o.__dict__)
        return func.HttpResponse(json_string, mimetype='application/json')
    else:
        return func.HttpResponse(
             "Please pass the authentication_token from an EasyAuth login in the request body",
             status_code=400
        )
