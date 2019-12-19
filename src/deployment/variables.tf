variable "location" {
    type    = string
    default = "centralus"
}

variable "base_name" {
    type    = string
    default = "dummybase"
}

variable "domain_name" {
    type    = string
    default = "dummydomain.com"
}

variable "azure_ad_tenant_id" {
    type    = string
    default = ""
}

variable "azure_subscription_id" {
    type    = string
    default = ""
}

variable "service_principal_client_secret" {
    type    = string
    default = ""
}

variable "service_principal_client_id" {
    type    = string
    default = ""
}

variable "aad_app_client_id" {
    type    = string
    default = ""
}

variable "aad_app_client_password" {
    type    = string
    default = ""
}