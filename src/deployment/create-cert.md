* [OpenSSL](https://github.com/openssl/openssl): Needed to convert a .CER of a purchased SSL certificate to a .PFX for use in Azure.
## Get a certifcate handy. Create your PFX

Several steps require a pfx which contains both the private and public keys for the certificate. When purchasing
a certificate, you usually download a .ZIP file which contains the following:
* .crt file
* .pem file
* .p7b file

Many SSL vendors provide instructions about converting the certificate into a PFX for Azure or IIS. 
For example, GoDaddy has [these instuctions](https://www.godaddy.com/help/manually-install-an-ssl-certificate-on-my-microsoft-azure-web-app-32071) for Azure. Note: if following 
those instructions, you have your PFX by step 10 where you create/save the PFX file.

Keep the PFX in an accessible but secure location. Keep the password for the PFX in a secure location too.

As of this writing, the following command would create a CSR and KEY file:
``` bash
openssl req -new -newkey rsa:2048 -nodes -keyout domain.key -out domain.csr
```

Then, creating the PFX should use a command line like this, where domain.key was created in the 
previous command line and domain.crt was downloaded after your SSL provider processed your CSR:

``` bash
openssl pkcs12 -export -out domain.pfx -inkey domain.key -in domain.crt 
```
