% PF-APPLY(1) Version @VERSION@ | pf-apply
% André Erdmann <dywi@mailerd.de>
% June 26, 2021

# NAME

**pf-apply** — safely load new pf.conf


# SYNOPSIS

| **pf-apply** \[**-d**\] \[**-f _file_**\] \[-I\] \[-L\] \[-R\] \[**-t _timeout_**\]
| **pf-apply** **-h**


# DESCRIPTION


Loads a new pf.conf configuration file and waits for user feedback.

Only if the user accepts the new configuration within a specific time frame,
it gets installed to */etc/pf.conf* and will be active on the next boot as well.

Otherwise, the configuration gets rolled back to the previous rule set.

The typical scenario is updating the pf.conf on a remote machine via SSH
while avoiding to get locked out.


Overview of the actions taken by pf-apply:

#. Initialize logging

#. Block other instances by acquiring an advisory file lock (flock(2))

#. Copy the new pf.conf to a temporary file below */etc* (PATH FIXME)
   so that it can be atomically moved later on

#. Check the new pf.conf (using pfctl -n -f pf.conf.new)

#. Dump current states for recovery on error

#. Fork to background, detach tty and exit parent process

   The parent process writes the pid of the child process
   to stdout prior to exiting.

#. Load the new pf.conf file

#. Wait up to 30 seconds for user feedback
   whether the new configuration should be kept or not.

   To accept the new configuration, send SIGUSR1 to the process.

   To discard it and roll back, send SIGTERM or SIGINT.
   Alternatively, this option is also selected if no user feedback
   was received at all, usually caused by being locked
   out by the new firewall configuration.

#. User accepts the new configuration (SIGUSR1 received)

   Rotate pf.conf files so that the new pf.conf configuration
   will be used on next boot:

   * */etc/pf.conf* is moved to */etc/pf.conf.old*
   * The new configuration is moved to */etc/pf.conf*

   This step uses hardlinks to ensure a mostly atomic operation.

#. User does not accept the new configuration (timeout or SIGTERM/SIGINT received)

   * Load */etc/pf.conf*

   * Restore firewall states from the previously created temporary file

   Alternatively, disable the firewall altogether (**-d** option).

#. Clean up temporary files, stop logging



# OPTIONS

-d

:   Instead of restoring the firewall rules from */etc/pf.conf* on error,
    disable the firewall completely (pfctl -d).

    Not recommended, use at your own discretion.

-f _file_

:   pf.conf file to be loaded.

    Defaults to *FIXME*.

-I

:   Do not install the new pf.conf file to *FIXME*.

-L

:   Do not acquire a lock

-R

:   Do not restore pf states on error

    This also disables dumping of pf states.

-t _timeout_

:   Maximum time to wait for user feedback whether the new pf.conf should be kept or not.

    Defaults to 30 seconds.


# EXIT CODES

0

:   Success

1

:   Unspecified error


2

:   Blocked by other instance (failed to acquire lock)

10

:   Failed to copy new pf.conf file to temporary file

11

:   New pf.conf did not pass syntax check

12

:   Failed to dump current states to temporary file

15

:   User did not accept new configuration, states restored

18

:   Failed to rollover pf.conf, states restored

35

:   User did not accept new configuration, states not restored

38

:   Failed to rollover pf.conf, states not restored

64

:   Usage error

70

:   Software logic broken

71

:   Failed to get system resources


# FILES

*FIXME*

:   The default new pf.conf file to be loaded when no **-f** option is given.

*FIXME*

:   Path to the lockfile used for blocking simultaneous execution of pf-apply.


# LIMITATIONS

pf-apply will restore the configuration from */etc/pf.conf* on error.
Previous rules stored in dynamic anchors or loaded from other files will be discarded.

No attempt is made to freeze tables, previous entries may be lost.
In particular, changed table files (\'table \<foo\> file \"file-path\"') will affect the restored configuration.


# BUGS

See GitHub Issues: <https://github.com/dywisor/pf-apply/issues>


# SEE ALSO

`pfctl`(8)
