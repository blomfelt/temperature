#!/usr/bin/env bash

sensor=$1
curl https://data.sensor.community/airrohr/v1/sensor/$sensor/ > data/sensor.json