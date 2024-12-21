#!/bin/bash

# set up network device
DEVICE=$(dmesg | grep cdc_ether | grep -m 1 "renamed from eth0" | awk -F" " '{print $5}' | sed 's/.$//')
if [[ $(nmcli c | grep -c "$DEVICE") -ne 1 ]]; then ip link set dev "$DEVICE" up; nmcli c add type ethernet; fi

# get authentication token
RESPONSE=""
until [[ $(echo $RESPONSE | grep -c SesInfo) == "1" ]]; do sleep 1; RESPONSE="$(curl -s -X GET http://192.168.8.1/api/webserver/SesTokInfo)"; done
COOKIE="$(echo "$RESPONSE" | grep 'SessionID=' | cut -b 10-147)"
TOKEN="$(echo "$RESPONSE" | grep 'TokInfo' | cut -b 10-41)"
DATA="<?xml version="1.0" encoding="UTF-8"?><request><dataswitch>1</dataswitch></request>"

# enable mobile net
curl -s -d "$DATA" http://192.168.8.1/api/dialup/mobile-dataswitch \
--header "X-Requested-With: XMLHttpRequest" \
--header "__RequestVerificationToken: $TOKEN" \
--header "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
--header "Cookie: $COOKIE" 1>/dev/null
