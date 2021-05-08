# AAD-FreeRadius-802.1x

Radius setup based on [freeRADIUS](https://freeradius.org/) and [docker](https://www.docker.com/) to support 802.1x Wi-Fi authentication for Azure AD joined clients.

## Prerequisites

* Docker host & client to build and run the image (can be any kind of linux server or PaaS offering like Azure Container Instance)
* Certification authority (ADCS or Cloud based like [SCEPMan](https://www.scepman.com/))
    * Revocation information is accessible via OCSP responder
    * Clients certificate deployment via SCEP
    * For Microsoft based OCSP responders nonce support must be enabled

# Setup

The following steps describe the setup of freeRADIUS with docker.
The setup can either be done with an Active Directory Certificate Services (ADCS) based certification authority or with a self-signed certificate for the freeRADIUS server.

## Certificate template (ADCS)

* Copy "Web Server" template
* Compatibility: change both to Server 2012R2
* General:
    * Display name: nicolonsky RADIUS Server
* Request handling:
    * Allow private key to be exported
* Cryptography:
    * Provider category: Key Storage Provider
    * Request must use one of the following providers: Microsoft Software Key Storage Provider
    * Request hash: SHA256
* Mark template as issuable: Manage -> New certificate template to issue

## Request certificate (ADCS)

* Request a new certificate: `openssl req -new -sha256 -newkey rsa:2048 -nodes -keyout raddb/certs/server.pem -days 365 -out request.csr`
* Submit CSR to Issuing CA
    * Submit request and remember request id: `certreq -attrib "CertificateTemplate:nicolonskyRADIUSServer" -submit "C:\ca\request.csr"`
    * Retrieve issued certificate: `certreq -retrieve 24`
    * Append certificate contents (base64 encoded) to: `raddb/certs/server.pem`

## Issue self-signed certificate

A self signed certificate can be requested and issued with: `openssl req -x509 -new -sha256 -newkey rsa:2048 -nodes -keyout raddb/certs/server.pem -days 365 -out raddb/certs/server.pem`.

## Gather Issuing CA certificate

* Copy base64 certificate of your issuing CA(s) to: `raddb/certs/ca.pem`

## Add RADIUS clients

* Add your radius clients to: `/raddb/clients.conf`

## Update OCSP responder URL

* Update the URL to match your OCSP responder: `raddb/mods-enabled/eap` (L#706)

## Build and run your docker images

* `docker compose build`
* `docker compose up -d`

## Build and run your docker images (Azure Container Instance)

* `docker login nicolonsky.azurecr.io`
* `docker login azure`
* `docker context create aci acicontext`
* `docker compose build`
* `docker --context acicontext compose up`

# Operational tasks

* Connect into container: `docker exec -it aad-freeradius-8021x-radius-1 bin/bash`
* View Radius logs: `tail /opt/var/log/radius/radius.log`