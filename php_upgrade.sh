#!/usr/local/bin/bash
#
# Find installed php version
#
phpver=$(php --version | grep ^PHP | awk '{print $2}' | cut -d. -f1,2 | sed 's/\.//')
echo "PHP version installed is: php"${phpver}
if [ "$2" != "" ]; then
    phpver=$2
    echo Version forced to:  $phpver
else
    phpver=php$phpver
fi
#
# List versions to upgrade to
#
echo
echo "Available versions:"
newver=$(ls -ld /usr/ports/lang/php*[0-9] | awk '{print $9}')
readarray -t  phpnewver <<< "$newver"
for element in "${phpnewver[@]}"
do
    echo $(basename "$element")
done
echo
phpup=""
for element in "${phpnewver[@]}"
do
    if [ "$1" == "$(basename $element)" ]; then
        phpup="$1"
        break
    fi
done
if [ "$phpup" == "" ]; then
    echo "Usage:"
    echo "$0 [version] where version is one of the above"
    exit 0
fi
#
# check for i386
#
if [ $(uname -p) == "i386" ]; then
    echo "WARNING:  i386 detected, gcc will be used as compiler"
    echo
    echo "You may want to hit ctrl-C, and run"
    echo "portmaster -a -x php\\* -x mod_php\\*"
    echo "before proceeding"
    echo
    cc=GCC
    sleep 5
fi

#
# Find all php ports
#
phpports=$(pkg info | grep php | grep "$phpver" | awk '{print $1}')
echo "Ports to upgrade:"
#
# Move php and mod_php to top, extensions to bottom
#
phptop=$phpver-${phpver:3:1}
readarray -t  phpportlist <<< "$phpports"
declare -a orderedportlist=()
for element in "${phpportlist[@]}"
do
    if [[ $element =~ $phptop ]]; then
        orderedportlist+=($element)
    fi
done
for element in "${phpportlist[@]}"
do
    if [[ ! $element =~ $phptop ]] && [[ ! $element =~ extensions ]] && \
        [[ $element =~ ^php ]]; then
        orderedportlist+=($element)
    fi
done
for element in "${phpportlist[@]}"
do
    if [[ $element =~ extensions ]]; then
        orderedportlist+=($element)
    fi
done
# everything else
for element in "${phpportlist[@]}"
do
    if [[ ! $element =~ $phptop ]] && [[ ! $element =~ extensions ]] && \
        [[ ! $element =~ ^php ]]; then
        orderedportlist+=($element)
    fi
done

for element in "${orderedportlist[@]}"; do
    echo -n "$element "
done
echo
sleep 10

for portle in "${orderedportlist[@]}"
do
    portdir=$(pkg info "$portle" | grep ^Origin | awk '{print $3}' | sed "s/$phpver/$phpup/")
    echo portmaster --no-confirm -o $portdir $portle
    portmaster --no-confirm -o $portdir $portle
done
