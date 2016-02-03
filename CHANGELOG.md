## 0.4

Spec:
	
 - The implementations are called processing rules. You should think of them like rules to process method calls.
 - Introduce the concept of a Client Action, the user is able to control the behaviour of the client. ( stop, publish, publish and stop )
 - Remove the concept for trial run. This is replaced by allowing the user to specify what happens after the method call.
 - Null is a valid return value.
 
Implementation suggestion:

 - A processing rule could look like this: `on("sum").call(lambda).then(publish)`
 - Remove PeekAtFirstRequest processing strategy
 - Remove the validate phase from the message processing pipeline
 - Change all the references to implementation map to be processing rules
 - Move the serialization strategy closer to the broker
