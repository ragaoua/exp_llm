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


## Setup the database and python environment

Start the db and python environment containers :

~~~bash
mkdir pgdata
podman-compose up -d
~~~

Optionally, only run the database container and create a python venv.
The venv is useful for executing the python scripts on your machine
directly instead of a container, which makes it easier to take
advantage of the hardware (e.g, Silicon chips as 'mps') :

~~~bash
mkdir pgdata
podman-compose up db -d
python -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
~~~

Keep in mind that, if you choose to go with a container for the python environment,
every execution of the python script from now on should be done inside said container (named
"otrs_app"). If you choose to go with the venv, the script should be executed through that venv.

So either this :

~~~bash
source venv/bin/activate
python <script> <options...>
~~~

Or this :

~~~bash
podman exec -it otrs_app python <script> <options...>
~~~

Also, if running the scripts though the venv, you'll need to change the "host" variable
inside the function "get_pg_connection" ("lib/connect.py") from "db" to "localhost".
Whatever method you choose, "localhost" works on Linux but not on Unix systems (MacOS),
due to limitations with the network stack caused by the podman virtual machine.

Next, import the otrs database and prepare the schema :

~~~bash
psql -h localhost -U postgres -f <dump>
./prepare.sh
~~~

Generate the vector embeddings :

~~~bash
podman exec -it otrs_app python generate_embeddings.py
~~~


# Search the top 5 most relevant tickets to a ticket

~~~bash
podman exec -it otrs_app python get_relevant_tickets.py <ticket_number> [DEBUG]
~~~


# Search the top 5 mort relevant tickets relative to a query

~~~bash
podman exec -it otrs_app python query.py <my_query> [DEBUG]
~~~


# Query an LLM and get a response based on the tickets

Work in progress...

~~~bash
PYTORCH_ENABLE_MPS_FALLBACK=1 python rag.py <my_query>
~~~



~~~bash
~~~
