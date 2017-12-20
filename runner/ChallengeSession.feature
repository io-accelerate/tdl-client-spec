Feature: Should allow the user to interact with the challenge server

  Background:
    Given There is a challenge server running on "localhost" port 8222
    And journeyId is "aJourneyId"
    And the challenge server exposes the following endpoints
      | verb       | endpointEquals               | status   | responseBody                         | acceptHeader  |
      | GET        | /availableActions/aJourneyId | 200      | Available actions coming from server | text/coloured |
      | GET        | /roundDescription/aJourneyId | 200      | RoundID\nRound Description           | text/coloured |
      | GET        | /journeyProgress/aJourneyId  | 200      | Journey progress coming from server  | text/coloured |

    And the challenge server exposes the following endpoints
      | verb       | endpointMatches                 | status   | responseBody                         | acceptHeader  |
      | POST       | /action/([a-zA-Z]+)/aJourneyId  | 200      | Successful action feedback           | text/coloured |

    And There is a recording server running on "localhost" port 41375
    And the recording server exposes the following endpoints
      | verb       | endpointEquals    | status   | responseBody   |
      | GET        | /status           | 200      | OK             |
      | POST       | /notify           | 200      | ACK            |

  # Business critical scenarios

  Scenario: The server interaction
    Given the action input comes from a provider returning "anySuccessful"
    And the challenges folder is empty
    When user starts client
    Then the server interaction should look like:
      """
      Connecting to localhost
      Journey progress coming from server
      Available actions coming from server
      Selected action is: anySuccessful
      Successful action feedback
      Challenge description saved to file: challenges/RoundID.txt.
      """

  Scenario: Refresh round description on successful action
    Given the action input comes from a provider returning "anySuccessful"
    And the challenges folder is empty
    When user starts client
    Then the file "challenges/RoundID.txt" should contain
    """
    RoundID
    Round Description

    """
    And the recording system should be notified with "RoundID/new"

  Scenario: Deploy code to production and display feedback
    Given the action input comes from a provider returning "deploy"
    And there is an implementation runner that prints "Running implementations"
    When user starts client
    Then the implementation runner should be run with the provided implementations
    And the server interaction should contain the following lines:
      """
      Selected action is: deploy
      Running implementations
      """
    And the recording system should be notified with "RoundID/deploy"

  # Negative paths

  Scenario: Should exit when no available actions
    Given the challenge server exposes the following endpoints
      | verb       | endpointEquals                | status  | responseBody             | acceptHeader  |
      | GET        | /availableActions/aJourneyId  | 200     | No actions available.    | text/coloured |
    When user starts client
    Then the client should not ask the user for input

  Scenario: Should exit if recording not available
    Given recording server is returning error
    When user starts client
    Then the client should not ask the user for input
    And the user is informed that they should start the recording

  Scenario: challenge server is returning a client error
    Given the challenge server returns 400, response body "Nothing here" for all requests
    When user starts client
    Then the server interaction should contain the following lines:
      """
      Nothing here
      """

  Scenario: challenge server is returning a server error
    Given the challenge server returns 500 for all requests
    When user starts client
    Then the server interaction should contain the following lines:
      """
      Server experienced an error. Try again in a few minutes.
      """

  Scenario: challenge server is returning an unknown error
    Given the challenge server returns 301 for all requests
    When user starts client
    Then the server interaction should contain the following lines:
      """
      Client threw an unexpected error. Try again.
      """