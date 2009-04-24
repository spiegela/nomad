Feature: client registers with registrar
	In order to publish my contact information
	As a client
	I want to register with the registrar
	Scenario: register with registrar
		Given I am not yet registered
		When I start up
		Then I should publish my status with the registrar