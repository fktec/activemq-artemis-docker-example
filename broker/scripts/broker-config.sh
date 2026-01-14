################################################
# Broker default files
################################################
echo "## Checking if has default files..."
ARTEMIS_INSTANCE_DEFAULT_EXISTS=$(ls "$ARTEMIS_INSTANCE_DEFAULT_FOLDER" 2>/dev/null)
if [ -n "$ARTEMIS_INSTANCE_DEFAULT_EXISTS" ]
then
    cp -r ${ARTEMIS_INSTANCE_DEFAULT_FOLDER}/. ${ARTEMIS_INSTANCE_FOLDER}/
    rm -rf ${ARTEMIS_INSTANCE_DEFAULT_FOLDER}
    echo "- Updated broker default files"
else
    echo "- There is no default files for the broker - step is skipped." 
fi
echo "---"
echo ""

################################################
# Broker custom files
################################################
echo "## Checking if has custom files..."
ARTEMIS_CUSTOM_FILES_EXISTS=$(ls "$ARTEMIS_INSTANCE_CUSTOM_FOLDER" 2>/dev/null)
if [ -n "$ARTEMIS_CUSTOM_FILES_EXISTS" ]
then
    cp -r ${ARTEMIS_INSTANCE_CUSTOM_FOLDER}/. ${ARTEMIS_INSTANCE_FOLDER}/
    rm -rf ${ARTEMIS_INSTANCE_CUSTOM_FOLDER}
    echo "- Updated broker files"
else
    echo "- There is no custom files for the broker - step is skipped."
fi
echo "---"
echo ""

################################################
# Clear tmp folder
################################################
echo "## Clearing the instance's temporary folder..."
ARTEMIS_INSTANCE_TMP_FOLDER="$ARTEMIS_INSTANCE_FOLDER/tmp"
ARTEMIS_INSTANCE_FOLDER_TMP_EXISTS=$(ls "$ARTEMIS_INSTANCE_TMP_FOLDER" 2>/dev/null)
if [ -n "$ARTEMIS_INSTANCE_FOLDER_TMP_EXISTS" ]
then
    rm -rf ${ARTEMIS_INSTANCE_TMP_FOLDER}
    echo "- The instance's temporary folder was successfully cleared."
else
    echo "- There are no temporary files for the cleaning - step is skipped."
fi
echo "---"
echo ""