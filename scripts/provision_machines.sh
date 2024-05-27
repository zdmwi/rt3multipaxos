#! /usr/bin/env bash

# Usage: provision_machines.sh <num-instances>

ZONE="us-east1-b"

COMPUTE_NAME_PATTERN="vm##"
COMPUTE_COUNT=$1
COMPUTE_MACHINE_TYPE="e2-standard-2"
COMPUTE_IMAGE_PROJECT="ubuntu-os-cloud"
COMPUTE_IMAGE_FAMILY="ubuntu-2204-lts"
COMPUTE_STARTUP_SCRIPT="scripts/startup.sh"
COMPUTE_DRIVER_STARTUP_SCRIPT="scripts/driver-startup.sh"

# maybe teardown previous filestore instance?
NUM_STEPS=4

# create the machines
echo "Step 1/${NUM_STEPS}: Creating ${COMPUTE_COUNT} virtual machines..."

# create the client node
gcloud compute instances create vm00 \
    --zone=${ZONE} \
    --machine-type=${COMPUTE_MACHINE_TYPE} \
    --image-project=${COMPUTE_IMAGE_PROJECT} \
    --image-family=${COMPUTE_IMAGE_FAMILY} \
    --metadata-from-file=startup-script=${COMPUTE_STARTUP_SCRIPT} \
    --metadata=filestore-ip=${FILESTORE_IP_ADDRESS}

# create the participating nodes
gcloud compute instances bulk create \
    --name-pattern=${COMPUTE_NAME_PATTERN} \
    --zone=${ZONE} \
    --count=${COMPUTE_COUNT} \
    --machine-type=${COMPUTE_MACHINE_TYPE} \
    --image-project=${COMPUTE_IMAGE_PROJECT} \
    --image-family=${COMPUTE_IMAGE_FAMILY} \
    --metadata-from-file=startup-script=${COMPUTE_STARTUP_SCRIPT} \
    --metadata=filestore-ip=${FILESTORE_IP_ADDRESS}

echo "Step 2/${NUM_STEPS}: Deploying binaries to machines..."

sleep 20

gcloud compute scp bin/client config/gcs_config.json vm00:
for num in $( seq 1 $COMPUTE_COUNT)
do
    gcloud compute scp bin/server vm$(printf %02d $num):
done

echo "Step 3/${NUM_STEPS}: Starting binaries across machines..."
for num in $( seq 1 $COMPUTE_COUNT)
do
    SERVER_ID="vm$(printf %02d $num)"
    gcloud compute ssh ${SERVER_ID} --command="./server -id ${SERVER_ID} -algorithm=paxos"
done

echo "Step 4/${NUM_STEPS}: Starting client binary..."
gcloud compute ssh vm00 --command="./client -id vm00 -config gcs_config.json"

echo "FINISHED!"