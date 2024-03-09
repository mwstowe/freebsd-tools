#!/usr/local/bin/bash
#
# Get current version
#
pythonversion=$(pkg info | grep ^python | sed 's/-.*//')
echo "Python version installed is:  $pythonversion"
#
# List versions to upgrade to
#
echo 
echo "Available versions:"
newver=$(ls -ld /usr/ports/lang/python[0-9]* | awk '{print $9}' | sed 's/.\{7\}/&./' | sort -V | sed 's/\.//')
readarray -t  pythonnewver <<< "$newver"
for element in "${pythonnewver[@]}"
do
    echo $(basename "$element")
done
echo
pythonup=""
for element in "${pythonnewver[@]}"
do
    if [ "$1" == "$(basename $element)" ]; then
        pythonup="$1"
        break
    fi
done
if [ "$pythonup" == "" ]; then
    echo "Usage:"
    echo "$0 [version] where version is one of the above"
    exit 0
fi

pyversion=${pythonversion:6}
pyup=${pythonup:6}

pydef=${pyversion:0:1}.${pyversion:1}
pydefup=${pyup:0:1}.${pyup:1}

cat /etc/make.conf | sed "s/$pydef/$pydefup/g" 
echo
echo "Confirm make.conf looks ok.  Replacing in 10 seconds"
sleep 10

cat /etc/make.conf | sed "s/$pydef/$pydefup/g" > /tmp/make.conf
mv /etc/make.conf /etc/make.conf.!
mv /tmp/make.conf /etc/make.conf

portmaster --no-confirm -dy -o lang/python$pyup python$pyversion
REINSTALL="$(pkg info -o py$pyversion-\* | awk '{printf "%s ", $2}')"
pkg delete -f py$pyversion-\*
portmaster --no-confirm -Dy $REINSTALL
REBUILD=$(pkg query -g "%n:%dn" '*' | grep py3 | grep -v py$pyup | cut -d: -f1 | sort -u)
portmaster --no-confirm -Dy $REBUILD
REBUILD2=$(pkg list | grep python-$pyversion | xargs pkg which | awk '{print $6}' | sort -u)
portmaster --no-confirm -Dy $REBUILD2
