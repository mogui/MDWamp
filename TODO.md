# README
- document Wamp cra auth with an example


# Advanced profile
- Authentication
    * WAMP Challenge-Response Authentication
    	- Three-legged Authentication -> imlpement a block based  https://github.com/tavendo/WAMP/blob/master/spec/advanced.md#three-legged-authenticationdetachment for signing the challenge
    * One Time Token Authentication

- Transports
   * Batched Transport
   * Multiplexed Transport

- Publish & Subscribe
    * Subscriber Black- and Whitelisting
    * Publisher Exclusion
    * Publisher Identification
    * Publication Trust Levels
    * Pattern-based Subscriptions
    * Distributed Subscriptions & Publications
    * Subscriber Meta Events
    * Subscriber List
    * Event History
    
- Remote Procedure Calls
    * Caller Identification
    * Progressive Call Results
    * Canceling Calls
    * Call Timeouts
    * Call Trust Levels
    * Pattern-based Registrations
    * Distributed Registrations & Calls
    * Callee Black- and Whitelisting
    * Caller Exclusion

7. Reflection


## DONE
1. Transports
   - Raw Socket Transport DONE
   - Long-Poll Transport DOESN'T make sense on mobile
3. Session Management
    - Heartbeats DONE !!? quirks
- Authentication
	- TLS Certificate-based Authentication Out of the box with scoketrocket
	- WAMP Challenge-Response Authentication
	- HTTP Cookie-based Authentication no sense on mobile