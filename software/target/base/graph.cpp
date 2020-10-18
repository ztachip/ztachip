#include <time.h>
#include <stdarg.h>
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
   m_outputAvail=0;
   m_queue=queue;
   m_lastRequestId=0;
   m_lastResponseId=0;
}

Graph::~Graph() {
   M_graphLst[m_queue]=0;
}

// Clear all the nodes from graph

ZtaStatus Graph::Clear() {
   m_nextNodeToSchedule=-1;
   m_nodes.clear();
   m_sinker=0;
   m_outputAvail=0;
   return ZtaStatusOk;
}

// Add a GraphNode to the Graph
// Execution order of GraphNodes are same order as they are being added
// to Graph...

ZtaStatus Graph::Add(GraphNode *node) {
   m_nodes.push_back(node);
   if(node->GetType()==GraphNodeTypeSinker)
      m_sinker=(GraphNodeSinker *)node;
   return ZtaStatusOk;
}

// Consume a result. Advance sinker node to next one for
// received output

ZtaStatus Graph::Consume() {
   if(!m_sinker)
      return ZtaStatusFail;
   if(m_outputAvail <= 0)
      return ZtaStatusFail;
   m_outputAvail--;
   return m_sinker->Consume();
}

void *Graph::GetOutputBuf(int _idx) {
   if(!m_sinker)
      return 0;
   return m_sinker->GetBuf(_idx);
}

int Graph::GetOutputBufLen(int _idx) {
   if(!m_sinker)
      return ZtaStatusFail;
   return m_sinker->GetBufLen(_idx);
}

int Graph::GetOutputDimension(int _idx,int _dimIdx) {
   if(!m_sinker)
      return ZtaStatusFail;
   return m_sinker->GetDimension(_idx,_dimIdx);
}

TENSOR *Graph::GetOutputTensor(int _idx) {
   if(!m_sinker)
      return 0;
   return m_sinker->GetTensor(_idx);
}


// Verify the graph
// Verify each nodes in the graph

ZtaStatus Graph::Verify() {
   // Make sure we have one sinker and it must be the last one
   for(int i=0;i < ((int)m_nodes.size()-1);i++) {
      if(m_nodes[i]->GetType()==GraphNodeTypeSinker) {
         printf("Sinker node must be the last node\n");
         return ZtaStatusFail;
      }
   }
   for(int i=0;i < (int)m_nodes.size();i++) {
      if(m_nodes[i]->Verify() != ZtaStatusOk)
         return ZtaStatusFail;
   }
   return ZtaStatusOk;
}

// Schedule the graph nodes for execution...
// GraphNodes are scheduled in the order they are pushed to the
// Graph

ZtaStatus Graph::Schedule() {
   ZtaStatus rc;
   if(m_nextNodeToSchedule < 0) {
      // Begin of a scheduling...
      if((m_outputAvail+1) > GRAPH_MAX_PIPELINE)
         return ZtaStatusFail;
//printf("SCHEDULE[%d] \n",m_queue);
      m_nextNodeToSchedule=0;
      clock_gettime(CLOCK_REALTIME, &m_tic);
   }
   while(m_nextNodeToSchedule < (int)m_nodes.size()) {
      GraphNode::CheckResponse();
      rc=m_nodes[m_nextNodeToSchedule]->Schedule(m_queue);
      if(rc==ZtaStatusPending)
         return ZtaStatusPending;
      if(rc!=ZtaStatusOk)
         return rc;
      m_nextNodeToSchedule++;
   }
   return ZtaStatusOk;
}

// Wait for graph to complete execution

ZtaStatus Graph::Wait(int timeout) {
   GraphNode::CheckResponse();
   if(m_nextNodeToSchedule < 0)
      return ZtaStatusOk;
   if(m_nextNodeToSchedule < (int)m_nodes.size()) {
      Schedule();
      return ZtaStatusPending;
   }
   if(m_lastResponseId==m_lastRequestId) {
      m_nextNodeToSchedule=-1;
      clock_gettime(CLOCK_REALTIME, &m_toc);
      m_timeElapsed = (m_toc.tv_sec-m_tic.tv_sec)*1000000+
         +(m_toc.tv_nsec-m_tic.tv_nsec)/1000;
      m_outputAvail++;
      return ZtaStatusOk;
   }
   else
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
   for(;;) {
      ztaSerial();
      if(ztahostMsgReadAvail()<3) {
         return ZtaStatusOk; // No response yet
      }
      ztahostMsgReadInt();
      resp=ztahostMsgReadInt();
      ztahostMsgReadInt();
      queue=(resp>>24);
      resp=(resp&0xFFFFFF);
      assert(queue < GRAPH_MAX_INSTANCE);
      M_graphLst[queue]->m_lastResponseId=resp;
   }
   ztaSerial();
   return ZtaStatusOk;
}

// Allocate and return the next request id

uint32_t GraphNode::GetNextRequestId(int queue) {
   Graph *g=M_graphLst[queue];
   g->m_lastRequestId++;
   if((g->m_lastRequestId & 0xFF000000) != 0)
      g->m_lastRequestId=0;
//printf("[%d] Request id=%d \n",queue,g->m_lastRequestId);
   return g->m_lastRequestId+(queue<<24);
}

bool GraphNode::AllRequestAreCompleted(int queue) {
   Graph *g=M_graphLst[queue];
   return g->m_lastRequestId==g->m_lastResponseId;
}

// Sink graph node
// All graphs terminated with a sink node

GraphNodeSinker::GraphNodeSinker() {
   m_head=m_tail=0;
}

GraphNodeSinker::~GraphNodeSinker() {
}

GraphNodeType GraphNodeSinker::GetType() {
   return GraphNodeTypeSinker;
}

ZtaStatus GraphNodeSinker::Create(int numInput,...) {
   va_list args;
   TENSOR *t;
   m_inputTensor.clear();
   va_start(args,numInput);
   for(int i=0;i < numInput;i++) {
      t=va_arg(args,TENSOR *);
      m_inputTensor.push_back(t);
   }
   va_end(args);
   m_head=0;
   m_tail=0;
   return ZtaStatusOk;
}

ZtaStatus GraphNodeSinker::Verify() {
   TENSOR *t;
   int numInput=m_inputTensor.size();
   Cleanup();
   // Allocate external buffers for all input tensors to the
   // sunk node;
   for(int i=0;i < GRAPH_MAX_PIPELINE;i++) {
      for(int j=0;j < numInput;j++) {
         t=new TENSOR();
         t->Clone(m_inputTensor[j]);
         m_buffers[i].push_back(t);
      }
   }
   for(int i=0;i < numInput;i++) {
      m_inputTensor[i]->Alias(m_buffers[m_head][i]);
   }
   return ZtaStatusOk;
}

ZtaStatus GraphNodeSinker::Schedule(int queue) {
   m_head=(m_head+1)%GRAPH_MAX_PIPELINE;
   for(int i=0;i < (int)m_inputTensor.size();i++) {
      m_inputTensor[i]->Alias(m_buffers[m_head][i]);
   }
   return ZtaStatusOk;
}

void *GraphNodeSinker::GetBuf(int _idx) {
   return m_buffers[m_tail][_idx]->GetBuf();
}

int GraphNodeSinker::GetBufLen(int _idx) {
   return m_buffers[m_tail][_idx]->GetBufLen();
}

int GraphNodeSinker::GetDimension(int _idx,int _dimIdx) {
   return m_buffers[m_tail][_idx]->GetDimension(_dimIdx);
}

ZtaStatus GraphNodeSinker::Consume() {
   m_tail=(m_tail+1)%GRAPH_MAX_PIPELINE;
   return ZtaStatusOk;
}


ZtaStatus GraphNodeSinker::Cleanup() {
   for(int i=0;i < GRAPH_MAX_PIPELINE;i++) {
     for(int j=0;j < (int)m_buffers[i].size();j++) {
        delete m_buffers[i][j];
     }
     m_buffers[i].clear(); 
   }
   m_head=m_tail=0;
   return ZtaStatusOk;
}
