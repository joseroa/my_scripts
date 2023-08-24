#!/bin/bash

# Get the current user's AWS account ID
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Set the start and end dates in the format YYYY-MM-DD (date only, no time)
START_DATE="2022-01-01"
END_DATE="2023-12-31"

# Convert start and end dates to seconds since the epoch
START_DATE_SECONDS=$(date -d "$START_DATE" +%s)
END_DATE_SECONDS=$(date -d "$END_DATE" +%s)

# List snapshots owned by the current user's account
SNAPSHOT_IDS=$(aws ec2 describe-snapshots --region "$AWS_REGION" --owner-ids "$AWS_ACCOUNT_ID" --query "Snapshots[?StartTime>='$START_DATE' && StartTime<='$END_DATE'].SnapshotId" --output text)

# Create an output file to temporarily store the snapshot IDs
SNAPSHOT_IDS_FILE="snapshot_ids.txt"
> "$SNAPSHOT_IDS_FILE"  # Clear the contents of the file

# Save snapshot IDs to the temporary file
echo "$SNAPSHOT_IDS" > "$SNAPSHOT_IDS_FILE"


# Create an output file to store the deleted snapshot IDs
OUTPUT_FILE="deleted_snapshots.txt"
> "$OUTPUT_FILE"  # Clear the contents of the file


# Loop through the list of snapshot IDs and delete each snapshot
for SNAPSHOT_ID in $SNAPSHOT_IDS; do
    # Check if the snapshot is associated with any AMIs
    AMI_ASSOCIATIONS=$(aws ec2 describe-images --region "$AWS_REGION" --filters "Name=block-device-mapping.snapshot-id,Values=$SNAPSHOT_ID" --query "Images[*].ImageId" --output text)

    if [ -z "$AMI_ASSOCIATIONS" ]; then
        echo "Deleting snapshot: $SNAPSHOT_ID"
        aws ec2 delete-snapshot --region "$AWS_REGION" --snapshot-id "$SNAPSHOT_ID"
        echo "$SNAPSHOT_ID" >> "$OUTPUT_FILE"  # Append the ID to the output file
    else
        echo "Snapshot $SNAPSHOT_ID is associated with AMIs and won't be deleted."
    fi
done

echo "Deleted snapshot IDs saved to $OUTPUT_FILE"



