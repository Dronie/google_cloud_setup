#!/bin/bash
# first argument passed to this script will be the seed
set -e

# set seed variable (with default value of 0)
# used to seed the prng for experiments
SEED=${1:-0}

# Get Metadata for self-deletion
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)
ZONE_FULL=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone)
ZONE=${ZONE_FULL##*/}
PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)

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
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq

# clone the repo
git clone https://$GH_USR:$GH_PAT@github.com/Dronie/Sequential-Partner-Choice.git

# set up python env and correct dependencies
yq -i ".SEED = $SEED" /Sequential-Partner-Choice/baselines/IPPO/config/ippo_ff_coin_game.yaml
python3 -m venv .venv
source .venv/bin/activate
pip install jaxmarl==0.0.5
pip install -e Sequential-Partner-Choice/
export PYTHONPATH=Sequential-Partner_Choice/JaxMARL:$PYTHONPATH
pip install -r Sequential-Partner-Choice/requirements.txt
pip install "jax[cuda12]"
export WANDB_API_KEY=$WANDB_KEY

# run the experiment
python3 Sequential-Partner-Choice/baselines/IPPO/ippo_ff_coin_game_no_ps_pc.py

# wait 10 seconds just for any residual stuff to finish off
sleep 10

# delete the VM (Need full access to all Cloud APIs for this)
gcloud compute instances delete "$INSTANCE_NAME" --zone="$ZONE" --project="$PROJECT_ID" --quiet
