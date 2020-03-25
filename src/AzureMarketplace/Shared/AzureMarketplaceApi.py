import os
import json
import uuid
from urllib import request, parse
from urllib.error import URLError, HTTPError
import sys
sys.path.append(os.path.abspath(""))
from Shared.EnvironmentVariables import environment_variables
from Shared.EasyAuth import app_auth

class marketplace_plan:
    def __init__(self, plan_id):
        self.planId = plan_id

class marketplace_quantity:
    def __init__(self, quantity):
        self.quantity = quantity

class marketplace_operation_status:
    def __init__(self, plan_id, quantity, status):
        self.planId = plan_id
        self.quantity = quantity
        self.status = status

class azure_marketplace_api:
     
    MARKETPLACE_TOKEN_HEADER = 'x-ms-marketplace-token'
    REQUEST_ID_HEADER = 'x-ms-requestid'
    AUTHORIZATION_HEADER = 'Authorization'
    CONTENT_TYPE_HEADER = 'Content-Type'
    ACCEPT_HEADER = 'Accept'
    MIME_TYPE_JSON = 'application/json; charset=utf-8'

    def __init__(self):
        self.environment = environment_variables()
        self.api_version = '2018-09-15' if self.environment.use_saas_mock_api else '2018-08-31' 
        self.base_uri = 'https://marketplaceapi.microsoft.com/api/saas/subscriptions/'
        self.app_auth = app_auth()
        
    def create_bearer(self, bearer):
        return 'Bearer {}'.format(bearer)

    def activate(self, subscription_id, plan_id):
        activate_uri = '{}{}/activate?api-version={}'.format(
            self.base_uri, 
            subscription_id,
            self.api_version)

        plan_value = marketplace_plan(plan_id)
        request_data = json.dumps(plan_value, default=lambda o: o.__dict__)
        request_bytes = request_data.encode('utf-8')
        req = request.Request(activate_uri, method='POST', data = request_bytes)
        bearer = self.app_auth.auth_portal() 
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        req.add_header(self.CONTENT_TYPE_HEADER, self.MIME_TYPE_JSON)
        resp = request.urlopen(req)
        if resp.code == 200:
            return True
        # if (resp.code == 400):
            
        return False

    def change_subscription_plan(self, subscription_id, plan_id): 
        change_subscription_uri = '{}{}?api-version={}'.format(
            self.base_uri, 
            subscription_id,
            self.api_version)

        # Force the plan ID to an ID which the mock API 
        # acknowledges
        if self.environment.use_saas_mock_api:
            plan_id = 'Premium'
        plan_value = marketplace_plan(plan_id)
        request_data = json.dumps(plan_value, default=lambda o: o.__dict__)
        request_bytes = request_data.encode('utf-8')
        bearer = self.app_auth.auth_portal()
        req = request.Request(change_subscription_uri, method='PATCH', data = request_bytes)
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        req.add_header(self.CONTENT_TYPE_HEADER, self.MIME_TYPE_JSON)
        try:
            resp = request.urlopen(req)
        except HTTPError as e:
            return e
        except URLError as e:
            return e
            
        if resp.code == 202:
            return True
        return False

    def change_subscription_quantity(self, subscription_id, quantity): 
        change_subscription_uri = '{}{}?api-version={}'.format(
            self.base_uri, 
            subscription_id,
            self.api_version)

        # If the mock API is active, change the seat count to 
        # a recognized value for the mock API        
        if self.environment.use_saas_mock_api and ((quantity <= 10) or (quantity >= 200)):
            quantity = 11

        quantity_value = marketplace_quantity(quantity)
        request_data = json.dumps(quantity_value, default=lambda o: o.__dict__)
        request_bytes = request_data.encode('utf-8')
        bearer = self.app_auth.auth_portal()
        req = request.Request(change_subscription_uri, method='PATCH', data = request_bytes)
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        req.add_header(self.CONTENT_TYPE_HEADER, self.MIME_TYPE_JSON)
        try:
            resp = request.urlopen(req)
        except HTTPError as e:
            return e
        except URLError as e:
            return e
            
        if resp.code == 202:
            return True
        return False

    def delete_subscription(self, subscription_id): 
        delete_uri = '{}{}?api-version={}'.format(
            self.base_uri, 
            subscription_id,
            self.api_version)

        bearer = self.app_auth.auth_portal()
        req = request.Request(delete_uri, method='DELETE')
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        resp_code = 0

        try:
            resp = request.urlopen(req)
            resp_code = resp.code
        except HTTPError as e:
            resp_code = e.code
        except URLError as e:
            resp_code = e.code
            
        if resp_code == 202:
            return True
        return resp_code

    def get_operation_status(self, subscription_id, operation_id): 
        # The mock API only recognizes two operation_ids.
        # Force fit to one of the two if we are using the 
        # mock API.
        if self.environment.use_saas_mock_api and \
            (operation_id != 'ea0b5d24-112b-4fc0-a6fc-44f3b8119458'):
            operation_id = 'ea0b5d24-112b-4fc0-a6fc-44f3b8119458'

        get_operation_uri = '{}{}/operations/{}?api-version={}'.format(
            self.base_uri, 
            subscription_id,
            operation_id,
            self.api_version
            )

        bearer = self.app_auth.auth_portal()
        req = request.Request(get_operation_uri, method='GET')
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        resp_code = 0

        try:
            resp = request.urlopen(req)
            resp_code = resp.code
        except HTTPError as e:
            resp_code = e.code
        except URLError as e:
            resp_code = e.code
            
        if resp_code == 200:
            data = json.load(resp)
            return data
        return resp_code

    def get_subscription(self, subscription_id): 
        if self.environment.use_saas_mock_api:
            # Force the subscription ID to an ID which the mock API 
            # acknowledges
            subscription_id = '37f9dea2-4345-438f-b0bd-03d40d28c7e0'
        get_uri = '{}{}/?api-version={}'.format(
            self.base_uri, 
            subscription_id,
            self.api_version)
        req = request.Request(get_uri, method='GET')
        bearer = self.app_auth.auth_portal()
        req.add_header(self.CONTENT_TYPE_HEADER, self.MIME_TYPE_JSON)
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        resp = request.urlopen(req)
        data = json.load(resp)
        return data

    def list_available_plans(self, subscription_id):
        list_uri = '{}{}/listAvailablePlans?api-version={}'.format(
            self.base_uri, 
            subscription_id,
            self.api_version)

        req = request.Request(list_uri, method='GET')
        bearer = self.app_auth.auth_portal()
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        req.add_header(self.CONTENT_TYPE_HEADER, self.MIME_TYPE_JSON)
        resp = request.urlopen(req)
        data = json.load(resp)
        return data
    
    def list_subscription_operations(self, subscription_id): 
        if self.environment.use_saas_mock_api:
            # Force the subscription ID to an ID which the mock API 
            # acknowledges
            subscription_id = '37f9dea2-4345-438f-b0bd-03d40d28c7e0'
        
        list_uri = '{}/{}/operations?api-version={}'.format(self.base_uri, subscription_id, self.api_version)
        
        req = request.Request(list_uri, method='GET')
        bearer = self.app_auth.auth_portal() 
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))

        resp = request.urlopen(req)
        data = json.load(resp)
        return data

    def list_subscriptions(self):
        list_uri = '{}?api-version={}'.format(self.base_uri, self.api_version)
        req = request.Request(list_uri, method='GET')
        bearer = self.app_auth.auth_portal() 
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))

        resp = request.urlopen(req)
        data = json.load(resp)
        return data

    async def resolve(self, bearer, token):
        bearer = parse.unquote(bearer)
        resolve_uri = '{}resolve?api-version={}&token={}'.format(self.base_uri, self.api_version, bearer)
        req = request.Request(resolve_uri, method='POST')
        req.add_header(self.MARKETPLACE_TOKEN_HEADER, bearer)
        app_bearer = self.app_auth.auth_portal()
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(app_bearer))

        resp = request.urlopen(req)
        data = json.load(resp)
        return data

    def update_operation_status(self, subscription_id, operation_id, plan_id, quantity, success):
        if self.environment.use_saas_mock_api:
            # Force the subscription ID to an ID which the mock API 
            # acknowledges
            subscription_id = '37f9dea2-4345-438f-b0bd-03d40d28c7e0'
            operation_id = "74dfb4db-c193-4891-827d-eb05fbdc64b0"
            plan_id = "Platinum"

        update_uri = '{}{}/operations/{}?api-version={}'.format(self.base_uri, subscription_id, operation_id, self.api_version)
        
        operation_value = marketplace_operation_status(plan_id, quantity, "Success" if success else "Failure")
        request_data = json.dumps(operation_value, default=lambda o: o.__dict__)
        request_bytes = request_data.encode('utf-8')
        req = request.Request(update_uri, method='PATCH', data = request_bytes)        
        bearer = self.app_auth.auth_portal() 
        req.add_header(self.AUTHORIZATION_HEADER, self.create_bearer(bearer))
        req.add_header(self.CONTENT_TYPE_HEADER, self.MIME_TYPE_JSON)
        try:
            resp = request.urlopen(req)
        except HTTPError as e:
            response = e.read()
            return False
        except URLError as e:
            return False
        
        if resp.code == 200:
            return True
        return False