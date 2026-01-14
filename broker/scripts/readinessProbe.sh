echo "# Checking artemis status..."

# Define a string exata que indica sucesso, conforme solicitado
EXPECTED_STRING="Checking that the node is started ... success"
 
# Verifica se as variáveis de ambiente necessárias estão definidas
if [ -z "$AMQ_USER" ] || [ -z "$AMQ_PASSWORD" ]; then
    echo "ERRO: As variaveis AMQ_USER e AMQ_PASSWORD precisam estar definidas."
    exit 1
fi
 
# Executa o comando do artemis
# 2>&1 redireciona erros (stderr) para a saída padrão (stdout) para capturarmos tudo
OUTPUT=$(artemis check node --silent --user "$AMQ_USER" --password "$AMQ_PASSWORD" 2>&1)
 
# Verifica se a string esperada está contida na saída do comando
# grep -F trata a string como literal (importante por causa dos "...")
# grep -q faz a busca ser "quiet" (sem imprimir nada, apenas retorna status)
if echo "$OUTPUT" | grep -Fq "$EXPECTED_STRING"; then
    # Sucesso
    exit 0
else
    # Falha
    echo "Health Check FAILED, Output received: "
    echo "$OUTPUT"
    exit 1
fi