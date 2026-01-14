CLUSTER_NAME="integracao-kaas-non-prd"
GCP_REGION="southamerica-east1"
GCP_PROJECT_ID="gglobo-integration-hml-hdg-dev"

#################################
# BEFORE SCRIPT
#################################

## Login GCloud
SERVICE_ACCOUNT_GCP_FILE="cluster/gcloud/service-account-gglobo-integration-hml-hdg-dev.json"
if [[ $(ls "$SERVICE_ACCOUNT_GCP_FILE") ]]
then
    echo "# Autenticando-se no GCloud..."
    gcloud auth activate-service-account --key-file=$SERVICE_ACCOUNT_GCP_FILE
    echo ""

    echo "# Conectando-se no GCloud >> [CLUSTER]: $CLUSTER_NAME, [REGION]: $GCP_REGION, [PROJECT_ID]: $GCP_PROJECT_ID"
    gcloud container clusters get-credentials $CLUSTER_NAME --region $GCP_REGION --project $GCP_PROJECT_ID
    echo ""
else
    RED_COLOR='\033[0;31m'
    echo -e "${RED_COLOR}# Não foi possível localizar o Service Account utilizado para se logar no GCloud."
    exit 1
fi

#################################
# SCRIPT
#################################

NAMESPACE="componentes-internos-uat"
POD_NAME="health-monitor-event-producer-api"

PODS=($(kubectl get pods -l app.kubernetes.io/name=$POD_NAME -n $NAMESPACE --no-headers -ocustom-columns=NAME:.metadata.name))

if [[ -n $PODS ]]
then
    for POD in "${PODS[@]}";
    do
        echo "# Arquivos customizados transferidos para dentro do broker >> $POD"
    done
else
    echo "# Não foram localizados pods."
fi

#################################
# AFTER SCRIPT
#################################