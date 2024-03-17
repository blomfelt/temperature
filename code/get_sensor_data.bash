#!/usr/bin/env bash

sensors=(25765 31437)

for sensor in ${sensors[@]}
do
echo $sensor
curl https://data.sensor.community/airrohr/v1/sensor/$sensor/ > data/sensor_$sensor.json
done