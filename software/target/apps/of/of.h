#ifndef _TARGET_APPS_OF_OF_H_
#define _TARGET_APPS_OF_OF_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do optical flow using Lucas-Kanade algorithm
// https://en.wikipedia.org/wiki/Lucas%E2%80%93Kanade_method

class GraphNodeOpticalFlow : public GraphNode {
public:
   GraphNodeOpticalFlow();
   GraphNodeOpticalFlow(TENSOR *input1,
                        TENSOR *x_gradient,
                        TENSOR *y_gradient,
                        TENSOR *t_gradient,
                        TENSOR *x_vect,
                        TENSOR *y_vect,
                        TENSOR *display);
   virtual ~GraphNodeOpticalFlow();
   ZtaStatus Create(TENSOR *input1,
                    TENSOR *x_gradient,
                    TENSOR *y_gradient,
                    TENSOR *t_gradient,
                    TENSOR *x_vect,
                    TENSOR *y_vect,
                    TENSOR *display);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Schedule(int queue);
private:
   void Cleanup();
   static float SpuCallback(float _in,void *pparm,uint32_t parm);
   static float SpuDisplayLeftHorizontalCallback(float _in,void *pparm,uint32_t parm);
   static float SpuDisplayRightHorizontalCallback(float _in,void *pparm,uint32_t parm);
   static float SpuDisplayVerticalCallback(float _in,void *pparm,uint32_t parm);
private:
   TENSOR *m_input1;
   TENSOR *m_x_gradient;
   TENSOR *m_y_gradient;
   TENSOR *m_t_gradient;
   TENSOR *m_x_vect;
   TENSOR *m_y_vect;
   TENSOR *m_display;
   int m_w;
   int m_h;
   int m_nChannel;
   uint32_t m_func;
   ZTA_SHARED_MEM m_spu;
   TENSOR m_buffer[2];
   int m_bufferHead;
};

#endif
