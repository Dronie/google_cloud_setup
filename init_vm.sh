#!/bin/bash
set -e

# Get Metadata for self-deletion
export INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)
export ZONE_FULL=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone)
export ZONE=${ZONE_FULL##*/}
export PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)

# Set variables 
GH_USR="" # your GitHub Username
GH_PAT="" # A GitHub Personal Access Token
WANDB_KEY="" # your WANDB API key

# set up the environment
cd /
apt-get -y update
apt-get -y install git
apt-get -y install python3-pip
apt-get -y install python3.10-venv
mkdir Code && cd Code/
git clone https://$GH_USR:$GH_PAT@github.com/Dronie/Sequential-Partner-Choice.git
cd Sequential-Partner-Choice/
python3 -m venv .venv
source .venv/bin/activate
pip install jaxmarl==0.0.5
pip install -e .
export PYTHONPATH=./JaxMARL:$PYTHONPATH
pip install -r requirements.txt
pip install "jax[cuda12]"
export WANDB_API_KEY=$WANDB_KEY

# run the experiment
python3 baselines/IPPO/ippo_ff_coin_game_no_ps_pc.py

# wait 10 seconds just for any residual stuff to finish off
sleep 10

# delete the VM (Need full access to all Cloud APIs for this)
gcloud compute instances delete "$INSTANCE_NAME" --zone="$ZONE" --project="$PROJECT_ID" --quiet
