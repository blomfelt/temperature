rule targets:
    input:
        "data/test.txt",
        "data/sensor.json"

rule test:
    output:
        "data/test.txt"
    shell:
        "echo hej > data/test.txt"

rule get_sensor_data:
    output:
        "data/sensor.json"
    shell:
        "curl https://data.sensor.community/airrohr/v1/sensor/25765/ > data/sensor.json"
