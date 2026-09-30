#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align --quiet -c"

echo -e "\n~~~~~ My Beauty Salon ~~~~~~\n"
echo "Welcome to my Salon, How can I help you?"

# Display services
display_services() {
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

echo "$SERVICES" | while IFS='|' read -r SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done 
}

# Show different choices
display_services

# Read choice
read SERVICE_ID_SELECTED

# validate service
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

while [[ -z $SERVICE_NAME ]]
do
  echo "I could not find that service. What would you like to do today?"
  display_services
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
done

# Get service 
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Get customer phone
echo "What is your phone number?"
read CUSTOMER_PHONE

# Find existing customer
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# If customer doesn't exist, insert it
if  [[ -z $CUSTOMER_NAME ]]
then 
  echo "I don't have a record for that phone number, What is your name?"
  read CUSTOMER_NAME

  $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  fi

# Pick appointment time
echo "At what time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# Set appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Confirmation
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."