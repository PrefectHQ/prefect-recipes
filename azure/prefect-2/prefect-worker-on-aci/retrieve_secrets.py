from azure.identity import DefaultAzureCredential, ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient
import sys

# Set up the default credential, which uses the managed identity of the Azure resource (ACI, VM, etc.)
def get_creds(auth_type):
    if auth_type == "managed_identity":
        credential = ManagedIdentityCredential(managed_identity_client_id="<the service principal / clientID of your identity>") # myaciid clientId
    else:
        credential = DefaultAzureCredential(exclude_shared_token_cache_credential=True)
    return credential


# Create a secret client using the default credential and the URL to the Key Vault
def get_secret(credential):
    secret_client = SecretClient(vault_url="https://<your vault>.vault.azure.net", credential=credential)
    secret_name = "mysecret"

    # Retrieve the secret
    retrieved_secret = secret_client.get_secret(secret_name)
    print (retrieved_secret.value) # This is the secret value - optional for development to verify


def main():
    # Check if the user wants to use managed identity, or the default credential
    if len(sys.argv) == 2 and sys.argv[1] == "managed_identity":
        credential = get_creds("managed_identity")
    else:
        credential = get_creds("default")
    access_token = get_secret(credential)
    # Return the access token to the pull step
    return {"access_token": access_token }

if __name__ == "__main__":
    main()
