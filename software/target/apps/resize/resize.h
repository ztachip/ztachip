#ifndef _TARGET_APPS_RESIZE_RESIZE_H_
#define _TARGET_APPS_RESIZE_RESIZE_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do image resize
// Resize using boxing method

class GraphNodeResize : public GraphNode {
public:
   GraphNodeResize();
   GraphNodeResize(TENSOR *input,TENSOR *output,int w,int h);
   ZtaStatus Create(TENSOR *input,TENSOR *output,int w,int h);
   virtual ~GraphNodeResize();
   virtual ZtaStatus Verify();
   virtual ZtaStatus Schedule(int queue);
private:
   void Cleanup();
   static float spuCallback(float input,void *pparm,uint32_t parm);
private:
   uint32_t m_func;
   int m_src_w;
   int m_src_h;
   int m_dst_w;
   int m_dst_h;
   int m_nChannel;
   TENSOR *m_input;
   TENSOR *m_output;
   ZTA_SHARED_MEM m_temp;
   ZTA_SHARED_MEM m_filter[2];
   ZTA_SHARED_MEM m_filteri[2];
   int m_filterLen[2];
   int m_scale_denomitor[2];
   ZTA_SHARED_MEM m_spu;
};

#endif
