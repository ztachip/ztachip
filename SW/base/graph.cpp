//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

#include <time.h>
#include <stdarg.h>
#include <unistd.h>
#include "ztahost.h"
#include "tensor.h"
#include "graph.h"

// Execution graph object

static Graph *M_graphLst[GRAPH_MAX_INSTANCE]={0,0};

Graph::Graph(int queue) {
   assert(queue < GRAPH_MAX_INSTANCE);
   assert(!M_graphLst[queue]);
   M_graphLst[queue]=this;
   m_nextNodeToSchedule=-1;
   m_timeElapsed=0;
   m_queue=queue;
   m_lastRequestId=0;
   m_lastResponseId=0xffffffff;
}

Graph::~Graph() {
   M_graphLst[m_queue]=0;
}

// Clear all the nodes from graph

ZtaStatus Graph::Clear() {
   m_nextNodeToSchedule=-1;
   m_nodes.clear();
   return ZtaStatusOk;
}

// Add a GraphNode to the Graph
// Execution order of GraphNodes are same order as they are being added
// to Graph...

ZtaStatus Graph::Add(GraphNode *node) {
   m_nodes.push_back(node);
   return ZtaStatusOk;
}

// Verify the graph
// Verify each nodes in the graph

ZtaStatus Graph::Verify() {
   for(int i=0;i < (int)m_nodes.size();i++) {
      if(m_nodes[i]->Verify() != ZtaStatusOk)
         return ZtaStatusFail;
   }
   return ZtaStatusOk;
}

// Prepare the graph nodes for execution...
// GraphNodes are scheduled in the order they are pushed to the
// Graph

ZtaStatus Graph::Prepare() {
   if(m_nextNodeToSchedule < 0) {
      // Begin of a scheduling...
      m_nextNodeToSchedule=0;
      return ZtaStatusOk;
   } else {
      return ZtaStatusFail;
   }
}

// Execute graph

ZtaStatus Graph::Run(int timeout) {
   ZtaStatus rc;
   if(m_nextNodeToSchedule < 0)
      return ZtaStatusOk;
   while(m_nextNodeToSchedule < (int)m_nodes.size()) {
      rc=m_nodes[m_nextNodeToSchedule]->Prepare(m_queue,(timeout>=0)?true:false);
      if(rc==ZtaStatusPending)
         break;
      if(rc!=ZtaStatusOk)
         return rc;
      m_nextNodeToSchedule++;
      if(timeout>=0)
         break;
   }
   GraphNode::CheckResponse();
   if((m_lastResponseId==m_lastRequestId) &&
      (m_nextNodeToSchedule >= (int)m_nodes.size())) {
      // Done...
      m_nextNodeToSchedule=-1;
      m_timeElapsed = 0;
      return ZtaStatusOk;
   } else
      return ZtaStatusPending;
}

GraphNode::GraphNode() {
}

GraphNode::~GraphNode() {
}

GraphNodeType GraphNode::GetType() {
   return GraphNodeTypeProcessing;
}

// Running the graph.
// Check response queue for any available responses.


ZtaStatus GraphNode::CheckResponse() {
   int queue;
   uint32_t resp;
   // Wait for response....
   while(ZTAM_GREG(0,REG_DP_READ_INDICATION_AVAIL,0)>0) {
	   ZTAM_GREG(0,REG_DP_READ_INDICATION,0);
	   resp=ZTAM_GREG(0,REG_DP_READ_INDICATION_PARM,0);
	   ZTAM_GREG(0,REG_DP_READ_SYNC,0);
	   queue=(resp>>24);
	   resp=(resp&0xFFFFFF);
	   assert(queue < GRAPH_MAX_INSTANCE);
	   M_graphLst[queue]->m_lastResponseId=resp;
   }
   return ZtaStatusOk;
}

// Allocate and return the next request id

uint32_t GraphNode::GetNextRequestId(int queue) {
   Graph *g=M_graphLst[queue];
   g->m_lastRequestId++;
   if((g->m_lastRequestId & 0xFF000000) != 0)
      g->m_lastRequestId=0;
   return g->m_lastRequestId+(queue<<24);
}

bool GraphNode::AllRequestAreCompleted(int queue) {
   Graph *g=M_graphLst[queue];
   return g->m_lastRequestId==g->m_lastResponseId;
}

