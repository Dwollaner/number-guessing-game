#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#Assign 0 to prevent garbage data
GUESS=0

echo Enter your username:
read USERNAME
SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))

addUserToDatabase() {
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
}

checkUserID() {
  USERNAME_DATABASE=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME_DATABASE'")
}

gameStats() {
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  TOTAL_GUESS_COUNT=$($PSQL "SELECT MIN(total_guesses) FROM games WHERE user_id = $USER_ID")
}

#Look for username in database
USERNAME_CHECK=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [ -z $USERNAME_CHECK ]
then
  READY_TO_PLAY=0
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  addUserToDatabase
  READY_TO_PLAY=1
else
  checkUserID
  gameStats
  echo "Welcome back, $USERNAME_DATABASE! You have played $GAMES_PLAYED games, and your best game took $TOTAL_GUESS_COUNT guesses."
  READY_TO_PLAY=1
fi

if [ $READY_TO_PLAY -eq 1 ]
then
  echo "Guess the secret number between 1 and 1000: "
  while [[ $GUESS -ne $SECRET_NUMBER ]]; do
    read GUESS    
    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      let GUESS_COUNT++
    elif [ $GUESS -gt $SECRET_NUMBER ]
    then
      echo "It's lower than that, guess again:"
      let GUESS_COUNT++
    elif [ $GUESS -lt $SECRET_NUMBER ]
    then
      echo "It's higher than that, guess again:"
      let GUESS_COUNT++
    elif [ $GUESS -eq $SECRET_NUMBER ]
    then
      let GUESS_COUNT++
      checkUserID
      INSERT_INTO_DATABASE=$($PSQL "INSERT INTO games(secret_number, total_guesses, user_id) VALUES($SECRET_NUMBER, $GUESS_COUNT, $USER_ID)")
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
    fi
  done
fi





