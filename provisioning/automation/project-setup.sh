#!/bin/bash
set -e
source provisioning/automation/bashhelpers.sh

PARENT_PROJECT=$(gcloud config get-value project)

while getopts f:p:b:r:s: flag; do
    case "${flag}" in
    f) PARENT_FOLDER=${OPTARG} ;;
    p) CI_PROJECT=${OPTARG} ;;
    b) BILLING_ACCOUNT_ID=${OPTARG} ;;
    r) REGION=${OPTARG} ;;
    s) SA_NAME=${OPTARG} ;;
    esac
done


if [[ -z $PARENT_FOLDER ]]; then
    export PARENT_FOLDER=$(gcloud projects describe ${PARENT_PROJECT} --format="value(parent.id)")
    echo "🔍 Found folder ${PARENT_FOLDER} from ${PARENT_PROJECT}"
else
    echo "📦 Using provided folder $PARENT_FOLDER"
fi

if [[ -z $CI_PROJECT ]]; then
    CI_PROJECT_PREFIX=avocano-test
    RANDOM_IDENTIFIER=$((RANDOM % 999999))
    CI_PROJECT=$(printf "%s-%06d" $CI_PROJECT_PREFIX $RANDOM_IDENTIFIER)-${TEST_TYPE:=manual}
fi

if [[ -z $REGION ]]; then
    REGION=us-central1
fi

SA_EMAIL=$(gcloud iam service-accounts list  --project ${PARENT_PROJECT} --filter $SA_NAME --format 'value(email)')
TF_STATE_BUCKET=${CI_PROJECT}-tfstate

echo "🚀 Running setup using $TEST_TYPE on $CI_PROJECT in $REGION with $SA_EMAIL"

if gcloud projects list --filter $CI_PROJECT | grep -q "$CI_PROJECT"; then
    echo "🔁 Reusing ${CI_PROJECT}"
else
    stepdo "🔨 create CI project $CI_PROJECT in folder $PARENT_FOLDER"
    gcloud projects create ${CI_PROJECT} --folder ${PARENT_FOLDER}
    stepdone

    stepdo "assign IAM policies to service account"
    for role in cloudbuild.builds.editor iam.serviceAccountTokenCreator iam.serviceAccountUser billing.projectManager; do
    quiet gcloud projects add-iam-policy-binding $CI_PROJECT \
        --member serviceAccount:${SA_EMAIL} \
        --role roles/${role}
    done
    stepdone

    stepdo "setup billing"
    if [[ -z $BILLING_ACCOUNT_ID ]]; then
        echo "Using billing account associated to parent project"
        BILLING_ACCOUNT=$(gcloud beta billing projects describe ${PARENT_PROJECT} --format="value(billingAccountName)" || sed -e 's/.*\///g')
    else
        echo "Using supplied billing account"
        BILLING_ACCOUNT=billingAccounts/$BILLING_ACCOUNT_ID
    fi

    gcloud beta billing projects link ${CI_PROJECT} --billing-account=${BILLING_ACCOUNT}
    stepdone

    stepdo "enable services on ci project"
    gcloud services enable --project $CI_PROJECT \
        cloudresourcemanager.googleapis.com \
        containerregistry.googleapis.com \
        cloudbuild.googleapis.com \
        cloudbilling.googleapis.com \
        iam.googleapis.com
    stepdone

    stepdo "assign IAM owner role to Cloud Build service account"
    CI_PROJECTNUMBER=$(gcloud projects describe ${CI_PROJECT} --format='value(projectNumber)')
    CLOUDBUILD_SA=$CI_PROJECTNUMBER@cloudbuild.gserviceaccount.com
    quiet gcloud projects add-iam-policy-binding $CI_PROJECT \
        --member serviceAccount:${CLOUDBUILD_SA} \
        --role roles/owner
    stepdone

    stepdo "assign Log Bucket writer to Cloud Build service account"
    LOGS_BUCKET=gs://${PARENT_PROJECT}-buildlogs
    gsutil iam ch \
        serviceAccount:${CLOUDBUILD_SA}:roles/storage.admin \
        $LOGS_BUCKET
    stepdone

    stepdo "setup Terraform bucket"
    gsutil mb -p ${CI_PROJECT} gs://$TF_STATE_BUCKET
    echo "Created $TF_STATE_BUCKET bucket"

    echo ""
    echo "✅ Project '${CI_PROJECT}' is now ready to use."
    echo ""
fi