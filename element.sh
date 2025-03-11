#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Verificar si se proporcionó un argumento
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Determinar el tipo de búsqueda según el argumento
if [[ $1 =~ ^[0-9]+$ ]]
then
  # Buscar por número atómico
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                   FROM elements e 
                   JOIN properties p ON e.atomic_number = p.atomic_number 
                   JOIN types t ON p.type_id = t.type_id 
                   WHERE e.atomic_number = $1")
else
  # Buscar por símbolo o nombre
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                   FROM elements e 
                   JOIN properties p ON e.atomic_number = p.atomic_number 
                   JOIN types t ON p.type_id = t.type_id 
                   WHERE e.symbol = '$1' OR e.name = '$1'")
fi

# Verificar si se encontró el elemento
if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
  exit
fi

# Extraer y mostrar la información del elemento
echo "$ELEMENT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
done
