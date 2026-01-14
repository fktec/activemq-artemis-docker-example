################################################
# Common Functions
################################################
debugPrint() {
    PRINT_VALUE="$1"
    if [ "$DEBUG_ENABLED" = "true" ]; then
        echo "[DEBUG]: $PRINT_VALUE" >&2 
    fi
}

loginEnabled() {
    [ "$AMQ_LOGIN_ENABLED" = "true" ]
}

sslEnabled() {
    [ "$AMQ_SSL_ENABLED" = "true" ]
}

sslFolderPath() {
    SSL_FOLDER_PATH="${ARTEMIS_INSTANCE_SSL_FOLDER}"
    if [ -n "$AMQ_KEYSTORE_TRUSTSTORE_DIR" ]; then
        SSL_FOLDER_PATH="${AMQ_KEYSTORE_TRUSTSTORE_DIR}"
    fi
    echo "$SSL_FOLDER_PATH"
}

sslKeyStorePath() {
    SSL_DIR=$(sslFolderPath)
    if [ -n "$SSL_DIR" ] && [ -n "$AMQ_KEYSTORE" ]; then
        KEYSTORE_PATH="$SSL_DIR/$AMQ_KEYSTORE"
        echo "$KEYSTORE_PATH"
    fi
}

sslTrustStorePath() {
    SSL_DIR=$(sslFolderPath)
    if [ -n "$SSL_DIR" ] && [ -n "$AMQ_TRUSTSTORE" ]; then
        TRUSTSTORE_PATH="$SSL_DIR/$AMQ_TRUSTSTORE"
        echo "$KEYSTORE_PATH"
    fi
}

brokerInstanceFolderPath() {
    echo "$ARTEMIS_INSTANCE_FOLDER"
}

################################################
# Broker Arguments
################################################
brokerBuildArgs() {
    # Arguments - BROKER
    if [ -n "$AMQ_NAME" ]; then
        BROKER_REF_ARGS="${BROKER_REF_ARGS} --name $AMQ_NAME"
    fi
    if [ -n "$ADMIN_ROLE" ]; then
        BROKER_REF_ARGS="${BROKER_REF_ARGS} --role $ADMIN_ROLE"
    fi

    # Arguments - LOGIN
    if loginEnabled; then
        LOGIN_ARGS="--require-login"

        if [ -n "$AMQ_USER" ]; then
            LOGIN_ARGS="${LOGIN_ARGS} --user ${AMQ_USER}"
        fi
        if [ -n "$AMQ_PASSWORD" ]; then
            LOGIN_ARGS="${LOGIN_ARGS} --password ${AMQ_PASSWORD}"
        fi
    fi

    # Arguments - SSL
    if sslEnabled; then        
        # KEYSTORE
        KEYSTORE_PATH=$(sslKeyStorePath)
        if [ -n "$KEYSTORE_PATH" ] && [ -n "$AMQ_KEYSTORE" ] && [ -n "$AMQ_KEYSTORE_PASSWORD" ]; then
            SSL_ARGS="${SSL_ARGS} --ssl-key $KEYSTORE_PATH"
            SSL_ARGS="${SSL_ARGS} --ssl-key-password $AMQ_KEYSTORE_PASSWORD"
        fi
        # TRUSTSTORE
        TRUSTSTORE_PATH=$(sslTrustStorePath)
        if [ -n "$TRUSTSTORE_PATH" ] && [ -n "$AMQ_TRUSTSTORE" ] && [ -n "$AMQ_TRUSTSTORE_PASSWORD" ]; then
            SSL_ARGS="${SSL_ARGS} --ssl-trust $TRUSTSTORE_PATH"
            SSL_ARGS="${SSL_ARGS} --ssl-trust-password $AMQ_TRUSTSTORE_PASSWORD"
        fi
    fi

    BROKER_BUILD_ARGS="${BROKER_REF_ARGS} ${LOGIN_ARGS} ${SSL_ARGS} ${EXTRA_ARGS}"
    debugPrint "BROKER_BUILD_ARGS = ${BROKER_BUILD_ARGS}"

    echo "${BROKER_BUILD_ARGS}"
}

################################################
# Java Arguments
################################################
javaArgs() {
    # Arguments - BROKER
    JAVA_BROKER_REF_ARGS="-DARTEMIS_INSTANCE_FOLDER=$(brokerInstanceFolderPath)"

    if [ -n "$AMQ_NAME" ]; then
        JAVA_BROKER_REF_ARGS="${JAVA_BROKER_REF_ARGS} -DAMQ_NAME=$AMQ_NAME"
    fi
    if [ -n "$AMQ_CONFIG_MIN_LARGE_MESSAGE_SIZE" ]; then
        JAVA_BROKER_REF_ARGS="${JAVA_BROKER_REF_ARGS} -DAMQ_CONFIG_MIN_LARGE_MESSAGE_SIZE=$AMQ_CONFIG_MIN_LARGE_MESSAGE_SIZE"
    fi

    # Arguments - LOGIN
    if loginEnabled; then
        if [ -n "$AMQ_USER" ]; then
            JAVA_LOGIN_ARGS="-DAMQ_USER=$AMQ_USER"
        fi
    fi

    # Arguments - SSL
    if sslEnabled; then
        JAVA_SSL_ARGS="-DAMQ_SSL_ENABLED=$AMQ_SSL_ENABLED"
        SSL_ACCEPTORS_ARGS="sslEnabled=${AMQ_SSL_ENABLED}"

        KEYSTORE_PATH=$(sslKeyStorePath)
        if [ -n "$KEYSTORE_PATH" ] && [ -n "$AMQ_KEYSTORE" ] && [ -n "$AMQ_KEYSTORE_PASSWORD" ]; then
            JAVA_SSL_ARGS="${JAVA_SSL_ARGS} -DKEYSTORE_PATH=$KEYSTORE_PATH"
            JAVA_SSL_ARGS="${JAVA_SSL_ARGS} -DAMQ_KEYSTORE_PASSWORD=$AMQ_KEYSTORE_PASSWORD"
            SSL_ACCEPTORS_ARGS="${SSL_ACCEPTORS_ARGS};keyStorePath=${KEYSTORE_PATH}"
        fi

        TRUSTSTORE_PATH=$(sslTrustStorePath)
        if [ -n "$TRUSTSTORE_PATH" ] && [ -n "$AMQ_TRUSTSTORE" ] && [ -n "$AMQ_TRUSTSTORE_PASSWORD" ]; then
            JAVA_SSL_ARGS="${JAVA_SSL_ARGS} -DATRUSTSTORE_PATH=$TRUSTSTORE_PATH"
            JAVA_SSL_ARGS="${JAVA_SSL_ARGS} -DAMQ_TRUSTSTORE_PASSWORD=$AMQ_TRUSTSTORE_PASSWORD"
            SSL_ACCEPTORS_ARGS="${SSL_ACCEPTORS_ARGS};keyStorePassword=${AMQ_KEYSTORE_PASSWORD}"
        fi
        
        JAVA_SSL_ARGS="${JAVA_SSL_ARGS} -DSSL_ACCEPTORS_ARGS=$SSL_ACCEPTORS_ARGS"
    fi

    # Arguments - HAWTIO
    if [ -z "$HAWTIO_ROLE_ARGS" ]; then
        HAWTIO_ROLE_ARGS="-Dhawtio.role=$ADMIN_ROLE"
    fi
    HAWTIO_ARGS="${HAWTIO_ARGS} ${HAWTIO_ROLE_ARGS}"

    # Arguments - Java Extra
    if [ -z "$JAVA_EXTRA_ARGS" ]
    then
        JAVA_EXTRA_ARGS="${JAVA_BROKER_REF_ARGS} ${JAVA_LOGIN_ARGS} ${JAVA_SSL_ARGS} ${HAWTIO_ARGS} ${JOLOKIA_ARGS}"
    fi
    
    JAVA_ARGS="${JAVA_DEFAULT_ARGS} ${JAVA_OPTS} ${JAVA_JMX_ARGS} ${JAVA_EXTRA_ARGS} ${JAVA_APPEND_ARGS}"
    debugPrint "JAVA_ARGS = ${JAVA_ARGS}"

    echo "${JAVA_ARGS}"
}
