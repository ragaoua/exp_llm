# Setup


## On Linux - Install the nvidia drivers

~~~
https://www.tecmint.com/install-nvidia-drivers-in-linux/#Method_1_Installing_NVIDIA_Drivers_Using_RPM_Fusion_in_Fedora
~~~
=> also installed the NVIDIA VAAPI/VDPAU Driver (see end of article)


## On Linux - Install cuda

Cf https://rpmfusion.org/Howto/CUDA#Installation

~~~bash
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
sudo dnf clean all
sudo dnf -y install cuda
~~~


## Start the app and db containers

~~~bash
mkdir pgdata
podman-compose up -d
~~~

## Import the otrs database

~~~bash
psql -h localhost -U postgres -f <dump>
~~~

## Prepare the database

~~~bash
bash prepare.sh
~~~


## Generate the vector embeddings

NB : the "generate_embeddings.py" script can load the embedding model
     into a MacOs M2 chip but that's commented since we're using
     containers

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
