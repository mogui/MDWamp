# README
- document Wamp cra auth with an example

# GO
- resolve issues msg pack

# Advanced profile
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
	- One Time Token Authentication