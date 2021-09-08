---
title: What is Rabbit MQ?
date: 2018-01-21
author: Dung Nguyen
tags: ["others", "tech"]
---

## 1. What is Rabbit MQ?

> Rabbit MQ is an server application, it is a message broker which implement AMQP (Advanced Message Queue Protocol).
> It works like a post service, which take the message from sender and dispatch that message to the receiver.

**Some terminologies:**

* `Producer`: send message to queue
* `Queue`: hold all message added by producer and dispatch those message to a consumer
* `Consumer`: receive message from

## 2. What is Rabbit MQ used for?

RabbitMQ is a message broker server that receive and dispatch/distribute messages to back end services that handle/process heavy tasks. It helps to build a big system can handle large amount of request

## 3. Features list

**Reliability**  
RabbitMQ offers a variety of features to let you trade off performance with reliability, including persistence, delivery acknowledgements, publisher confirms, and high availability.

**Flexible Routing**  
Messages are routed through exchanges before arriving at queues. RabbitMQ features several built-in exchange types for typical routing logic. For more complex routing you can bind exchanges together or even write your own exchange type as a plugin.

**Clustering**  
Several RabbitMQ servers on a local network can be clustered together, forming a single logical broker.

**Federation**  
For servers that need to be more loosely and unreliably connected than clustering allows, RabbitMQ offers a federation model.

**Highly Available Queues**  
Queues can be mirrored across several machines in a cluster, ensuring that even in the event of hardware failure your messages are safe.

**Multi-protocol**  
RabbitMQ supports messaging over a variety of messaging protocols.

**Many Clients**  
There are RabbitMQ clients for almost any language you can think of.

**Management UI**  
RabbitMQ ships with an easy-to use management UI that allows you to monitor and control every aspect of your message broker.

**Tracing**  
If your messaging system is misbehaving, RabbitMQ offers tracing support to let you find out what's going on.

## 3.Bis. Implement models

### 1. **Supported Model**

* **Default exchange**  
  Message from Producer will be pushed directly to message queue and Consumber will receive message on the same queue.
  Producer and Consumer must know the name of the queue

* **Fanout exchange**  
  Every message is pushed to Fanout exchange,it will be pushed to all all queues which subscribe this Exchange

* **Direct exachange**  
  If a Consumer only want to filter received message, it will bind to one or many routing_key. When Exchange have new message, it will append that message to all queue which subscribe same routing_key with message. If message's routing key does not match any subscriber, it will be discarded

* **Topic exchange**  
  This type of exchange allow more complicated filter, it use pattern to filter topic. Topic string format contains many words and separate by dot [.]
  \# to replace 0 or many words \* to replace exactly one word
  **Example**:  
  publish topic: kern.logs.error, security.log.warning
  pattern: \*.\*.error, kern.\#

* **Headers exchange**

### 2. **Direct message:**

> Producer send message directy to message queue
> To send message direct to queue, set exchange name to empty string
> Many consumer can subcribe same queue. Message will be dispatched using FIFO rule

**Producer**

```python
channel.basic_publish(exchange='',
					  routing_key='routing_name',
                      body='message_content')
```

**Consumer**

```python
channel.basic_consume(callback, # callback function to handle message
						queue='queue_name'
                        no_ack=True)
```

{{< mermaid >}}
graph LR;
A((Producer))-->Q[queue];
Q --> C((Consumer 1));
Q --> C2((Consumer 2));
Q --> C3(( ......));
{{< /mermaid >}}

### 3. **Publish message via Exchange**(publish/subcribe)

**Exchange**: acts like an agent, it receives messages from Producer and pushes them to appropriate queue.
The idea of exchange is to separate Producer from queues. Producers do not need to know about queues, it simply sends message to exchange, and Exchanges will know how/ which queue to append message to or discard them.

> Routing key comes with publish and subscribe. Instead of knowing name of queue, producer now only need know routing key, it sends messages to Exchange with routing key. Each time Exchange receives a message, it will check message's routing key and push that message to all Consumer which subscribe that routing key.

{{< mermaid >}}
graph LR;
P1((P1))-->E(Exchange);
P2((P2))-->E;
E-->|Black|Q1[Queue1];
E-->|Green|Q2[Queue2];
E-->|Blue|Q2[Queue2];
Q1-->C1((C1));
Q2-->C2((C2));
{{< /mermaid >}}

**Producer**

```python
# firs we need to declare an exchange
# four types of exchange: fanout, headers, topic, direct
channel.exchange_declare(exchange='exchange_name',
						type='exchange_type')
....
channel.basic_publish(exchange='exchange_name',
						routing_key='channel_name',
                        body='message_content')
....
```

**Consumer**

```python
channel.exchange_declare(exchange='exchange_name',
						type='exchange_type')
....
# need to bind queue to a specific exchange
channel.queue_bind(exchange='exchange_name',
					queue='queue_name')
....
channel.basic_consume(callback,
					queue='queue_name',
                    no_ack=True)
```

4. **RPC**

   > Client send request to Server, Method is defined at server and Client should know exactly which function server has.
   > Client push request to a queue and server subscribe this queue
   > Server push result to another queue and clien subscribe this queue

   {{< mermaid >}}
   graph LR
   C((Client))-->Q1[request queue]
   Q1--> S((Server))
   Q2[result queue] -->C
   S--> Q2
   style C fill:orange
   style S fill:pink
   {{< /mermaid >}}

##4. Use case

* [Sound cloud](https://developers.soundcloud.com/blog/building-products-at-soundcloud-part-1-dealing-with-the-monolith)

##5. References

* [Install instruction](http://www.rabbitmq.com/download.html)
* Tutorial [page](http://www.rabbitmq.com/tutorials/tutorial-one-python.html)
* ==**[AMQP concept](https://www.rabbitmq.com/tutorials/amqp-concepts.html)**==
  ##6. Conclusion
