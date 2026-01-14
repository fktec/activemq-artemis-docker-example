
################################################
# Set Broker Config
################################################
. broker-helper.sh
. broker-config.sh

################################################
# Set Broker Run Config
################################################
echo "## Config Broker Run args..."

export JAVA_ARGS=$(javaArgs)

echo "---"
echo ""

################################################
# Start ActiveMQ Artemis
################################################
echo "## Starting Activemq Artemis..."
artemis run

echo "---"
echo ""
