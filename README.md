# Setup

## Linux setup with an nvidia GPU
### OPTION 1 : install the nvidia drivers locally

~~~
https://www.tecmint.com/install-nvidia-drivers-in-linux/#Method_1_Installing_NVIDIA_Drivers_Using_RPM_Fusion_in_Fedora
~~~
=> also install the NVIDIA VAAPI/VDPAU Driver (see end of article)

### Install cuda

Cf https://rpmfusion.org/Howto/CUDA#Installation

~~~bash
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
sudo dnf clean all
sudo dnf -y install cuda
~~~

### OPTION 2 : install the nvidia drivers for containers

Cf https://hub.docker.com/r/ollama/ollama
Cf https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installation
Cf https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html

~~~bash
sudo dnf install -y nvidia-container-toolkit
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
~~~


## Install podman-compose

~~~bash
sudo dnf install -y podman-compose
~~~


## Setup the database and ollama containers

Define the PGDATA_HOST_DIR and OLLAMA_HOST_DIR variables.
either use a .env file or export the variables directly.
For instance :

~~~bash
cat >.env <<EOF
PGDATA_HOST_DIR=/data/llm_plgrnd/pgdata
OLLAMA_HOST_DIR=/data/llm_plgrnd/ollama_data
EOF
~~~

**NB** : if not defined, the variables default to "pgdata"
         and "ollama_data" in the current directory

Start the containers :

~~~bash
mkdir pgdata
podman-compose up -d
~~~

Next, import the otrs database and prepare the schema :

~~~bash
psql -h localhost -U postgres -f <dump>
./00_prepare.sh
~~~

Generate the vector embeddings :
~~~bash
./01_generate_embeddings.sh
~~~


# Search the top n most relevant tickets to a ticket

~~~bash
./query.sh -t|--ticket <ticket_number> [-n|--limit <limit>] <-p|--print-conversation>
~~~


# Search the top n most relevant tickets relative to a query

~~~bash
./query.sh -q|--prompt <your_request> [-n|--limit <limit>] <-p|--print-conversation>
~~~


# Query an LLM and get a response based on the tickets

Work in progress...

