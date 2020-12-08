import os
import json
import uuid
import azuremarketplace
from urllib import request, parse
from urllib.error import URLError, HTTPError
import sys
sys.path.append(os.path.abspath(""))
from Shared.EnvironmentVariables import environment_variables
from Shared.EasyAuth import app_auth
from azuremarketplace.microsoft.marketplace.saas import SaaSAPI
from azuremarketplace.microsoft.marketplace.saas.models import ResolvedSubscription, SubscriberPlan, UpdateOperation
from azure.identity import ClientSecretCredential
from msrest import Serializer

class azure_marketplace_api:
     
    MARKETPLACE_TOKEN_HEADER = 'x-ms-marketplace-token'
    REQUEST_ID_HEADER = 'x-ms-requestid'
    AUTHORIZATION_HEADER = 'Authorization'
    CONTENT_TYPE_HEADER = 'Content-Type'
    ACCEPT_HEADER = 'Accept'
    MIME_TYPE_JSON = 'application/json; charset=utf-8'

    def __init__(self):
        self.environment = environment_variables()
        client_models = {k: v for k, v in azuremarketplace.microsoft.marketplace.saas.models.__dict__.items() if isinstance(v, type)}
        serializer = Serializer(client_models)
        serializer.client_side_validation = False
        self.serializer = serializer
        cred = ClientSecretCredential(
            client_id=self.environment.aad_app_client_id,
            client_secret=self.environment.aad_app_client_password,
            tenant_id=self.environment.aad_tenant_id
        )
        self.client = SaaSAPI(cred)

        
    def create_bearer(self, bearer):
        return 'Bearer {}'.format(bearer)

    def handle_simple_response(self, response, data, other):
        return response

    def activate(self, subscription_id, plan_id):
        plan = SubscriberPlan(plan_id=plan_id)
        response = self.client.fulfillment_operations.activate_subscription(subscription_id=subscription_id,
            body=plan, cls=self.handle_simple_response)
        if response.http_response.status_code == 200:
            return True

        return False

    def change_subscription_plan(self, subscription_id, plan_id): 
        plan = SubscriberPlan(plan_id=plan_id)
        response = self.client.fulfillment_operations.update_subscription(
            subscription_id=subscription_id,
            body=plan,
            cls=self.handle_simple_response
        )

        status_code = response.http_response.status_code
        if status_code == 200 or status_code == 202:
            return response.http_response.headers['Operation-Location']

        return False

    def change_subscription_quantity(self, subscription_id, quantity): 
        plan = SubscriberPlan(quantity=quantity)
        response = self.client.fulfillment_operations.update_subscription(
            subscription_id=subscription_id,
            body=plan,
            cls=self.handle_simple_response
        )

        status_code = response.http_response.status_code
        if status_code == 200 or status_code == 202:
            return response.http_response.headers['Operation-Location']

        return False

    def delete_subscription(self, subscription_id): 
        response = self.client.fulfillment_operations.delete_subscription(
            subscription_id=subscription_id,
            cls=self.handle_simple_response)
        status_code = response.http_response.status_code
        if status_code == 202:
            return True

        return False

    def get_operation_status(self, subscription_id, operation_id): 
        response = self.client.subscription_operations.get_operation_status(
            subscription_id=subscription_id,
            operation_id=operation_id
        )

        json_obj = self.serializer.body(response, 'Operation')
        json_string = json.dumps(json_obj, default=lambda o: o.__dict__)
        return json_string
        

    def get_subscription(self, subscription_id): 
        response = self.client.fulfillment_operations.get_subscription(
            subscription_id=subscription_id
        )

        json_obj = self.serializer.body(response, 'Subscription')
        json_string = json.dumps(json_obj, default=lambda o: o.__dict__)
        return json_string

    def list_available_plans(self, subscription_id):
        response = self.client.fulfillment_operations.list_available_plans(
            subscription_id=subscription_id
        )

        json_obj = self.serializer.body(response, 'SubscriptionPlans')
        json_string = json.dumps(json_obj, default=lambda o: o.__dict__)
        return json_string
    
    def list_subscription_operations(self, subscription_id): 
        response = self.client.subscription_operations.list_operations(
            subscription_id=subscription_id
        )

        json_obj = self.serializer.body(response, 'OperationList')
        json_string = json.dumps(json_obj, default=lambda o: o.__dict__)
        return json_string

    def list_subscriptions(self):
        response = self.client.fulfillment_operations.list_subscriptions()
        # This one is incomplete
        json_obj = self.serializer.body(response, 'SubscriptionsResponse')
        json_string = json.dumps(json_obj, default=lambda o: o.__dict__)
        return json_string

    def resolve(self, marketplace_token):
        retval = self.client.fulfillment_operations.resolve(x_ms_marketplace_token=marketplace_token)

        json_obj = self.serializer.body(retval, 'ResolvedSubscription')
        json_string = json.dumps(json_obj, default=lambda o: o.__dict__)
        return json_string
    
    def resolve_to_obj(self, marketplace_token):
        retval = self.client.fulfillment_operations.resolve(x_ms_marketplace_token=marketplace_token)

        json_obj = self.serializer.body(retval, 'ResolvedSubscription')
        return json_obj
    
    def update_operation_status(self, subscription_id, operation_id, plan_id, quantity, status):
        updateOperation = UpdateOperation(
            plan_id=plan_id,
            quantity=quantity,
            status=status
        )
        response = self.client.subscription_operations.update_operation_status(
            subscription_id=subscription_id,
            operation_id=operation_id,
            body=updateOperation,
            cls=self.handle_simple_response
        )

        status_code = response.http_response.status_code
        if status_code == 200 or status_code == 202:
            return True

        return False