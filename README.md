# Setup


## Install the nvidia drivers

~~~
https://www.tecmint.com/install-nvidia-drivers-in-linux/#Method_1_Installing_NVIDIA_Drivers_Using_RPM_Fusion_in_Fedora
~~~

=> also installed the NVIDIA VAAPI/VDPAU Driver (see end of article)


## Install cuda

Cf https://rpmfusion.org/Howto/CUDA#Installation

~~~bash
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
sudo dnf clean all
sudo dnf -y install cuda
~~~


## Setup the python venv

~~~bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
~~~


## Run the database container

~~~bash
mkdir pgdata
podman run -d --name otrs -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 -v ./pgdata:/var/lib/postgresql/data --privileged --shm-size=20g pgvector/pgvector:pg16 -c effective_cache_size=15GB -c shared_buffers=5GB -c work_mem=512MB -c max_parallel_workers_per_gather=4
~~~


## Prepare the database

~~~bash
bash prepare.sh # Creates the materialized view containing
~~~


## Generate the vector embeddings

~~~bash
python generate_embeddings.py
~~~


# Search the top 5 most relevant tickets to a ticket

~~~bash
python get_relevant_tickets.py <ticket_number> [DEBUG]
~~~


# Search the top 5 mort relevant tickets relative to a query

~~~bash
python query.py <my_query> [DEBUG]
~~~

# Query an LLM (RAG)

Work in progres...

~~~bash
python rag.py <my_query>
~~~
