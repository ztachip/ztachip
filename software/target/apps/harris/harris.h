#ifndef _TARGET_APPS_HARRIS_HARRIS_H_
#define _TARGET_APPS_HARRIS_HARRIS_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do harris-corder detection
// Refer to https://en.wikipedia.org/wiki/Harris_Corner_Detector

class GraphNodeHarris : public GraphNode {
public:
   GraphNodeHarris();
   GraphNodeHarris(TENSOR *input,TENSOR *output);
   virtual ~GraphNodeHarris();
   ZtaStatus Create(TENSOR *input,TENSOR *output);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Schedule(int queue);
private:
   void Cleanup();
private:
   TENSOR *m_input;
   TENSOR *m_output;
   int m_w;
   int m_h;
   int m_nChannel;
   uint32_t m_func;
   ZTA_SHARED_MEM m_x_gradient;
   ZTA_SHARED_MEM m_y_gradient;
   ZTA_SHARED_MEM m_score;   
};

#endif
