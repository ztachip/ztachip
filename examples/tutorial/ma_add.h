#ifndef _EXAMPLES_TUTORIAL_MA_ADD_H_
#define _EXAMPLES_TUTORIAL_MA_ADD_H_ 

#include "../../software/target/base/tensor.h"
#include "../../software/target/base/graph.h"

// Graph node to do gaussian convolution on an image
// The effect is image blurring

class GraphNodeMaAdd : public GraphNode {
public:
   GraphNodeMaAdd();
   GraphNodeMaAdd(TENSOR *input1,TENSOR *input2,TENSOR *output);
   virtual ~GraphNodeMaAdd();
   ZtaStatus Create(TENSOR *input1,TENSOR *input2,TENSOR *output);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Schedule(int queue);
private:
   TENSOR *m_input1;
   TENSOR *m_input2;
   TENSOR *m_output;
   uint32_t m_func;
};

#endif
