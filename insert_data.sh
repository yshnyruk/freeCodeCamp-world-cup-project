#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# clear the database
echo $($PSQL "TRUNCATE games, teams")
# read each line
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # get first team
  if [[ $WINNER != 'winner' ]]
  then
    FIRST_TEAM_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    # if no team
    if [[ -z $FIRST_TEAM_ID ]]
    then
      # add team
      INSERT_FIRST_TEAM_RESULT=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ $INSERT_FIRST_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $WINNER
      fi
      # get first team id
      FIRST_TEAM_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    fi

    SECOND_TEAM_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    # if no team
    if [[ -z $SECOND_TEAM_ID ]]
    then
      # add team
      INSERT_SECOND_TEAM_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[ $INSERT_SECOND_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      # get second team id
      SECOND_TEAM_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    fi
    # get a game
    GAME_ID=$($PSQL "select game_id from games where winner_id = $FIRST_TEAM_ID and opponent_id = $SECOND_TEAM_ID")
    # if no game
    if [[ -z $GAME_ID ]]
    then
      # add game
      INSERT_GAME_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $FIRST_TEAM_ID, $SECOND_TEAM_ID, $W_GOALS, $O_GOALS)")
      if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into games, $WINNER vs $OPPONENT
      fi
    fi
  fi
done