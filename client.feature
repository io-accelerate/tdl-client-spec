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

  Scenario: Should display published requests and response
    Given I receive the following requests:
      | {"method":"sum","params":[1,2],"id":"X1"}      |
      | {"method":"increment","params":[3],"id":"X2"}  |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | publish           |
      | increment    | increment number | publish and stop  |
    Then the client should display to console:
      | id = X1, req = sum(1, 2), resp = 3     |
      | id = X2, req = increment(3), resp = 4  |

  Scenario: Should flag unpublished requests and response
    Given I receive the following requests:
      | {"method":"sum","params":[1,2],"id":"X1"}      |
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | sum          | add two numbers  | stop              |
    Then the client should display to console:
      | id = X1, req = sum(1, 2), resp = 3 (NOT PUBLISHED) |


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
      | id = X1, req = sum(0, 1), resp = empty (NOT PUBLISHED) |


  #  Connections problems
  #DEBT: Should be handled as a separate feature

  Scenario: Exit gracefully is broker not available
    Given the broker is not available
<<<<<<< HEAD
    When I go live with the following implementations:
      | some_method       |  some logic   |
    Then I should get no exception


  #  Trial runs
  #DEBT: Should be handled as a separate feature

  Scenario: Trial run does not count
    Given I receive the following requests:
      | {"method":"sum","params":[0,1],"id":"X1"} |
      | {"method":"sum","params":[5,6],"id":"X1"} |
    When I do a trial run with the following implementations:
      | sum       | adds two numbers |
    Then the client should not consume any request
    And the client should not publish any response

  Scenario: Trial run displays first message
    Given I receive the following requests:
      | {"method":"sum","params":[0,1],"id":"X1"} |
      | {"method":"sum","params":[5,6],"id":"X1"} |
    When I do a trial run with the following implementations:
      | sum       | adds two numbers |
    Then the client should display to console:
      | id = X1, req = sum(0, 1), resp = 1  |
    But the client should not display to console:
      | id = X2, req = sum(5, 6), resp = 11  |
=======
    When I go live with the following processing rules:
      |   Method     |      Call        |  Action           |
      | some_method  |  some logic      | publish           |
    Then I should get no exception
>>>>>>> e36a822... Allow user to control the client through client actions
