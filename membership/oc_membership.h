#ifndef OCF_OC_MEMBERSHIP_H
#	define OCF_OC_MEMBERSHIP_H
/*
 * <ocf/oc_membership.h> - membership APIs (version 0.1)
 *
 * The structures and functions in this header file work closely with
 * the oc_event.h event infrastructure.  All (edata, esize) parameters
 * to functions in this header file refer to membership event bodies.
 * It is expected that all such are received by this mechanism.
 *
 *
 * There are a few things in this header file which don't really belong here
 * but are needed and they aren't in any other header file.
 *
 * These are:
 *	definition of	oc_node_id_t
 *			oc_cluster_handle_t
 *
 * Maybe we ought to put common types into an <ocf/oc_types.h>
 *
 * The oc_cmp_node_id() and oc_localnodeid() functions also belong in
 * some more global header file.
 *
 * oc_member_eventttype_t and *	oc_member_uniqueid_t are membership-unique
 * and don't belong in a set of ocf-common header files (IMHO)
 *
 * Copyright (C) 2002 Alan Robertson <alanr@unix.sh>
 *
 *	This copyright will be assigned to the Free Standards Group
 *	in the future.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of version 2.1 of the GNU Lesser General Public
 * License as published by the Free Software Foundation.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <stddef.h>
#include <ocf/oc_event.h>

#ifdef HAVE_UUID_UUID_H
#	include <uuid/uuid.h>
#else

typedef unsigned char uuid_t[16];

#endif
						/* controversial? */
typedef void *					oc_cluster_handle_t;
typedef uuid_t					oc_node_id_t;
typedef enum oc_member_eventtype_e		oc_member_eventtype_t;
typedef struct oc_member_uniqueid_s		oc_member_uniqueid_t;

/*
 *	A few words about the oc_node_id_t:
 *
 *	An oc_node_id_t is assigned to a node no later than when it first
 *	joins a cluster, and it will not change while that node is active
 *	in some partition in the cluster.  It is normally expected to
 *	be assigned to a node, and not changed afterwards except by
 *	adminstrative intervention.
 *
 *	The mechanism for assigning oc_node_id_t's to nodes is outside the
 *	scope of this specification.  The only basic operation which
 *	can be performed on these objects is comparison.
 *
 *	See oc_cmp_node_id() for comparisons between them.
 */

/*
 * oc_member_uniqueid_t
 * The values of these fields are guaranteed to be the same across
 * all nodes within a given partition, and guaranteed to be different
 * between all active partitions in the cluster.
 *
 * In other words, if you exchange current oc_member_uniqueid_t objects
 * with another cluster node, you can tell with certainty, whether or not
 * you and the other node are currently members of the same partition.
 *
 * The m_instance field is guaranteed to be unique to a particular
 * membership instance while that node is active in the cluster.
 * If a node is shut down and restarts, then the m_instance might
 * repeat a value it had in the past.
 *
 * See oc_cmp_uniqueid() for comparing them.
 *
 * The meaning of the uniqueid field is not defined by this specification.
 * It may be the node_id of a node in the cluster or it may be a unique
 * checksum or it may be some other value.  All that is specified is that
 * it and the m_instance are unique when taken as a whole.
 */
typedef unsigned char oc_mbr_uuid[16];
struct oc_member_uniqueid_s {
	unsigned	m_instance;
	oc_mbr_uniqueid	uniqueid;
};
/*
 * This enumeration is used both to indicated the type of an event
 * received, and to request the types of events one wants delivered.
 * (see oc_member_request_events() and oc_member_etype() for more
 * details on how this is used).
 */

enum oc_member_eventtype_e {
	OC_NOT_MEMBERSHIP,	/* Not a (valid) membership event */
	OC_FULL_MEMBERSHIP,	/* full membership update */
	OC_INCR_MEMBERSHIP,	/* incremental membership update */
};


#ifdef __cplusplus
extern "C" {
#endif

/*
 *	Returns 0 for equal node_ids,
 *	negative for node id l less than node id r
 *	positive for node id l greater than node id r
 *
 *	No meaning may be ascribed to the fact that a particular
 *	node id is greater or less than some other node id.
 *	The comparison operator is provided primarily for
 *	equality comparisons, and secondarily for use in
 *	sorting them into a canonical order.
 */
int	oc_cmp_node_id(oc_node_id_t l, oc_node_id_t r);


/* Return our local node id */
int oc_localnodeid(oc_node_id_t* us, oc_cluster_handle_t handle);
/*
 *	On failure these functions return -1:
 *	The following errno values are defined:
 *	EINVAL	invalid handle argument
 *	EL2HLT	cluster software not currently running
 */

/* What kind of event did we get? */
/* (see oc_member_request_events() for more details) */
oc_member_eventtype_t oc_member_etype(const void* edata, size_t esize);

/*
 * oc_member_uniqueid() returns the unique identifier associated
 * with this membership event.  See the description in the typedef
 * for more details.
 */
int oc_member_uniqueid(const void* edata, size_t esize,
oc_member_uniqueid_t* u);
/*
 *	Failure of these functions return -1.
 *	The following errno values are defined:
 *	EL2HLT	cluster software not currently running
 *	EINVAL	edata does not refer to a membership event
 */

/* How many nodes of each category do we have? */
int oc_member_n_nodesjoined(const void* edata, size_t esize);
int oc_member_n_nodesgone(void* edata, size_t esize);
int oc_member_n_nodesconst(void* edata, size_t esize);
/*
 *	Failure of these functions return -1.
 *	The following errno values are defined:
 *	EL2HLT	cluster software not currently running
 *	EINVAL	edata does not refer to a membership event
 *	ENOSYS	edata refers to an OC_INCR_MEMBERSHIP update, and
 *		oc_member_n_nodesconst() was called.
 */

/* What nodes of each category do we have? */
oc_node_id_t* oc_member_nodesjoined(const void* edata, size_t esize);
oc_node_id_t* oc_member_nodesgone(void* edata, size_t esize);
oc_node_id_t* oc_member_nodesconst(void* edata, size_t esize);
/*
 *	Failure of these functions return NULL.
 *	The following errno values are defined:
 *	EL2HLT	cluster software not currently running
 *	EINVAL	edata does not refer to a membership event
 *	ENOSYS	edata refers to an OC_INCR_MEMBERSHIP update, and
 *		oc_member_nodesconst() was called.
 */

/* 
 *
 * OC_NO_MEMBERSHIP
 * No membership events will be delivered.  This is the default on opening
 * a membership event connection.
 *
 * OC_FULL_MEMBERSHIP
 * Deliver all membership information including information on
 * members that didn't change.  In this mode, the oc_member_nodesconst()
 * call is supported.
 *
 * OC_INCR_MEMBERSHIP
 * Deliver only changed membership events.  In this mode, calls to
 * oc_member_nodesconst(), et al. are not supported.
 *
 * Setting OC_FULL_MEMBERSHIP or OC_INCR_MEMBERSHIP will result in the
 * delivery of a single OC_FULL_MEMBERSHIP event soon after making
 * this call.  Subsequent events will be delivered as received in the
 * requested style (incremental or full).  Because events may already
 * be pending when this operation is issued, no guarantee can be made
 * regarding when this triggered event will be delivered.
 *
 */
int oc_member_request_events(oc_member_eventtype_t etype, oc_ev_t token);
/*
 *	On failure this function returns -1:
 *	The following errno values are defined:
 *	EINVAL	invalid etype or handle argument
 *	EL2HLT	cluster software not currently running
 *	EBADF	invalid oc_ev_t token parameter
 */

/*
 *	if  l.m_instance < r.m_instance then return -1
 *	if  r.m_instance > r.m_instance then return 1
 *	if l.m_instance == r.m_instance and l.uniqueid == r.uniqueid
 *		then return 0
 *	otherwise return 2
 */
int oc_cmp_uniqueid(const oc_member_uniqueid_t l, const oc_member_uniqueid_t r);

#ifdef __cplusplus
}
#endif

#endif
