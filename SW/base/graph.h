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

#ifndef __TARGET_BASE_GRAPH_H__
#define __TARGET_BASE_GRAPH_H__

#include "tensor.h"


#define GRAPH_MAX_INSTANCE 8

typedef enum {
   GraphNodeTypeProcessing, // Node that do the processing
   GraphNodeTypeSource // Node to represent input, must be first node of the graph
} GraphNodeType;

// A node in the execution graph
// This is a pure virtual class and to be implemented
// Graph node execution stages are as followed...
//    Create stage: Nodes are created with appropriate connections with other nodes.
//    Verify stage: Check input/output tensors. If tensors are undefined then initialize them
//    Prepare stage: Send commands to ztachip to perform the functions
//    Run stage: Run and wait for result to be completed.

class GraphNode {
public:
   GraphNode();
   virtual ~GraphNode(); 
   virtual ZtaStatus Verify()=0; // Verify input/output/parameter
   virtual ZtaStatus Prepare(int queue,bool stepMode)=0; // Schedule for execution.
   virtual GraphNodeType GetType();
public:
   static ZtaStatus CheckResponse();
   bool AllRequestAreCompleted(int queue);
   uint32_t GetNextRequestId(int queue);
};

// Graph is a container of GraphNode
// GraphNodes execution are coordinated by Graph

class Graph {
public:
   Graph(int queue=0);
   ~Graph();
   ZtaStatus Clear();
   ZtaStatus Add(GraphNode *node);
   ZtaStatus Verify();
   ZtaStatus Prepare();
   ZtaStatus Run(int timeout);
   inline ZtaStatus RunUntilCompletion() {
      ZtaStatus rc;
	  for(;;) {
         rc=Run(-1);
         if(rc==ZtaStatusOk)
            return rc;
         if(rc != ZtaStatusPending)
            return ZtaStatusFail;
      }
   }
   bool IsRunning() {return m_nextNodeToSchedule >= 0;}
   void *GetOutputBuf(int _idx);
   int GetOutputBufLen(int _idx);
   int GetOutputDimension(int _idx,int _dimIdx);
   TENSOR *GetOutputTensor(int _idx);
   uint32_t GetElapsedTime() {return m_timeElapsed;}
private:
   std::vector<GraphNode *> m_nodes;
   int m_nextNodeToSchedule;
   uint32_t m_timeElapsed;
   int m_queue;
public:
   uint32_t m_lastRequestId;
   uint32_t m_lastResponseId;
};

#endif
