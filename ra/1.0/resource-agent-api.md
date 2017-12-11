# Open Clustering Framework Resource Agent API

Editor: Lars Marowsky-Brée <lmb@suse.de>

URL: http://www.opencf.org/standards/resource-agent-api.html

## License

    Copyright (c) 2002 Lars Marowsky-Brée.

    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.2 or
    any later version published by the Free Software Foundation; with no
    Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A
    copy of the license can be found at http://www.gnu.org/licenses/fdl.txt.

## Abstract

Resource Agents (RA) are the middle layer between the Resource Manager
(RM) and the actual resources being managed. They aim to integrate the
resource type with the RM without any modifications to the actual
resource provider itself, by encapsulating it carefully and providing
generic methods (actions) to operate on them.

The RAs are obviously very specific to the resource type they operate
on, however there is no reason why they should be specific to a
particular RM.

The API described in this document should be general enough that a
compliant Resource Agent can be used by all existing resource managers /
switch-over systems who chose to implement this API either exclusively
or in addition to their existing one.


### Scope

This document describes a common API for the RM to call the RAs so the
pool of available RAs can be shared by the different clustering
solutions.

It does NOT define any libraries or helper functions which RAs might share
with regard to common functionality like external command execution, cluster
logging et cetera, as these are NOT specific to RA and are defined in the
respective standards.


### API version described

This document currently describes version 1.0 of the API. 


## Terms used in this document

### "Resource"

A single physical or logical entity that provides a service to clients or
other resources. For example, a resource can be a single disk volume, a
particular network address, or an application such as a web server. A resource
is generally available for use over time on two or more nodes in a cluster,
although it usually can be allocated to only one node at any given time.

Resources are identified by a name that must be unique to the particular
resource type. This is any name chosen by the administrator to identify
the resource instance and passed to the RA as a special environment
variable.

A resource may also have instance parameters which provide additional
information required for Resource Agent to control the resource.


### "Resource types"

A resource type represents a set of resources which share a common set of
instance parameters and a common set of actions which can be performed on
resource of the given type.

The resource type name is chosen by the provider of the RA.


### "Resource agent"

A RA provides the actions ("member functions") for a given type of
resources; by providing the RA with the instance parameters, it is used
to control a specific resource.

They are usually implemented as shell scripts, but the API described here does
not require this.

Although this is somewhat similar to LSB init scripts, there are some
differences explained below. 


### "Instance parameters"

Instance parameters are the attributes which describe a given resource
instance. It is recommended that the implementor minimize the set of
instance parameters.

The meta data allows the RA to flag one or more instance parameters as
`unique`. This is a hint to the RM or higher level configuration tools
that the combination of these parameters must be unique to the given
resource type.

An instance parameter has a given name and value. They are both case
sensitive and must satisfy the requirements of POSIX environment
name/value combinations.


## API

### API Version Numbers

The version number is of the form `x.y`, where `x` and `y` are positive
numbers greater or equal to zero. `x` is referred to as the "major"
number, and `y` as the "minor" number.

The major number must be increased if a _backwards incompatible_ change is
made to the API. A major number mismatch between the RA and the RM must be
reported as an error by both sides.

The minor number must be increased if _any_ change at all is made to the
API.  If the major is increased, the minor number should be reset to
zero. The minor number can be used by both sides to see whether a
certain additional feature is supported by the other party.


### Paths

The Resource Agents are located in subdirectories under
`/usr/ocf/resource.d`.

The subdirectories allow the installation of multiple RAs for the same
type, but from different vendors or package versions.

The filename within the directories equals the resource type name
provided by the RA and may be a link to the real location.

Example directory structure:

    FailSafe -> FailSafe-1.1.0/
    FailSafe-1.0.4/
    FailSafe-1.1.0/
    heartbeat -> heartbeat-1.1.2/
    heartbeat-1.1.2/
    heartbeat-1.1.2/IPAddr
    heartbeat-1.1.2/IP -> IPAddr

How the RM choses an agent for a specific resource type name from the
available set is implementation specific.


### Execution syntax

After the RM has identified the executable to call, the RA will be
called with the requested action as its sole argument.

To allow for further extensions, the RA shall ignore all other
arguments.


### Resource Agent actions

A RA must be able to perform the following actions on a given resource
instance on request by the RM; additional actions may be supported by
the script for example for LSB compliance.

The actions are all required to be idempotent. Invoking any operation
twice - in particular, the start and stop actions - shall succeed and
leave the resource instance in the requested state.

In general, a RA should not assume it is the only RA of its type running
at any given time because the RM might start several RA instances for
multiple independent resource instances in parallel.

_Mandatory_ actions must be supported; _optional_ operations must be
advertised in the meta data if supported. If the RM tries to call a
unsupported action the RA shall return an error as defined below.


- `start`
  
    Mandatory.

    This brings the resource instance online and makes it available for
    use. It should NOT terminate before the resource instance has either
    been fully started or an error has been encountered.

    It may try to implement recovery actions for certain cases of startup
    failures.

    `start` must succeed if the resource instance is already running.

    `start` must return an error if the resource instance is not fully
    started.

- `stop`

    Mandatory.

    This stops the resource instance. After the `stop` command has
    completed, no component of the resource shall remain active and it
    must be possible to start it on the same node or another node or an
    error must be returned.

    The `stop` request by the RM includes the authorization to bring down the
    resource even by force as long data integrity is maintained; breaking
    currently active transactions should be avoided, but the request to offline
    the resource has higher priority than this. If this is not possible,
    the RA shall return an error to allow higher level recovery.

    The `stop` action should also perform clean-ups of artifacts like leftover
    shared memory segments, semaphores, IPC message queues, lock files etc.

    `stop` must succeed if the resource is already stopped.

    `stop` must return an error if the resource is not fully stopped.
  
- `monitor`

    Mandatory.

    Checks and returns the current status of the resource instance. The
    thoroughness of the check is further influenced by the weight of the
    check, which is further explained under **Action specific extensions**..

    It is accepted practice to have additional instance parameters which
    are not strictly required to identify the resource instance but are
    needed to monitor it or customize how intrusive this check is allowed
    to be.

    Note that `monitor` shall also return a well defined error code (see
    below) for stopped instances, ie before `start` has ever been
    invoked.
  
- `recover`

    Optional.

    A special case of the `start` action, this should try to recover a resource
    locally. 

    It is recommended that this action is not advertised unless it is
    advantageous to use when compared to a stop/start operation.

    If this is not supported, it may be mapped to a stop/start action by
    the RM.

    An example includes "recovering" an IP address by moving it to another
    interface; this is much less costly than initiating a full resource group
    fail over to another node.

- `reload`

    Optional.

    Notifies the resource instance of a configuration change external to
    the instance parameters; it should reload the configuration of the
    resource instance without disrupting the service.

    It is recommended that this action is not advertised unless it is
    advantageous to use when compared to a stop/start operation.

    If this is not supported, it may be mapped to a stop/start action by
    the RM.

- `meta-data`

    Mandatory.

    Returns the resource agent meta data via stdout.

- `validate-all`

    Optional.

    Validate the instance parameters provided.

    Perform a syntax check and if possible, a semantic check on the
    instance parameters.


### Parameter passing

The instance parameters and some additional attributes are passed in via the
environment; this has been chosen because it does not reveal the parameters to
an unprivileged user on the same system and environment variables can be
easily accessed by all programming languages and shell scripts.

The entire environment variable name space starting with `OCF_` is considered to
be reserved for OCF use.


#### Syntax for instance parameters

They are directly converted to environment variables; the name is prefixed
with `OCF_RESKEY_`.

The instance parameter `force` with the value `yes` thus becomes
`OCF_RESKEY_force=yes` in the environment.

See the terms section on instance parameters for a more formal explanation.


#### Global OCF attributes

Currently, the following additional environment variables are defined:

* `OCF_RA_VERSION_MAJOR`
* `OCF_RA_VERSION_MINOR`

    Version number of the OCF Resource Agent API. If the script does 
    not support this revision, it should report an error.
    
    See **API Version Numbers** for an explanation of the versioning
    scheme used. The version number is split into two numbers for ease
    of use in shell scripts.

    These two may be used by the RA to determine whether it is run under
    an OCF compliant RM.

    Example:

    ```
    OCF_RA_VERSION_MAJOR=1
    OCF_RA_VERSION_MINOR=0
    ```

* `OCF_ROOT`

    Referring to the root of the OCF directory hierarchy.
    
    Example: `OCF_ROOT=/usr/ocf`

* `OCF_RESOURCE_INSTANCE`

    The name of the resource instance.

* `OCF_RESOURCE_TYPE`

    The name of the resource type being operated on.

### Action specific extensions

These environment variables are not required for all actions, but only
supported by some.

#### Parameters specific to the 'monitor' action

- `OCF_CHECK_LEVEL`

    - `0`

        The most lightweight check possible, which should not
        have an impact on the QoS.

        Example: Check for the existence of the process.

    - `10`

        A medium weight check, expected to be called multiple
        times per minute, which should not have a noticeable
        impact on the QoS.

        Example: Send a request for a static page to a
        webserver.

    - `20`

        A heavy weight check, called infrequently, which may
        impact system or service performance.

        Example: An internal consistency check to verify service
        integrity.

Service must remain available during all of these operation.
All other number are reserved.

It is recommended that if a requested level is not implemented,
the RA should perform the next lower level supported.


### Exit status codes

These exit status codes are the ones documented in the LSB 1.1.0
specification, with additional explanations of how they shall be used by
RAs. In general, all non-zero status codes shall indicate failure in
accordance to the best current practices.

#### All operations

- `0`

    No error, action succeeded completely

- `1`

    Generic or unspecified error (current practice)
    The "monitor" operation shall return this for a crashed, hung or
    otherwise non-functional resource.

- `2`

    Invalid or excess argument(s)
    Likely error code for validate-all, if the instance parameters
    do not validate. Any other action is free to also return this
    exit status code for this case.

- `3`

    Unimplemented feature (for example, "reload")

- `4`

    User had insufficient privilege

- `5`

    Program is not installed

- `6`

    Program is not configured

- `7`

    Program is not running

    Note: This is not the error code to be returned by a successful
    "stop" operation. A successful "stop" operation shall return 0.
    The "monitor" action shall return this value only for a 
    _cleanly_ stopped resource. If in doubt, it should return 1.

- `8-99`

    Reserved for future LSB use

- `100-149`

    Reserved for distribution use

- `150-199`

    Reserved for application use

- `200-254`

    Reserved

## Relation to the LSB

It is required that the current LSB spec is fully supported by the system.

The API tries to make it possible to have RA function both as a normal LSB
init script and a cluster-aware RA, but this is not required functionality.
The RAs could however use the helper functions defined for LSB init scripts.


## RA meta data

### Format

The API has the following requirements which are not fulfilled by the
LSB way of embedding meta data into the beginning of the init scripts:

- Independent of the language the RA is actually written in,
- Extensible,
- Structured,
- Easy to parse from a variety of languages.

This is why the API uses simple XML to describe the RA meta data. The
DTD for this API can be found at [this location](http://www.opencf.org/standards/ra-api-1.dtd).

### Semantics

An example of a valid meta data output is provided in
`ra-metadata-example.xml`.

## To-do list

- Move the terminology definitions out into a separate document
  common to all OCF work.
- An interface where the RA asynchronously informs the RM of
  failures is planned but not defined yet. 

## Contributors

- James Bottomley <James.Bottomley@steeleye.com>
- Greg Freemyer <freemyer@NorcrossGroup.com>
- Simon Horman <horms@verge.net.au>
- Ragnar Kjørstad <linux-ha@ragnark.vestdata.no>
- Lars Marowsky-Brée <lmb@suse.de>
- Alan Robertson <alanr@unix.sh>
- Yixiong Zou <yixiong.zou@intel.com> 
