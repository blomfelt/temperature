rule targets:
    input:
        "data/test.txt",
        "data/sensor.json"

rule test:
    input:
        script = "code/test.sh"
    output:
        "data/test.txt"
    shell:
        "bash ./{input.script}"

rule get_sensor_data:
    output:
        "data/sensor.json"
    shell:
        "curl https://data.sensor.community/airrohr/v1/sensor/25765/ > data/sensor.json"
