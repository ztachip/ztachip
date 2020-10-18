#ifndef __TARGET_BASE_GRAPH_H__
#define __TARGET_BASE_GRAPH_H__

#include <time.h>
#include "tensor.h"

// Maxumum pipeline for a graph

#define GRAPH_MAX_PIPELINE  2

#define GRAPH_MAX_INSTANCE 2

typedef enum {
   GraphNodeTypeProcessing, // Node that do the processing
   GraphNodeTypeSource, // Node to represent input, must be first node of the graph
   GraphNodeTypeSinker // Node to represent last stage of the graph
} GraphNodeType;

// A node in the execution graph
// This is a pure virtual class and to be implemented
// Graph node execution stages are as followed...
//    Create stage: Nodes are created with appropriate connections with other nodes.
//    Verify stage: Check input/output tensors. If tensors are undefined then initialize them
//    Schedule stage: Send commands to ztachip to perform the functions
//    Wait stage: Wait for result to be completed.

class GraphNode {
public:
   GraphNode();
   virtual ~GraphNode(); 
   virtual ZtaStatus Verify()=0; // Verify input/output/parameter
   virtual ZtaStatus Schedule(int queue)=0; // Schedule for execution. 
   virtual GraphNodeType GetType();
public:
   static ZtaStatus CheckResponse();
   bool AllRequestAreCompleted(int queue);
   uint32_t GetNextRequestId(int queue);
};

// Class for sinker node
// All graphs terminated with sinker node

class GraphNodeSinker: public GraphNode {
public:
   GraphNodeSinker();
   ~GraphNodeSinker();
   ZtaStatus Create(int numInput,...);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Schedule(int queue); 
   void *GetBuf(int _idx);
   int GetBufLen(int _idx);
   ZtaStatus Consume();
   int GetDimension(int _idx,int _dimIdx);
   virtual GraphNodeType GetType();
   TENSOR *GetTensor(int _idx) {return m_buffers[m_tail][_idx];}
private:
   ZtaStatus Cleanup();
private:
   std::vector<TENSOR *> m_inputTensor;
   std::vector<TENSOR *> m_buffers[GRAPH_MAX_PIPELINE];
   int m_head;
   int m_tail;
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
   ZtaStatus Schedule();
   ZtaStatus Wait(int timeout);
   ZtaStatus Consume();
   bool IsBusy() {return m_nextNodeToSchedule >= 0;}

   int GetOutputAvail() {return m_outputAvail;}
   void *GetOutputBuf(int _idx);
   int GetOutputBufLen(int _idx);
   int GetOutputDimension(int _idx,int _dimIdx);
   TENSOR *GetOutputTensor(int _idx);
   uint32_t GetElapsedTime() {return m_timeElapsed;}
private:
   struct timespec m_tic;
   struct timespec m_toc; 
   std::vector<GraphNode *> m_nodes;
   int m_nextNodeToSchedule;
   uint32_t m_timeElapsed;
   GraphNodeSinker *m_sinker;
   int m_outputAvail;
   int m_queue;
public:
   uint32_t m_lastRequestId;
   uint32_t m_lastResponseId;
};

#endif
