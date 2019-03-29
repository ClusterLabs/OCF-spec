**JOIN THE developers@clusterlabs.org MAILING LIST AND FOLLOW PULL REQUESTS
AT https://github.com/ClusterLabs/OCF-spec/ TO DISCUSS CHANGES**

# Open Clustering Framework Resource Agent Meta Data

This document complements [Open Clustering Framework Resource Agent API](
resource-agent-api.md) (referred to as API) that establishes a wider context
for this separate model for declarative data format (referred to as meta data)
providing the discoverability of resource agent properties.

URL: https://github.com/ClusterLabs/OCF-spec/blob/master/ra/1.1/resource-agent-metadata.md
Relavant as of: 1.1
Status: OFFICIAL except where marked as DRAFT


## License

    Copyright (c) 2002, 2018-2019 the OCF-spec project contributors

    The version control history for this file may have further details.

    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.2 or
    any later version published by the Free Software Foundation; with no
    Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A
    copy of the license can be found at https://www.gnu.org/licenses/fdl.txt.


## Abstract

Resource Agents (RA) are the middle layer between the Resource Manager
(RM) and the actual resources being managed. They aim to integrate the
resource type with the RM without any modifications to the actual
resource provider itself, by encapsulating it carefully and providing
generic methods (actions) to operate on them.

The RAs are obviously very specific to the resource type they operate
on, however there is no reason why they should be specific to a
particular RM.

The meta data format set forth in this document addresses the declarative,
one way intechange format that RA uses to announce, in semantic-free way,
means of configuring and launching it, to the RM, so it can adjust to these
ahead of any actual execution.  In particular, RM can hence provide some
assurance levels back to the RA regarding its use, like that no unsupported
operations will be attempted.


## Format

The API has the following requirements thatare not fulfilled by the
LSB way of embedding meta data into the beginning of the init scripts:

- Independent of the language the RA is actually written in,
- Extensible,
- Structured,
- Easy to parse from a variety of languages.

This is why the API uses simple XML to describe the RA meta data.
The RelaxNG schema for this API can be found at [`ra-api.rng`](ra-api.rng).


### DRAFT: One Size Does Not Fit All: Profiles

Historically, OCF standard served its purpose of more systemic, discoverable
and flexible and yet standard-abiding (hence portable) variant of init scripts
well.  However, over time, some rather specialized usage patterns relying on
some rather non-formalized assumptions, either static ones (new previously
non-enumerated actions started to be used with a dedidcated semantic purpose)
or those in the run-time (like whether which RM is there to talk back to
should there be a need) emerged.

To accommodate to this, a light-weight scheme of profiles -- usage pattern
specific extensions of contracts between RA and RM (that happen agree on
the feasible match of these profiles) regarding extended configuration and/or
behaviours -- is devised as of version OCF standard 1.1.

#### Life Cycle of Profiles

Key principle here is a modularity, which allows extending the scale of well
established contracts independently of the core, rather static baseline of
the standard.  These profiles and their life cycle are to be organized as
follows:

1. for each new profile, a name is devised, in a `<NAME>-<VERSION>`
   format, where `<VERSION>` is an incrementing natural number starting with 1
   (number 0 is reserved to denote pre-existing contracts in use that
   were born outside of this profile framework)

2. new document is created relative the root of this OCF standard version,
   in the path location `profiles/<NAME>-<VERSION>.md`, following the common
   template for the profiles, setting the status in the header to `DRAFT`

3. if the profile has any meta data exposed configuration part,
   `profiles/<NAME>-<VERSION>.md` is accompanied with
   `profiles/<NAME>-<VERSION>.rng` describing the respective sub-grammar

4. once the profile is deemed mature enough (perhaps attested with workable
   support in at least a single RM and single RA), the status is changed
   to `OFFICIAL`

#### Retrofitting Pre-Existing Divergencies into Profiles

Following divergencies from the pristine OCF standard are observed, and
subsequently the respective extension contracts are given these names
of respective profiles:

* `rm-pacemaker-0`:
  - resource agents that need to talk back to the RM that in this case
    needs to be pacemaker (using its APIs, directly or through CLI utilities);
    note that these resources make no sensible utility under other RMs

* `clonable-0`:
   - resource agents that do care whether they are run as a standalone
     resources or as an scale-out deployment

* `repurposable-0`:
   - resource agents that are used to act in various roles and switching
     between them (actually, a specialization of `clonable-0`)


## Semantics

An example of a valid meta data output is provided in
[`ra-metadata-example.xml`](ra-metadata-example.xml).
