#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

# Services
option_selected=("")
while [[ $option_selected == "" ]]
do
        echo -e "\nWelcome to My Salon, how can I help you?"
        services=$($PSQL "SELECT ROW_NUMBER() OVER(ORDER BY name ASC) AS option, name FROM services;")
        echo "$services" | sed 's/|/) /'

        options=$($PSQL "SELECT ROW_NUMBER() OVER(ORDER BY name ASC) FROM services;")
        read SERVICE_ID_SELECTED
        option_list=$(echo $options | tr "\n" "\n")
        for op in $option_list; do
                if [ $SERVICE_ID_SELECTED == $op ]; then
                        option_selected="$($PSQL "SELECT name FROM services WHERE service_id=$op;")"
                fi
        done
done
echo "You have selected a $option_selected."

# Customer
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
customer_name=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $customer_name ]]; then
        echo -e "\nI don't have a record of that phone number, what's your name?"
        read CUSTOMER_NAME
        $PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
        echo -e "\nWhat time would you like your $option_selected, $CUSTOMER_NAME?"
        read SERVICE_TIME
        customer_id=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME';")
        $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
        echo -e "\nI have put you down for a $option_selected at $SERVICE_TIME, $CUSTOMER_NAME."
else
        CUSTOMER_NAME="$customer_name"
        echo -e "\nWhat time would you like your $option_selected, $CUSTOMER_NAME?"
        read SERVICE_TIME
        customer_id=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME';")
        $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
        echo -e "\nI have put you down for a $option_selected at $SERVICE_TIME, $CUSTOMER_NAME."
fi
