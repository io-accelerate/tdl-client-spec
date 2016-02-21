# Created by julianghionoiu at 11/10/2015
Feature: Complete challenge
  # Enter feature description here

  Background:
    Given I start with a clean broker

  #  Message processing rules

  Scenario: Process message then publish
    Given I receive the following requests:
      | {"method":"sum","params":[1,2],"id":"X1"}      |
      | {"method":"increment","params":[3],"id":"X2"}  |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | publish           |
      | increment    | increment number | publish           |
    Then the client should consume all requests
    And the client should publish the following responses:
      | {"result":3,"error":null,"id":"X1"} |
      | {"result":4,"error":null,"id":"X2"} |

  Scenario: Process message then stop
    Given I receive the following requests:
      | {"method":"sum","params":[1,2],"id":"X1"}      |
      | {"method":"increment","params":[3],"id":"X2"}  |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | stop              |
      | increment    | increment number | publish           |
    Then the client should not consume any request
    And the client should not publish any response

  Scenario: Process messages then publish and stop
    Given I receive the following requests:
      | {"method":"sum","params":[1,2],"id":"X1"}      |
      | {"method":"increment","params":[3],"id":"X2"}  |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | publish and stop  |
      | increment    | increment number | publish           |
    Then the client should consume first request
    And the client should publish the following responses:
      | {"result":3,"error":null,"id":"X1"} |


  #  Display

  Scenario: Display requests and responses
    Given I receive the following requests:
      | {"method":"sum","params":[1,2],"id":"X1"}      |
      | {"method":"increment","params":[3],"id":"X2"}  |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | publish           |
      | increment    | increment number | publish and stop  |
    Then the client should display to console:
      | id = X1, req = sum(1, 2), resp = 3   |
      | id = X2, req = increment(3), resp = 4  |

  Scenario: Display label next to unpublished responses
    Given I receive the following requests:
      | {"method":"sum","params":[1,2],"id":"X1"}      |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | stop              |
    Then the client should display to console:
      | id = X1, req = sum(1, 2), resp = 3, (NOT PUBLISHED) |

  Scenario: Handle multi-line request and response
    Given I receive the following requests:
      | {"method":"echo","params":["a"],"id":"X1"}      |
      | {"method":"echo","params":["x\ny"],"id":"X2"}      |
      | {"method":"echo","params":["p\nq\nr"],"id":"X3"}      |
    When I go live with the following processing rules:
      |   Method     |      Call          |  Action           |
      | echo         | echo the request   | publish           |
    Then the client should display to console:
      | id = X1, req = echo("a"), resp = "a"   |
      | id = X2, req = echo("x .. ( 1 more line )"), resp = "x .. ( 1 more line )" |
      | id = X3, req = echo("p .. ( 2 more lines )"), resp = "p .. ( 2 more lines )" |


  #  Handle edge cases

  Scenario: Should consume null requests
    Given I receive the following requests:
      | {"method":"sum","params":[0,1],"id":"X1"} |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | return null      | publish           |
    Then the client should consume all requests
    And the client should publish the following responses:
      | {"result":null,"error":null,"id":"X1"} |

  Scenario: Should stop on exceptions
    Given I receive the following requests:
      | {"method":"sum","params":[0,1],"id":"X1"} |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          |  throw exception | publish           |
    Then the client should not consume any request
    And the client should not publish any response
    And the client should display to console:
      | id = X1, req = sum(0, 1), error = "user implementation raised exception", (NOT PUBLISHED) |

  Scenario: Should display informative message if method not registered
    Given I receive the following requests:
      | {"method":"random","params":[2],"id":"X1"} |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | publish           |
    Then the client should not consume any request
    And the client should display to console:
      | id = X1, req = random(2), error = "method 'random' did not match any processing rule", (NOT PUBLISHED) |


  #  Connections problems

  Scenario: Exit gracefully is broker not available
    Given the broker is not available
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | some_method  |  some logic      | publish           |
    Then I should get no exception
    And the client should display to console:
      | There was a problem processing messages |

  Scenario: Exit gracefully if malformed message is received
    Given I receive the following requests:
      | malformed_request |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | some_method  |  some logic      | publish           |
    Then I should get no exception
    And the client should display to console:
      | Invalid message format |

  Scenario: Should display informative message when starting and stopping client
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
    Then the client should display to console:
      | Starting client |
      | Stopping client |
