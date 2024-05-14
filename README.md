# A GitHub-native private certificate authority

For local development environments that need TLS certificates, it's useful to mimic public
certificate authority behavior with a private CA that belongs to your organization.

This repo is a very simple wrapper around the `openssl` certificate signing command, which
runs without dependencies inside of GitHub actions. You store your CA's private key as a
repository secret, and signed certificates are stored as workflow run artifacts.

> [!IMPORTANT]  
> Before continuing, create a new private repository in your GitHub organization using
> this repository as a template. Click the green "Use this template" button above.

If you've already completed setup, skip to the [Get a signed cert](#get-a-signed-cert)
section.

The following steps assume you have a POSIX-ish shell and `openssl` available on your
local machine so make sure it's installed before proceeding. The included shell scripts
also depend on `tee` and `base64` with the flag `-w0` but can be easily adapted if
those aren't available.

## Setup

You only need to do this once. Skip to the [Get a signed cert](#get-a-signed-cert)
section if you completed setup previously.

#### Create your CA key and cert

On your local machine, create a CA key and certificate, combined into a single file. You
only need to do this once. Use the provided `new-ca.sh` shell script for convenience:

```sh
CA_NAME="Acme, Inc. Private CA" ./new-ca.sh
```

#### Configure GitHub

Create a repository secret named `CA_KEY_AND_CERT` with the contents of your combined CA key
and certificate PEM file.

1. In GitHub, navigate to the settings page for [actions secrets and variables](../../settings/secrets/actions)
3. In the "Secrets" tab, select "New repository secret"
4. Name your secret `CA_KEY_AND_CERT`
5. Paste the contents of your combined CA key and certificate PEM file as the "Secret" value

Note that once you've stored the private key as a GitHub repository secret you can destroy
the key on your local machine (just be sure to keep a copy of the CA cert). Your CA will
then only exist inside of your GitHub repo.

#### Add your CA certificate to trust stores (optional but recommended)

Presuming you want your leaf ("server") certificates to be accepted as valid by TLS clients
(i.e. web browsers, curl, etc.) you'll need to add the CA certificate created in step one
(just the cert, not the combined key and cert) to the relevant "trust stores" in your
development environment.

## Get a signed cert

#### Create a private key and certificate signing request

On your local machine, create a new private key and use it to generate a CSR for whatever
DNS name you want to appear in your signed cert. Use the provided `new-csr.sh` shell
script for convenience:

```sh
DNS_NAME=www.example.com ./new-csr.sh
```

You'll need the private key to configure TLS for your server later, so make a note of its
location. It's the file ending in `.key`.

#### Request a signed certificate

Certificates are signed using GitHub Actions. This repository includes a workflow named "sign"
that you can initiate directly from the [GitHub UI](../../actions/workflows/sign.yaml) or API.
In the UI, at the top of the workflow runs list, you should see a banner that reads
"This workflow has a workflow_dispatch event trigger." To the right of that is a button named
"Run workflow" which you can use to initiate a new signing request.

The only required input is a base64-encoded certificate signing request. If you used the
provided shell script in the previous step then the CSR file ending in `.b64` contains the
data you need.

Run the workflow with your base64-encoded CSR as input. Assuming the run completes successfully
your signed cert is available as a downloadable artifact from the workflow run details page.

## Use the signed cert

Pop the private key and signed cert from the previous step into any server's TLS configuration
and it should work. 
