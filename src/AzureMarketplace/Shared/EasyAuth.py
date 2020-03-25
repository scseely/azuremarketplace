from urllib import request, parse
import sys
import os
sys.path.append(os.path.abspath(""))
from Shared.EnvironmentVariables import environment_variables
import json

class easy_auth_result:

    EMAIL_CLAIM = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'
    NAME_CLAIM = 'name'
    TENANT_CLAIM = 'http://schemas.microsoft.com/identity/claims/tenantid'
    IDENTITY_NAME = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
    UPN_CLAIM = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn'

    def __init__(self, auth_info):
        data = auth_info[0]
        self.refresh_token = data.get('refresh_token')
        self.expires_on = data.get('expires_on')
        self.user_id = data.get('user_id')

        self.email = self.lookup_claim(data, self.EMAIL_CLAIM)
        if (self.email == None):
            self.email = self.lookup_claim(data, self.UPN_CLAIM)
            
        if (self.email == None):
            self.email = self.user_id

        self.name = self.lookup_claim(data, self.NAME_CLAIM)
        self.tenant = self.lookup_claim(data, self.TENANT_CLAIM)
        self.identity = self.lookup_claim(data, self.IDENTITY_NAME)

    def lookup_claim(self, data, claim):
        user_claims = data.get('user_claims')
        for entry in user_claims:
            if (entry.get('typ') == claim):
                return entry.get('val')
        return None


class easy_auth:
    AUTHORIZATION_HEADER = 'X-ZUMO-AUTH'

    def __init__(self, app_url, authentication_token):
        self.app_url = app_url
        self.authentication_token = authentication_token

    def auth_me(self):
        auth_me_uri = '{}/.auth/me'.format(self.app_url)
        req = request.Request(auth_me_uri, method='GET')
        req.add_header(self.AUTHORIZATION_HEADER, self.authentication_token)

        resp = request.urlopen(req)
        data = json.load(resp)
        result = easy_auth_result(data)
        return result

class app_auth:
    def __init__(self):
        self.environment = environment_variables()
        self.auth_portal_url = 'https://login.microsoftonline.com/{}/oauth2/token'.format(
            self.environment.aad_tenant_id)

    def auth_portal(self):

        # Note: the resource string is a GUID, documented at 
        # https://docs.microsoft.com/azure/marketplace/partner-center-portal/pc-saas-registration#get-a-token-based-on-the-azure-ad-app
        data = parse.urlencode({
           "grant_type"     : "client_credentials",
           "client_id"      : self.environment.aad_app_client_id,
           "client_secret"  : self.environment.aad_app_client_password,
           "resource"       : "62d94f6c-d599-489b-a797-3e10e42fbe22"
        })
        request_bytes = data.encode('utf-8')
        req = request.Request(self.auth_portal_url, method='POST', data=request_bytes)
        resp = request.urlopen(req)
        data = json.load(resp)

        return data["access_token"]

