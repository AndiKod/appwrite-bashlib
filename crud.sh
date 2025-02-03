#!/usr/bin/env bash

# ---------------- #
#   appwrite/crud  #
# ---------------- #

# Configuration
API_KEY="$(env "APPWRITE_KEY")"
API_URL="$(get_yaml_item "API_URL" "${ROOT}/data/appwrite.yaml")"
PROJECT_ID="$(get_yaml_item "PROJECT_ID" "${ROOT}/data/appwrite.yaml")"
DB_ID="$(get_yaml_item "DB_ID" "${ROOT}/data/appwrite.yaml")"


check_appwrite_api_key() {
    local api_key="$1"
    
     # Check if the key starts with "standard_"
    if [[ ! "$api_key" =~ ^standard_ ]]; then
        echo "Invalid: Key must start with 'standard_'"
        return 1
    fi

    # Remove the "standard_" prefix for length checking
    local key_without_prefix="${api_key#standard_}" 

    # Check if it only contains valid hexadecimal characters
    if [[ ! "$key_without_prefix" =~ ^[a-f0-9]+$ ]]; then
        echo "Invalid: Key must contain only lowercase hexadecimal characters (a-f, 0-9)"
        return 1
    fi

}

if [[ -z "$API_KEY" ]]; then
  p "${btnWarning} Oops! ${x} APPWRITE_KEY variable is not set."
  p "Place it in the '$SCD/env.yaml' file as 'APPWRITE_KEY: mykeyhere'."
  exit 1   
fi

check_appwrite_api_key "$API_KEY"

if [[ -z "$PROJECT_ID" ]]; then      
  p "${btnWarning} Oops! ${x} PROJECT_ID variable is not set."  
  p "It should be defined in the src/bin.sh file, that use this lib. "
  exit 1       
fi


# Function to handle API requests
make_request() {
  local method=$1
  local endpoint=$2
  local data=$3

  curl -s -X "$method" "$API_URL/$endpoint" \
    -H "X-Appwrite-Project: ${PROJECT_ID}" \
    -H "X-Appwrite-Key: ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$data"
}

# --- BASICS --- #

# CREATE
# Usage: create_record "collection_id" "fields_json"

create_document() {
  local collection_id="$1"
  local document_data="$2"

  make_request "POST" \
    "databases/$DB_ID/collections/$collection_id/documents" "$document_data" 
}

# READ
# Usage: read_records "collection_id"    

read_document() {
  local collection_id="$1"
  local document_id="$2"

  # Get the data from the Table
  response=$(make_request "GET" "databases/$DB_ID/collections/$collection_id/documents/$document_id" "")
  # Parse the JSON response and return an array of records
  echo "$response"
}

# We will need this, to access the record_id.
read_collection() {
  local collection_id="$1"

  # Get the data from the Table
  make_request "GET" "databases/$DB_ID/collections/$collection_id/documents" "" | jq -c '.documents[]'
}

# UPDATE
# Usage: update_record "document_id" "data_json"

update_document() {
  local collection_id="$1"
  local document_id="$2"
  local data="$3"

  # Get the data from the Table
  response=$(make_request "PATCH" "databases/$DB_ID/collections/$collection_id/documents/$document_id" "$data")
  # Parse the JSON response and return an array of records
  echo "Response: $response"
}

# DELETE
# Usage: delete_record "record_id" 

delete_document() {
  local collection_id="$1"
  local document_id="$2"

  make_request "DELETE" "databases/$DB_ID/collections/$collection_id/documents/$document_id" ""
}



# --- CRUD Above --- #

# In some script that use "crud/table" we:
#
# Create the users array from the DB:
# TABLE_ID="tblGbqPslIjoHatI6zz"
# readarray -t users < <(read_records "$TABLE_ID")
#
# Then iterate over the users array
# for user in "${users[@]}"; do
#     username=$(field "$user" "username")
#     p "Processing user: $username"
# done
#
field() {
  stack="$2"
  needle="$1"
  echo "$stack" | jq -r ".${needle}"
}


# READ (Retrieve records)
get_table_records() {
  local collection_id="$1"

  # Get the data from the Table
  response=$(make_request "GET" "databases/$DB_ID/collections/$collection_id/documents" "")
  # Parse the JSON response and return an array of records
  echo "$response" | jq -c '.documents[]'
}

get_documents_as_array() {
  local collection_id="$1"
  local array_name="$2"
  readarray -t "$array_name" < <(get_table_records "$collection_id")
}
