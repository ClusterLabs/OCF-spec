**JOIN THE developers@clusterlabs.org MAILING LIST AND FOLLOW PULL REQUESTS
AT https://github.com/ClusterLabs/OCF-spec/ TO DISCUSS CHANGES**

# Open Clustering Framework Resource Agent Meta Data

This document complements [Open Clustering Framework Resource Agent API](
resource-agent-api.md) (referred to as API) that establishes a wider context
for this separate model for declarative data format (referred to as meta data)
providing the discoverability of resource agent properties.

URL: https://github.com/ClusterLabs/OCF-spec/blob/master/ra/1.1/resource-agent-metadata.md
Relavant as of: 1.1
Status: OFFICIAL


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


## Semantics

An example of a valid meta data output is provided in
[`ra-metadata-example.xml`](ra-metadata-example.xml).
