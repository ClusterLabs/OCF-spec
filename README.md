# Open Cluster Framework (OCF)

## What is the OCF?

The Open Cluster Framework (OCF) is a collection of open standards for
high-availability (HA) clustering.

The only standard currently in active use is:

* The OCF Resource Agent API provides a layer of abstraction between cluster
  software and the services managed by the cluster.

## Who is the OCF?

The OCF is maintained and distributed by
[ClusterLabs](https://www.clusterlabs.org/), a community hub for open-source,
high-availability clustering software.

## What is the history of the OCF?

In the early 2000s, open-source, high-availability clustering software was in
its infancy, and there were various implementations. Each needed to do things
like start and stop cluster-managed services, and each implemented this
functionality on its own.

To reduce that duplication of effort, the OCF Project was formed, spearheaded
by Linux HA project developers Alan Robertson and Lars Marowsky-Brée, and
unveiled at the Ottawa Linux Symposium in July 2001. (1)

The original goal was ambitious: create a set of APIs for all functionality
needed by both high-availability and high-performance-computing clusters,
provide a reference implementation, and get all open source projects on board.
The OCF became an official Working Group of the Free Standards Group.

However, by the end of the decade, the situation had changed. The Free
Standards Group had been absorbed into the Linux Foundation, and the "working
group" ceased to exist. The field of open source HA had been winnowed to a few
projects. The high-performance computing community went its own way, and of the
APIs, only the resource agent standard was in active use.

The narrower focus strengthened the community. At a 2015 summit (2),
participants agreed to consolidate efforts under the banner of ClusterLabs,
which took on maintenance of the OCF standards.

(1) ["Introducing the Open Cluster Framework", Linux Journal, Sept. 3, 2002](https://www.linuxjournal.com/article/6143)

(2) ["HA Cluster Summit 2015", plan.alteeva.ca](http://plan.alteeve.ca/index.php/HA_Cluster_Summit_2015)

## How is this repository organized?

The repository has these subdirectories:

* concepts: Some background on clustering
* historical: Standards and implementations no longer used or maintained
* ra: OCF Resource Agent API
  * ra/_number_: A particular (official or draft) version of the standard
    * resource-agent-api.md: The standard
    * ra-metadata-example.xml: Example resource agent meta-data (informational
      only, not part of the standard)
    * ra-api.rng: RelaxNG schema for validating resource agent meta-data
  * ra/latest: Symbolic link to latest official version
  * ra/next: Proposed changes that have not made it into a specific draft yet

## How are the standards maintained?

The standards are maintained in a
[Github repository](https://github.com/ClusterLabs/OCF-spec).

Changes are proposed and discussed via pull requests to the repository.
Topics related to the OCF may also be discussed on the
[users@clusterlabs.org](https://lists.clusterlabs.org/mailman/listinfo/users) and
[developers@clusterlabs.org](https://lists.clusterlabs.org/mailman/listinfo/developers)
mailing lists.
