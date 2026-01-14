################################################
# Common
################################################
. broker-helper.sh

################################################
# Set Broker Build Config
################################################
echo "## Config Broker Build args..."

BROKER_BUILD_ARGS=$(brokerBuildArgs)

echo "---"
echo ""

################################################
# Build artemis activemq broker
################################################
echo "## Checking if Activemq Artemis Exists..."
BROKER_EXISTS=$(ls $ARTEMIS_INSTANCE_BIN_FOLDER/artemis 2>/dev/null)
if [ -n "$BROKER_EXISTS" ]; then
    echo "- Broker already created - step is skipped"
else
    artemis-build create ${BROKER_BUILD_ARGS} ${ARTEMIS_INSTANCE_FOLDER}
    echo "- Activemq Artemis created"
fi
echo "---"
echo ""

