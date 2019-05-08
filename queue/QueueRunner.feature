Feature: Command and control using a message broker

  Background:
    Given I start with a clean broker having a request and a response queue
    And a client that connects to the queues

  Scenario: Default client setting
    Then the time to wait for requests is 500ms

  #  Message processing rules

  Scenario: Processes requests and publishes responses for various methods
    Given I receive the following requests:
      | payload                                             |
      | {"method":"sum","params":[1,2],"id":"X1"}           |
      | {"method":"echo","params":["Xs"],"id":"X2"}         |
      | {"method":"array_sum","params":[[1,2,3]],"id":"X3"} |
      | {"method":"int_range","params":[1,4],"id":"X4"}     |
    When I go live with the following processing rules:
      | method    | call                         |
      | sum       | add two numbers              |
      | echo      | replay the value             |
      | array_sum | sum the elements of an array |
      | int_range | generate array of integers   |
    Then the client should consume all requests
    And the client should publish the following responses:
      | payload                                   |
      | {"result":3,"error":null,"id":"X1"}       |
      | {"result":"Xs","error":null,"id":"X2"}    |
      | {"result":6,"error":null,"id":"X3"}       |
      | {"result":[1,2,3],"error":null,"id":"X4"} |

  #  Display

  Scenario: Display requests and responses
    Given I receive the following requests:
      | payload                                       |
      | {"method":"sum","params":[1,2],"id":"X1"}     |
      | {"method":"increment","params":[3],"id":"X2"} |
    When I go live with the following processing rules:
      | method    | call             |
      | sum       | add two numbers  |
      | increment | increment number |
    Then the client should display to console:
      | output                                |
      | id = X1, req = sum(1, 2), resp = 3    |
      | id = X2, req = increment(3), resp = 4 |

  Scenario: Handle multi-line request and response
    Given I receive the following requests:
      | payload                                          |
      | {"method":"echo","params":[""],"id":"X1"}        |
      | {"method":"echo","params":["a"],"id":"X2"}       |
      | {"method":"echo","params":["x\ny"],"id":"X3"}    |
      | {"method":"echo","params":["p\nq\nr"],"id":"X4"} |
    When I go live with the following processing rules:
      | method | call             |
      | echo   | replay the value |
    Then the client should display to console:
      | output                                                                       |
      | id = X1, req = echo(""), resp = ""                                           |
      | id = X2, req = echo("a"), resp = "a"                                         |
      | id = X3, req = echo("x .. ( 1 more line )"), resp = "x .. ( 1 more line )"   |
      | id = X4, req = echo("p .. ( 2 more lines )"), resp = "p .. ( 2 more lines )" |

  Scenario: Handle array input and output
    Given I receive the following requests:
      | payload                                             |
      | {"method":"array_sum","params":[[1,2,3]],"id":"X3"} |
      | {"method":"int_range","params":[1,4],"id":"X4"}     |
    When I go live with the following processing rules:
      | method    | call                         |
      | array_sum | sum the elements of an array |
      | int_range | generate array of integers   |
    Then the client should display to console:
      | output                                           |
      | id = X3, req = array_sum([1, 2, 3]), resp = 6    |
      | id = X4, req = int_range(1, 4), resp = [1, 2, 3] |

  #  Cover edge cases

  Scenario: Should consume null requests
    Given I receive the following requests:
      | payload                                   |
      | {"method":"sum","params":[0,1],"id":"X1"} |
    When I go live with the following processing rules:
      | method | call        |
      | sum    | return null |
    Then the client should consume all requests
    And the client should publish the following responses:
      | payload                                |
      | {"result":null,"error":null,"id":"X1"} |

  Scenario: Should not publish any more messages after an exception when processing a message
    Given I receive the following requests:
      | payload                                       |
      | {"method":"increment","params":[1],"id":"X1"} |
      | {"method":"sum","params":[0,1],"id":"X2"}     |
      | {"method":"increment","params":[2],"id":"X3"} |
    When I go live with the following processing rules:
      | method    | call             |
      | increment | increment number |
      | sum       | throw exception  |
    Then the client should consume one request
    And the client should publish one response
    And the client should display to console:
      | output                                                                                    |
      | id = X1, req = increment(1), resp = 2                                                     |
      | id = X2, req = sum(0, 1), error = "user implementation raised exception", (NOT PUBLISHED) |

  Scenario: Should display informative message if method not registered
    Given I receive the following requests:
      | payload                                    |
      | {"method":"random","params":[2],"id":"X1"} |
    When I go live with the following processing rules:
      | method | call            |
      | sum    | add two numbers |
    Then the client should not consume any request
    And the client should display to console:
      | output                                                                                                 |
      | id = X1, req = random(2), error = "method 'random' did not match any processing rule", (NOT PUBLISHED) |

  #  Performance

  Scenario: Should have a decent performance
    Given I receive 50 identical requests like:
      | payload                                        |
      | {"method":"some_method","params":[],"id":"X1"} |
    When I go live with the following processing rules:
      | method      | call       |
      | some_method | some logic |
    Then the client should consume all requests
    And the processing time should be lower than 5000ms

  #  Handle possible failures

  Scenario: Should not timeout prematurely
    Given I receive the following requests:
      | payload                                  |
      | {"method":"slow","params":[0],"id":"X1"} |
      | {"method":"slow","params":[1],"id":"X2"} |
    When I go live with the following processing rules:
      | method | call           |
      | slow   | work for 600ms |
    Then the client should consume all requests
    And the client should publish the following responses:
      | payload                                |
      | {"result":"OK","error":null,"id":"X1"} |
      | {"result":"OK","error":null,"id":"X2"} |

  Scenario: Exit gracefully if broker not available
    Given the broker is not available
    When I go live with the following processing rules:
      | method      | call       |
      | some_method | some logic |
    Then I should get no exception
    And the client should display to console:
      | output                                  |
      | There was a problem processing messages |

  Scenario: Exit gracefully if malformed message is received
    Given I receive the following requests:
      | payload           |
      | malformed_request |
    When I go live with the following processing rules:
      | method      | call       |
      | some_method | some logic |
    Then I should get no exception
    And the client should display to console:
      | output                 |
      | Invalid message format |

  Scenario: Should display informative message when starting and stopping client
    When I go live with the following processing rules:
      | method | call |
    Then the client should display to console:
      | output               |
      | Starting client      |
      | Waiting for requests |
      | Stopping client      |
