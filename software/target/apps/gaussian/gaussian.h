#ifndef _TARGET_APPS_GAUSSIAN_GAUSSIAN_H_
#define _TARGET_APPS_GAUSSIAN_GAUSSIAN_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do gaussian convolution on an image
// The effect is image blurring

class GraphNodeGaussian : public GraphNode {
public:
   GraphNodeGaussian();
   GraphNodeGaussian(TENSOR *input,TENSOR *output);
   virtual ~GraphNodeGaussian();
   ZtaStatus Create(TENSOR *input,TENSOR *output);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Schedule(int queue);
   void SetSigma(float _sigma);
   float GetSigma();
private:
   void Cleanup();
   float gaussian(int x,int y,float sigma);
   void BuildKernel();
private:
   TENSOR *m_input;
   TENSOR *m_output;
   int m_w;
   int m_h;
   int m_nChannel;
   int m_ksz;
   uint32_t m_func;
   float m_sigma;
   ZTA_SHARED_MEM m_kernel;
};

#endif
