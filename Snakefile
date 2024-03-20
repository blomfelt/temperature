SENSORS = ['25765'] #Just need to specify one of them?

rule all:
    input:
        expand("data/sensor_{sensorID}.json", sensorID = SENSORS),
        "data/values.tsv",
        "visuals/day_temp.png",
        "visuals/max_temp.png",
        "index.html"

rule get_sensor_data:
    input:
        script = "code/get_sensor_data.bash"
    output:
        "data/sensor_{id}.json"
    conda:
        "environment.yml"
    shell:
        "bash ./{input.script}"

rule copy_values:
    output:
        "data/old_values.tsv"
    conda:
        "environment.yml"
    shell:
        "cp data/values.tsv data/old_values.tsv"

rule add_new_data:
    input:
        script = "code/read_json.R",
        data = expand("data/sensor_{sensorID}.json", sensorID = SENSORS),
        val = "data/old_values.tsv"
    output:
        "data/values.tsv"
    conda:
        "environment.yml"
    shell:
        """
        cp data/old_values.tsv data/values.tsv
        Rscript ./{input.script}
        """

rule visualize_data:
    input:
        script = "code/visualize_temp.R",
        data = "data/values.tsv"
    output:
        day_temp = "visuals/day_temp.png",
        max_temp = "visuals/max_temp.png"
    conda:
        "environment.yml"
    shell:
        """
        ./{input.script}
        """

rule create_html:
    input:
        script = "index.Rmd",
        png = "visuals/day_temp.png"
    output:
        "index.html"
    conda:
        "environment.yml"
    shell:
        """
        R -e "library(rmarkdown); render('{input.script}')" 
        """