# Appwrite CRUD library for Sh:erpa

This library is a CRUD (Create, Read, Update, Delete) library for Appwrite, intended as an extention to [Sh:erpa](https://github.com/SherpaCLI/sherpa) to ease the creation of applications running into the terminal. 


## Installation 

```bash
# Install the library
sherpa install -n "appwrite" -t "lib" -u "https://github.com/AndiKod/appwrite-bashlib"
```

You can install the pre-configured, bashbox demo package, demonstrating the basic CRUD operations and build from there

```bash
sherpa install -n "appwrite" -u "https://github.com/AndiKod/appwrite-bashbox"
```
or start from scratch as follow:

## Configuration

Place the API_KEY in "$SCD/env.yaml" as

```yaml
APPWRITE_KEY: "standard_..."
```
Create a BashBox package with

```bash
sherpa new myapp
```
Move inside the project directory

```bash
boxes && cd myapp
```
in `data/appwrite.yaml`, place the following content

```yaml
API_URL: "https://cloud.appwrite.io/v1"
PROJECT_ID: "..."
DB_ID: "..."
SOME_COLLECTION_ID: "..."
SOME_DOCUMENT_ID: "..."
```

## Usage

Let aside the things like validation, errors checking, etc, the CRUD functions themselves are self-explanatory:

### Add a username

```bash
# Prepare the Payload
# A uuid is expected as documentId
# If needed, run: webi uuidv7@stable
data='{
    "documentId": "'$(uuidv7)'",
    "data": {
    "username": "'$new_user'"
    }
}'

# Register the user
if create_document "$collection_id" "$data" > /dev/null 2>&1; then
    br
    p "${btnSuccess} Done! ${x} is registered."
    br
    exit 0
else
    br
    p "${btnWarning} Oops! ${x} Process exited with code ${?}"
    br
    exit 1
fi
``` 
### List usernames

```bash [src/bin.sh]
# Data 
collection_id="$(dataGet "appwrite" "USERS_COLLECTION")"
get_documents_as_array "$collection_id" "users"

# Template
h1 "Appwrite CRUD"
hr "Sh:erpa" "-"
h2 "Users"
p  "List of usernames from the users collection:"
br
for user in "${users[@]}"; do
    username="$(field "username" "$user")"
    p "> $username"
done
```

### Update a username

```bash [src/bin.sh]
# Prepare the Payload
data='{
    "data": {
    "username": "'"$new_username"'"
    }
}'

# Update the username
if update_document "$collection_id" "$document_id" "$data" > /dev/null; then
    br
    p "${btnSuccess} Done! ${x} ${actual_username} is now called ${new_username}."
    br
    exit 0
else
    br
    p "${btnWarning} Oops! ${x} Process exited with code ${?}"
    br
    exit 1
fi # end Update the username
```

### Delete a username

```bash [src/bin.sh]
confirm "Are you sure you want to delete ${username}"

# Delete a unername
if delete_document "$collection_id" "$document_id" > /dev/null; then
    br
    p "${btnSuccess} Done! ${x} ${username} just left the camp."
    br
    exit 0
else
    br
    p "${btnWarning} Oops! ${x} Process exited with code ${?}"
    br
    exit 1
fi # end Delete a username
```

