#!/usr/local/bin/bash
#
# Find installed perl version
#
perlver=$(perl -v | grep subversion | cut -d' ' -f9 | sed 's/(v//' | sed 's/)//')
# Trim subversion
perlver="${perlver%.*}"

echo "perl version installed is: perl"${perlver}
if [ "$2" != "" ]; then
    perlver=$2
    echo Version forced to:  $perlver
else
    perlver=perl$perlver
fi
#
# List versions to upgrade to
#
echo
echo "Available versions:"
newver=$(ls -ld /usr/ports/lang/perl*[0-9] | awk '{print $9}')
readarray -t  perlnewver <<< "$newver"
for element in "${perlnewver[@]}"
do
    echo $(basename "$element")
done
echo
perlup=""
for element in "${perlnewver[@]}"
do
    if [ "$1" == "$(basename $element)" ]; then
        perlup="$1"
        break
    fi
done
if [ "$perlup" == "" ]; then
    echo "Usage:"
    echo "$0 [version] where version is one of the above"
    exit 0
fi


pversion=${perlver:4}
pup=${perlup:4}

pydef="perl"${pversion:0:1}"="$pversion
pydefup="perl"${pup:0:1}"="$pup

cat /etc/make.conf | sed "s/$pversion/$pup/g" 
echo
echo "Confirm make.conf looks ok.  Replacing in 10 seconds"
sleep 10

cat /etc/make.conf | sed "s/$pversion/$pup/g" > /tmp/make.conf
mv /etc/make.conf /etc/make.conf.!
mv /tmp/make.conf /etc/make.conf

portmaster -o lang/$perlup lang/$perlver

portmaster -f `pkg shlib -qR libperl.so.${perlver:4}`
