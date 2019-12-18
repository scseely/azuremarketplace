import os

class environment_variables:
    def __init__(self):
        self.use_saas_mock_api = os.environ['USE_SAAS_MOCK_API'].lower() == 'True'.lower()
        self.app_service_url = os.environ['APP_SERVICE_URL']
        self.aad_app_client_id = os.environ['AAD_APP_CLIENT_ID']
        self.aad_app_client_password = os.environ['AAD_APP_CLIENT_PASSWORD']
        self.aad_tenant_id = os.environ['AAD_TENANT_ID']
        