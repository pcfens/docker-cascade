#!/bin/sh

PROPFILE="/usr/local/tomcat/conf/catalina.properties"
if [ ! -f "$PROPFILE" ]; then
  echo "Unable to find properties file $PROPFILE"
  exit 1
fi

setProperty() {
  prop=$1
  val=$2

  if [ $(grep -c "$prop" "$PROPFILE") -eq 0 ]; then
    echo "${prop}=$val" >> "$PROPFILE"
  else
    val=$(echo "$val" |sed 's#/#\\/#g')
    sed -i "s/$prop=.*/$prop=$val/" "$PROPFILE"
  fi
}

setPropsFromFile() {
  file=$1
  for l in $(grep '=' "$file" | grep -v '^ *#'); do
    prop=$(echo "$l" |cut -d= -f1)
    val=$(cut -d= -f2- <<< "$l")
    setProperty "$prop" "$val"
  done
}

setPropFromEnv() {
  prop=$1
  val=$2
  # If no value was given, abort
  [ -z "$val" ] && return
  if [ $(grep -c "$prop" "$PROPFILE") -eq 0 ]; then
    echo "${prop}=$val" >> "$PROPFILE"
  else
    val=$(echo "$val" |sed 's#/#\\/#g')
    sed -i "s/$prop=.*/$prop=$val/" "$PROPFILE"
  fi
}

if [ -f "${CONFIG_FILE}" ]; then
  setPropsFromFile "${CONFIG_FILE}"
fi

# Pull properties from docker secrets
if [ -d /run/secrets ]; then
  for file in /run/secrets/*; do
    # If the file extension is .properties then simply append it to PROPFILE
    if [ $(echo "$file" | rev | cut -d. -f1 | rev) == "properties" ]; then
      cat "$file" > $PROPFILE
    else
      prop=$(basename "$file")
      val=$(cat "$file")
      setProperty "$prop" "$val"
    fi
  done
fi

exec bin/catalina.sh run
