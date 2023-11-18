#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?" 

  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services;")
  if [[ -z $SERVICES_AVAILABLE ]]
  then
    echo -e "\nWe don't have services available."
  else
    # display services available
    echo "$SERVICES_AVAILABLE" | while read SERVICE_ID NAME
    do
    NAME_FORMATTED=$(echo $NAME | sed 's/| //')
      echo "$SERVICE_ID) $NAME_FORMATTED"
    done
  fi
  read SERVICE_ID_SELECTED
  
  SERVICE_SELECTED=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_SELECTED ]]
  then
    MAIN_MENU "Please enter a valid option."
  else
    # get customer_phone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # get service_time
    echo -e "\nWhat time do you want to book?"
    read SERVICE_TIME

    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # send to main menu
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}

MAIN_MENU