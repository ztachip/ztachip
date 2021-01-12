#ifndef _EXAMPLES_TUTORIAL_MA_SCALE_H_
#define _EXAMPLES_TUTORIAL_MA_SCALE_H_ 

#include "../../software/target/base/tensor.h"
#include "../../software/target/base/graph.h"

class GraphNodeMaScale : public GraphNode {
public:
   GraphNodeMaScale();
   GraphNodeMaScale(TENSOR *input,TENSOR *output,int scale);
   virtual ~GraphNodeMaScale();
   ZtaStatus Create(TENSOR *input,TENSOR *output,int scale);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Schedule(int queue);
private:
   TENSOR *m_input;
   TENSOR *m_output;
   int m_scale;
   uint32_t m_func;
};

#endif
