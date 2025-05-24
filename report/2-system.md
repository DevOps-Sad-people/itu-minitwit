# System

A description and illustration of the:

## [ seb/nick ] Design and architecture of your _ITU-MiniTwit_ systems


## [Nic] All dependencies of your _ITU-MiniTwit_ systems on all levels of abstraction and development stages. That is, list and briefly describe all technologies and tools you applied and depend on.


## [Nic] Important interactions of subsystems.
###     For example, via an illustrative UML Sequence diagram that shows the flow of information through your system from user request in the browser, over all subsystems, hitting the database, and a response that is returned to the user.
###   Similarly, another illustrative sequence diagram that shows how requests from the simulator traverse your system.

Both the simulator and client contact the same API application, so both sequence diagrams look identical. The following sequence diagram uses the simulator request endpoint `/fllws/[username]` as the baseline.

![UML Sequence diagram of monitoring and logging](./images/sim-request.jpg)

For monitoring and logging, we have also included a sequence diagram to show how they interact with each other.

![UML Sequence diagram of monitoring and logging](./images/monitor+logging.jpg)


## [G] Describe the current state of your systems, for example using results of static analysis and quality assessments.



## [ALL] MSc students should argue for the choice of technologies and decisions for at least all cases for which we asked you to do so in the tasks at the end of each session.

