#!/usr/bin/env bash

#column -t data/current_values.tsv

currentDate=$(grep "25002" data/current_values.tsv | cut -f2)
echo $currentDate

currentHour=$(grep "25002" data/current_values.tsv | cut -f7 | cut -d":" -f1)
echo $currentHour

# Temperature chosen as 25002, difference if change to 31437?
currentTemp=$(grep "25002" data/current_values.tsv | cut -f3)
echo $currentTemp

# Pressure at sensor, change to pressure at sea level? How calculated?
currentPress=$(grep "31437" data/current_values.tsv | cut -f4)
echo $currentPress

currentHum=$(grep "31437" data/current_values.tsv | cut -f5)
echo $currentHum

sed "s/UPPTID/$currentHour/" index_mall.html | 
sed "s/UPPDATUM/$currentDate/" | 
sed "s/TEMPERATURNU/$currentTemp/" |
sed "s/HUMNU/$currentHum/" |
sed "s/PRESNU/$currentPress/" > public/index.html
