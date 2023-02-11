#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES_MENU(){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo -e INDEX "Out of service"
  else
    echo -e "\nHere are available services:"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    echo -e "\nWhich one would you like to opt?"
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      SERVICES_MENU "That is not a valid service number."
    else
      # get service availibilty 
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      if [[ -z $SERVICE_NAME ]]
      then
        SERVICES_MENU "That is not a valid service number."
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          echo -e "\nWelcome to our salon bash store !"
        fi

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
       
        echo -e "\nPlease enter service time:"
        read SERVICE_TIME

        APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      fi
    fi
  fi
}

INDEX(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nThank you for stopping in.\n"
}

SERVICES_MENU