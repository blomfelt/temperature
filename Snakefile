SENSORS = ['25765'] #Just need to specify one of them?

rule all:
    input:
        expand("data/sensor_{sensorID}.json", sensorID = SENSORS),
        "data/test.txt",
        "values.tsv"

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

rule copy_values:
    output:
        "old_values.tsv"
    shell:
        "cp values.tsv old_values.tsv"

rule add_new_data:
    input:
        script = "code/read_json.R",
        data = expand("data/sensor_{sensorID}.json", sensorID = SENSORS),
        val = "old_values.tsv"
    output:
        "values.tsv"
    shell:
        """
        cp old_values.tsv values.tsv
        Rscript ./{input.script}
        """