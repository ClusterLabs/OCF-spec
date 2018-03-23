**DRAFT - DRAFT - DRAFT**

**JOIN THE developers@clusterlabs.org MAILING LIST AND FOLLOW PULL REQUESTS
AT https://github.com/ClusterLabs/OCF-spec/ TO DISCUSS CHANGES**

# Open Clustering Framework Resource Agent API

Editor: Lars Marowsky-Brée <lmb@suse.de>

URL: https://github.com/ClusterLabs/OCF-spec/blob/master/ra/next/resource-agent-api.md


## Abstract

The Open Clustering Framework Resource Agent (RA) API provides an abstraction
layer between diverse, computer-hosted resources and diverse types of software
managing such resources in a clustered environment.

The RA API allows resources to be managed without any modification to the
actual resource providers, by providing a standardized interface to common
management tasks. It also allows (but does not require) RAs to be designed
without consideration of specific software that might invoke them, and thus
shared by any such software.


## Status of This Memo

This is an Open Cluster Framework (OCF) document produced by ClusterLabs
<https://clusterlabs.org>.

This document describes proposed extensions to the OCF RA API, which may be
incorporated into future versions of the standard. It has not been adopted
as a standard, and should be considered for discussion purposes only.


## Copyright Notice

Copyright 2002,2018 Lars Marowsky-Brée

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.2 or
any later version published by the Free Software Foundation; with no
Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A
copy of the license can be found at http://www.gnu.org/licenses/fdl.txt.


## Terms used in this document

### Resource

A _resource_, also known as a _resource instance_, is a logical entity that
provides a particular computer-hosted service. Examples of resources include a
disk volume, a network address, a web server, or a virtual machine.

### Cluster

A _cluster_ is a collection of one or more computers under common
administration running a set of resources.

### Resource Manager

A _resource manager_ (RM), also known as a _cluster resource manager_ (CRM),
is software that manages resources in a cluster.

### Resource Type

A _resource type_, also known as a _resource class_, is a name indicating the
service provided by a resource. This name should be suitable for use as a file
name.

### Resource Agent

A _resource agent_ (RA) is a software application implementing the RA API for a
particular resource type. An RA allows a resource manager to perform specific
mangement tasks for resource instances.

### Resource Agent Provider

A _resource agent provider_ is an entity supplying one or more resource agents
for installation on cluster hosts. Each provider should have a unique name
suitable for use as a file system directory name.

A provider may choose to supply multiple, separate collections of resource
agents. In this case, each collection should have a unique name, and _provider_
may refer either to the entity as a whole, or to an individual collection.

Currently, there is no central registry for provider names. Providers should
choose names that do not appear to be already in use for publicly available
resource agents.

Each provider also chooses the resource type names used for the resource agents
it provides. These do not need to be unique across providers.

### Resource Name 

A _resource name_ is a unique identifier chosen by the cluster administrator
to identify a particular resource instance.

### Resource Parameters

_Resource parameters_, also known as _instance parameters_, are attributes
describing a particular resource instance. Each parameter has a name and a
value, which must satisfy the requirements of POSIX environment variable names
and values.

The resource agent defines the names, meaning, and allowed values of parameters
available for its resource type.

The cluster administrator specifies the particular parameters used for each
resource instance.


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


### The Resource Agent Directory

Resource agents are executable files that must be made available beneath a
common location on a host's file system, referred to as the _resource agent
directory_.

In the 1.0 version of this standard, the only acceptable location of this
directory was `/usr/ocf/resource.d`. However, in practice, installations
typically used the nonconforming location `/usr/lib/ocf/resource.d`.

For strict compatibility with the standard, resource agents should be installed
in the 1.0 location, and resource managers should look for agents there.

For widest compatibility, resource agents and resource managers should allow
the installer to choose the location of the directory, which should have a
reasonable default, and should be identical for all resource agents and
resource managers installed on a particular host. Resource managers may also
choose to search multiple locations.


### The Resource Agent Directory Tree

Each provider shall install its resource agents in a subdirectory of the
resource agent directory, using the provider's name. This allows installation
of multiple resource agents for the same type, but from different suppliers or
package versions.

Each resource agent should be installed as a file within the provider
subdirectory, named according to the resource type.

The provider subdirectory and resource agent file may be links to the actual
locations.

A simple example of a resource agent directory tree containing a single
provider `acme` that provides resource agents `widget` and `gadget`:

    acme/
        acme/widget
        acme/gadget

Another example where multiple versions of acme's agents are installed:

    acme -> acme-2.0/
    acme-1.0/
        acme-1.0/widget
        acme-1.0/gadget
    acme-2.0/
        acme-2.0/widget
        acme-2.0/gadget

An example with two providers, an agent available from two providers, and an
agent available under multiple names from the same provider:

    acme/
        acme/widget
        acme/gadget
    betterco/
        betterco/widget
        betterco/IP -> IPAddr
        betterco/IPAddr

Resource managers may choose an agent for a specific resource type name from
the available set in any manner they choose.


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
- Ken Gaillot <kgaillot@redhat.com>
