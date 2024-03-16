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
    input:
        script = "code/get_sensor_data.bash"
    params:
        sensor_id = 25765
    output:
        "data/sensor.json"
    shell:
        "bash ./{input.script} {params.sensor_id}"
