SENSORS = ['25765'] #Just need to specify one of them?

rule all:
    input:
        expand("data/sensor_{sensorID}.json", sensorID = SENSORS),
        "data/test.txt",
        expand("data/sensor_{sensorID}_temp.txt", sensorID = SENSORS)

rule get_sensor_data:
    input:
        script = "code/get_sensor_data.bash"
    output:
        "data/sensor_{id}.json"
    shell:
        "bash ./{input.script}"

rule test:
    input:
        script = "code/test.sh"
    output:
        "data/test.txt"
    shell:
        "bash ./{input.script}"

rule extract_temp:
    input:
        "data/sensor_{sensor_ID}.json"
    output:
        "data/sensor_{sensor_ID}_temp.txt"
    script:
        """
        import json
        with open('{input}', 'r') as infile:
            temp_data = json.load(infile)
            print(temp_data);
        with open('{output}', 'w') as file:
            file.write(json.dumps(temp_data))
        """
