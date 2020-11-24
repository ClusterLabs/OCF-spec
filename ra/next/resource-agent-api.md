**DRAFT - DRAFT - DRAFT**

**JOIN THE developers@clusterlabs.org MAILING LIST AND FOLLOW PULL REQUESTS
AT https://github.com/ClusterLabs/OCF-spec/ TO DISCUSS CHANGES**

# Open Clustering Framework Resource Agent API

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

Originally Copyright 2002,2018 Lars Marowsky-Brée
Later changes copyright 2020 the Open Cluster Framework project contributors

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

A _resource type_ is a name indicating the service provided by a resource. This
name should be suitable for use as a file name.

A resource type beginning with a leading dot (.) is a hint to RMs and other
tools that the resource type should be omitted from lists provided in response
to user queries.

### Resource Agent

A _resource agent_ (RA) is a software application implementing the RA API for a
particular resource type. An RA allows a resource manager to perform specific
mangement tasks for resource instances.

### Resource Agent Provider

A _resource agent provider_ is an entity supplying one or more resource agents
for installation on cluster hosts. Each provider should have a unique name
suitable for use as a file system directory name.

A resource agent provider beginning with a leading dot (.) is a hint to RMs and
other tools that the resource agent provider should be omitted from lists
provided in response to user queries.

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


### Resource Agent Actions

Resource agents must accept a single command-line argument specifying an
action to be performed. RAs must be able to perform actions listed in this
section as mandatory, and must advertise them as described in
**Resource Agent Meta-Data**. RAs may support any additional actions, including
but not limited to those listed in this section as optional.

Actions must be idempotent. Invoking an already successfully performed action
additional times must be successful and leave the resource instance in the
requested state. For example, a start command given to a resource that has
already been successfully started should return success without changing the
state of the resource.

An RA should not assume it is the only RA of its type running at any given
time. Multiple resource instances of the same type may be running in parallel.

An RA must return a well-defined status, as described under
**Exit Status Codes**. This includes improper usage such as being called with
an unsupported action.

#### Mandatory Actions

- `start`
  
    This must bring the resource instance online and makes it available for
    use. It should NOT terminate before the resource instance has either
    been fully started or an error has been encountered.

    It may try to implement recovery actions for certain cases of startup
    failures.

    `start` must succeed if the resource instance is already running.

    `start` must return an error if the resource instance is not fully
    started.

- `stop`

    This must stop the resource instance. After the `stop` command has
    completed, no component of the resource shall remain active, and it
    must be possible to start it on the same node or another node, otherwise an
    error must be returned.

    The `stop` request by the RM includes the authorization to bring down the
    resource even by force as long as data integrity is maintained. Breaking
    currently active transactions should be avoided, but the request to offline
    the resource has higher priority than this. If this is not possible,
    the RA shall return an error, to allow higher-level recovery.

    The `stop` action should also clean up any artifacts such as leftover
    shared memory segments, semaphores, IPC message queues, lock files, etc.

    `stop` must succeed if the resource is already stopped.

    `stop` must return an error if the resource is not fully stopped.
  
- `monitor`

    This must check the current status of the resource instance. The
    thoroughness of the check is influenced by the weight of the check, as
    described under **Monitor-Specific Parameters**.

    An RA may have additional instance parameters which are not strictly
    required to identify the resource instance but are useful for monitoring
    it. In particular, RAs may support an integer _depth_ parameter specifying
    how intrusive this check is allowed to be (which values for depth are
    supported and what degree of intrusiveness they correspond to is left to
    the RA).

- `meta-data`

    This must display the XML information described under
    **Resource Agent Meta-Data** via standard output.

#### Optional Actions

- `demote`

    If the resource supports two modes of operation (_roles_), this action
    must put the resource in the default role (the role that a start action
    leaves the resource in).

- `notify`

    If the resource requires special coordination when multiple instances are
    run simultaneously in the cluster, the resource agent should support this
    action, which should perform such coordination.

    When the RA supports this action, RMs should call the action for all active
    instances of this particular resource in the cluster before and after any
    demote, promote, start, or stop action performed on any instance of it.

    How the RM passes useful information to the RA when performing this action
    is currently left to the RM and RA, but may be formalized in a future
    version of this standard.

- `promote`

    If the resource supports roles, this action must put the resource in the
    special (non-default) role.

- `recover`

    A special case of the `start` action, this should try to recover a resource
    locally.

    It is recommended that this action is not advertised unless it is
    advantageous to use when compared to a stop and start action sequence.

    If this is not supported, it may be mapped to a stop and start action
    sequence by the RM.

    An example includes "recovering" an IP address by moving it to another
    interface; this is much less costly than initiating a full resource group
    fail-over to another node.

- `reload`

    This should notify the resource instance of a configuration change external
    to the instance parameters. It should reload the configuration of the
    resource instance without disrupting the service.

    It is recommended that this action is not advertised unless it is
    advantageous to use when compared to a stop and start action sequence.

    If this is not supported, it may be mapped to a stop and start action
    sequence by the RM.

- `validate-all`

    This should validate the instance parameters provided.

    This should perform a syntax check, and if possible a semantic check, on
    the instance parameters.


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
    OCF_RA_VERSION_MINOR=1
    ```

* `OCF_ROOT`

    Referring to the root of the OCF directory hierarchy.
    
    Example: `OCF_ROOT=/usr/ocf`

* `OCF_RESOURCE_INSTANCE`

    The name of the resource instance.

* `OCF_RESOURCE_TYPE`

    The name of the resource type being operated on.

#### Monitor-Specific Parameters

Resource agents may optionally support the parameters listed here when called
with the `monitor` action.

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

    - All other numbers are reserved.

Service must remain available during the monitor, regardless of level.

It is recommended that if a requested level is not implemented,
the RA should perform the next lower level supported.


### Exit Status Codes

These exit status codes are identical to those documented in the LSB 5.0 Core
specification for non-status "Init Script Actions"
<https://refspecs.linuxfoundation.org/LSB_5.0.0/LSB-Core-generic/LSB-Core-generic/iniscrptact.html>,
with additional explanations of how they shall be used by RAs.

Although non-zero status codes are referred to in this document as errors, RA
developers should keep in mind that RMs decide whether a status code is a
failure or not (for example, if a particular error is the expected situation,
it may not be considered a failure).

- `0`

    Success. The requested action finished and succeeded completely, or
    for a "monitor" action, the service was found to be properly active.

- `1`

    Unspecified error. The action did not completely succeed for some reason,
    or for a "monitor" action, the service was malfunctioning or in an
    undetermined state. A more specific status code should be used if
    applicable.

- `2`

    Invalid parameter(s). Note: there is some variance in the actual use of
    this status; it may refer to parameters that are inherently invalid (for
    example, text provided for a parameter value that must be an integer), or
    to parameters that are invalid in the context of the local host (for
    example, a supplied file name does not exist). It is recommended to use
    the latter meaning, so RMs can decide to try running the resource on a
    different host after receiving this status.

- `3`

    Unimplemented feature. The RA does not support the requested action.

- `4`

    Insufficient privilege. The user executing the RA lacked some necessary
    authorization.

- `5`

    Not installed. Some software required for the operation of the service is
    not available on the local host.

- `6`

    Not configured. Note: there is some variance in the actual use of this
    status; it may mean the service's own configuration on the local host is
    invalid, or it may mean the parameters supplied to the RA are inherently
    invalid. It is recommended to use the latter meaning, so that RMs may
    decide to fail the action without retrying elsewhere.

- `7`

    Not running. A "monitor" action shall return this if it finds the service
    to be completely stopped (if there is doubt, some other status such as 1
    should be returned). Note: A successful "stop" operation shall return 0,
    not 7.

- `8-99`

    Reserved for future LSB use

- `100-149`

    Reserved for distribution use

- `150-199`

    Reserved for application use

- `200-254`

    Reserved


## Relation to the LSB

The RA API aims to make it possible for (but does not require) an RA to
function as both an LSB-compliant init script and a cluster-aware RA.
RAs may use helper functions defined for LSB init scripts.


## Resource Agent Meta-Data

### Format

While the LSB uses shell script comments at the beginning of init scripts to
provide meta-data, OCF RA meta-data is described using XML so that the
meta-data can be:

- Independent of the language the RA itself is written in,
- Extensible,
- Structured, and
- Easy to parse from a variety of languages.

RA meta-data shall conform to the XML schema formally described at
<https://github.com/ClusterLabs/OCF-spec/blob/master/ra/next/ra-api.rng>.

### Example

An example of a valid meta-data output is provided at
<https://github.com/ClusterLabs/OCF-spec/blob/master/ra/next/ra-metadata-example.xml>.

### Semantics

Certain meta-data XML elements warrant further explanation:

- `resource-agent`: The optional `version` attribute should describe the
  version of the agent itself.

- `version`: This is the version of the OCF RA standard with which the RA
  claims compatibility.

- `longdesc`, `shortdesc`, and `desc`: These elements, wherever they occur in
  meta-data, are natural-language descriptions of what is specified by their
  parent element, intended as hints to tools for display to users. These
  elements must contain a `lang` attribute whose value is a standard language
  identifier ("BCP 47" <https://www.rfc-editor.org/rfc/bcp/bcp47.txt>).
  Multiple elements with different values for `lang` may be specified, to
  provide translations. These elements may contain any XML, but it is strongly
  recommended to limit the content to a text string.

- `parameter`:
    - `unique` attribute: This is a hint to RMs and other tools that the
      combination of all parameters marked `unique` must be unique to the resource
      type. That is, no two resource instances of the same resource type may have
      the same combination of `unique` parameters.
    - `required` attribute: This is a hint to RMs and other tools that every
      resource instance of this resource type must specify a value for this
      parameter.
    - `deprecated` child element: When present, this element is a hint to RMs
      and other tools that the parameter is supported for backward
      compatibility only.
      - `replaced-with` child element: This must contain a `name` attribute
        with the name of another parameter that should be used instead of the
        deprecated parameter. Multiple such elements maybe specified.

- `action`: Resource agents should advertise each action they support,
  including all mandatory actions, with an `action` element.
    - `name` attribute (required): This is a unique identifier for the action
      as described in **Resource Agent Actions**. There may be multiple
      `action` entries with the same name and different values for other
      attributes (for example, to recommend different timeout and interval
      values for status actions of different depths).
    - `timeout` attribute (required): This is a hint to RMs and other tools
      that every resource instance of this resource type should specify a
      timeout equal to or greater than this value (when used with any other
      attribute values specified in this entry).
    - `interval` attribute (optional): This is a hint to RMs and other tools
      that every resource instance of this resource type should repeat this
      action at intervals equal to this value (when used with any other
      attribute values specified in this entry).
    - `depth` attribute (optional): This is a hint to RMs and other tools
      that this action of the resource agent utilizes the depth parameter with
      this value, as described in **Resource Agent Actions**.
    - `role` attribute (optional): This is a hint to RMs and other tools
      that this action of the resource agent recognizes this role value,
      as described in **Resource Agent Actions**.

## Contributors

- James Bottomley <James.Bottomley@steeleye.com>
- Greg Freemyer <freemyer@NorcrossGroup.com>
- Simon Horman <horms@verge.net.au>
- Ragnar Kjørstad <linux-ha@ragnark.vestdata.no>
- Lars Marowsky-Brée <lmb@suse.de>
- Alan Robertson <alanr@unix.sh>
- Yixiong Zou <yixiong.zou@intel.com> 
- Ken Gaillot <kgaillot@redhat.com>
