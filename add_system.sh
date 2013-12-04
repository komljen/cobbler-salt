#!/usr/bin/env bash
#===============================================================================
#
#    AUTHOR: Alen Komljen <alen.komljen@live.com>
#
#===============================================================================
args=("$@")
domain="example.com"
interface="eth0"
profile="ubuntu-server-12.04.3-x86_64"
salt_master="192.168.100.150"
#-------------------------------------------------------------------------------
if [ ! "${#args[@]}" -eq 2 ]
then
    echo "USAGE: ./add_system.sh --mac=00:00:00:00:00:00 \
--roles=\"mysql nova-controller\""
    exit 1
fi
#-------------------------------------------------------------------------------
for i in "${args[@]}"
do
    key=$(echo $i | cut -d= -f1)

    if [ "$key" == "--mac" ]
    then
        export mac=$(echo $i | cut -d= -f2)
    elif [ "$key" == "--roles" ]
    then
        export roles=( $(echo $i | cut -d= -f2) )
    fi
done
#-------------------------------------------------------------------------------
ksmeta_roles=$(for i in "${roles[@]}"; do echo roles=$i; done)

name="compute-node-$(cobbler system list | wc -l)$(( ( RANDOM % 77 ) + 2 ))"

cobbler system add --name=${name} --hostname=${name} --interface=${interface}  \
                   --dns-name=${name}.${domain} --mac-address=${mac}           \
                   --dhcp-tag=default                                          \
                   --profile=${profile}                                        \
                   --ksmeta="${ksmeta_roles} master=${salt_master}"            \
                   --kopts="netcfg/choose_interface=${interface}"              \
                   --netboot-enabled=true

cobbler sync > /dev/null

echo "New system added: ${name}"

#===============================================================================
