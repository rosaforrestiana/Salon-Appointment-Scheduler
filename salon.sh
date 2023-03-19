#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# display title
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"

# get services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

MAIN_MENU(){

  # display argument if exist
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # show service menu
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  #if input is not INT
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # return to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  fi

  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id =$SERVICE_ID_SELECTED;")
  #if the number input not found
  if [[ -z $SERVICE_ID ]]
  then
    # return to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")

  # if a valid option
  # ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  

  # if customer not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask for customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert customer data
    UPDATE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # add appointment time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME

  # if no time input
  if [[ -z $SERVICE_TIME ]]
  then
    MAIN_MENU "You have to input the time, please try again"
  fi

  #insert appointment
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  if [[ $APPOINTMENT_RESULT=='INSERT 0 1' ]]
  then
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    exit
  else
    MAIN_MENU "Unexpected error occur, please try again."
  fi
}


MAIN_MENU
