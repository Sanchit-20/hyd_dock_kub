#!/bin/sh

set -e

style="padding: 20px;"
src=""
alt=""

# If the COLOR env has been set, check it has a valid value. If unset, set to
# the default value - black
if [ ! -z ${COLOR+x} ]; then
            COLOR=$(echo "$COLOR" | tr '[:upper:]' '[:lower:]')
else
    COLOR=black
fi

if [ -s /etc/docker-hostname ]; then 
    NODE_NAME=$(cat /etc/docker-hostname)
fi

# Add 'Node Name' to static HTML page if NODE_NAME has been set
if [ ! -z ${NODE_NAME+x} ]; then
    sed -i '/<h2>Version/ i <h2>Node Name: '"$NODE_NAME"'<\/h2>' ./index.html
fi

sed -i "s#@@COLOR@@#${COLOR}#g" ./index.html

# Create a temporary file for holding the entire image tag, which may contain a
# base64 encoded image embedded in the src attribute
tmpfile=$(mktemp -p .)

src=$(echo "data:image/png;base64,$(base64 ./images/shipping_container_${COLOR}.png)")
alt="$(echo $COLOR)  container"
echo "<img style=\""$style"\" src=\""$src"\" alt=\""$alt"\">" > $tmpfile

# Insert the image tag into the index.html file and remove the temporary file
sed -i '/^.\+<\/title>/r '"$tmpfile"'' ./index.html
rm -rf ./${tmpfile}

exec "$@"
