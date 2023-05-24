#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SALON APPOINTMENT SCHEDULER ~~~~~"

echo -e "\nWelcome to Hair Saloon. We currently offer the following services:"

# search for available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

SERVICE_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

# show availiable services
echo -e "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done

# ask which service for appointment
echo -e "\nWhat would you like to schedule today?"
read SERVICE_ID_SELECTED
case $SERVICE_ID_SELECTED in
  [1-5]) BOOKING_MENU ;;
  6) EXIT ;;
  *) SERVICE_MENU "That is not a valid service number.";;
esac
}

BOOKING_MENU(){
  # get customer info
  echo -e "\nWhat is your phone number?"
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

  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # book appointment time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME

  # insert into appointments
  INSERT_SERVICE_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  # confirmation message
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/ //g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}


SERVICE_MENU
