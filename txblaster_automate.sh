#!/bin/bash

echo "############ read values from .conf file ###################"
echo ""

port=$(awk '/^port=/ {print substr($1,6)}' ~/.bitcoin/bitcoin.conf)
rpcport=$(awk '/^rpcport=/ {print substr($1,9)}' ~/.bitcoin/bitcoin.conf)
rpcuser=$(awk '/^rpcuser=/ {print substr($1,9)}' ~/.bitcoin/bitcoin.conf)
rpcpwd=$(awk '/^rpcpassword=/ {print substr($1,13)}' ~/.bitcoin/bitcoin.conf)


echo "Step 1: stop node if running"
~/sv/src/bitcoin-cli -conf=/home/mike/.bitcoin/bitcoin.conf stop

sleep 10

echo "Step 2: remove regtest folder"

rm -r ~/.bitcoin/regtest

sleep 10

echo "Step 3: start up bsv node"

~/sv/src/bitcoind -genesisactivationheight=100 -maxstdtxvalidationduration=1000 -maxnonstdtxvalidationduration=5000 -maxscriptsizepolicy=0 -excessiveblocksize=0 -maxstackmemoryusageconsensus=0  -daemon
sleep 30

echo "Step 4: generate empty blocks"
~/sv/src/bitcoin-cli -conf=/home/mike/.bitcoin/bitcoin.conf generate 200
sleep 10

echo "Step 5: grab new address"
newaddr=$(~/sv/src/bitcoin-cli -conf=/home/mike/.bitcoin/bitcoin.conf getnewaddress)

echo "new address is  " $newaddr

sleep 10

echo "Step 6: dump out private key from address"
dumpkey=$(~/sv/src/bitcoin-cli -conf=/home/mike/.bitcoin/bitcoin.conf dumpprivkey $newaddr)

echo "private key is " $dumpkey

sleep 10

echo "Step 7: send coins to address"
addr=$(~/sv/src/bitcoin-cli -conf=/home/mike/.bitcoin/bitcoin.conf sendtoaddress $newaddr 200) 
sleep 10

#echo "txn is " $addr

echo "Step 8: get raw txn for funding"
rawtxn=$(~/sv/src/bitcoin-cli -conf=/home/mike/.bitcoin/bitcoin.conf getrawtransaction $addr) 

echo "raw txn is " $rawtxn


echo "Step 9: create json file for txblaster"

echo "{" >> generate.json
echo "\""networkType\"": \""RegTest\"", " >> generate.json
echo "\""savePathRoot\"": \""/root/sv\""," >> generate.json
echo "\""fundingPrivateKeyWIF\"": \""$dumpkey\"", " >> generate.json
echo "\""fundingTransaction\"": \""$rawtxn\"", " >> generate.json
echo "\""numberOfInputsPerTransaction\"": 1, " >> generate.json
echo "\""numberOfOutputsPerTransaction\"": 2, " >> generate.json
echo "\""numberOfTransactionsToGenerate\"": 100000, " >> generate.json
echo "" >> generate.json
echo "\""verifyRpcNodeParameters\"": {" >> generate.json
echo "          \""rpcAddress\"":  \""127.0.0.1:$rpcport\""," >> generate.json
echo "		\""user\"": \""$rpcuser\"", " >> generate.json
echo "          \""password\"": \""$rpcpwd\"" " >> generate.json
echo "	}," >> generate.json
echo "" >> generate.json
echo "\""adaptersConfig\"": [" >> generate.json
echo "	{" >> generate.json
echo "		\""announceTransactions\"": false, " >> generate.json
echo "		\""peerDiscovery\"": \""None\"", " >> generate.json
echo "          \""connectToPeers\"": [ \""127.0.0.1:$port\"" ]" >> generate.json
echo "		}" >> generate.json
echo "	]," >> generate.json
echo "" >> generate.json
echo "\""submitLastBatch\"": false, " >> generate.json
echo "\""sessionName\"": \""100k_txns\"", " >> generate.json
echo "\""logToConsole\"": true, " >> generate.json 
echo "\""privateKeysFile\"": \""524K_privateKeysWithPublic.txt\"" " >> generate.json
echo "" >> generate.json
echo "}" >> generate.json

echo ""
echo "Finished!!!!"



