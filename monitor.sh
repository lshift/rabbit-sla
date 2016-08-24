#!/bin/bash
MONITORING_INTERVAL=10
MAX_MESSAGE_WAIT_TIME=120
ADMIN_EMAIL=

while :
do
    sudo rabbitmqctl -q list_queues name head_message_timestamp | while read QNAME QHEAD_MESSAGE_TIMESTAMP
    do
        if [ -z $QHEAD_MESSAGE_TIMESTAMP ]
        then
            echo "Queue $QNAME: head message has no timestamp"
        else
            echo "Queue $QNAME: head message timestamp `date -d @$QHEAD_MESSAGE_TIMESTAMP`"
            if (( `date +%s` > QHEAD_MESSAGE_TIMESTAMP + MAX_MESSAGE_WAIT_TIME )); then
                echo "===> Alert: Queue $QNAME: message waiting since `date -d @$QHEAD_MESSAGE_TIMESTAMP`" 
                if [ -n "$ADMIN_EMAIL" ]; then
                    mail -s "RabbitMQ Consumer Alert" $ADMIN_EMAIL
                fi
            fi
        fi
    done
    sleep $MONITORING_INTERVAL
done
