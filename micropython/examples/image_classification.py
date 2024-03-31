
#
# This example performs TensorFlowLite's Mobinet AI algorithm for image classification
# ztachip uses the same tflite model from TensorFlowLite without any retraining or adaptation.
# Execution graph:
#   1. Copy webcam input to t1. Reformat t1 to format RR..GG..BB 
#   2. Resize t1 to dimension 224x224. Mobinet expects this input size. 
#   3. Perform Mobinet Image Classification algo.
#   4. Copy webcam input to display. Display has format RGBRGB...
# Program runs until push button is pressed
#

import zta

tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
t1 = zta.Tensor()
t2 = zta.Tensor()
n1=zta.GraphNodeCopyAndTransform(tensorInput,t1,zta.COLOR,zta.PLANAR)
n2=zta.GraphNodeResize(t1,t2,224,224)
n3=zta.GraphNodeImageClassifier(t2)
n4=zta.GraphNodeCopyAndTransform(tensorInput,tensorOutput,zta.COLOR,zta.INTERLEAVED)
graph=zta.Graph(n1,n2,n3,n4)
while (zta.ButtonState()==0):
   if(zta.CameraCapture()) :
       graph.Run()
       top5=n3.GetTop5()
       zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
       r=16
       for top5Item in top5:
          zta.CanvasDrawText('{} 0.{:02d} '.format(top5Item[1],(top5Item[0]*100)>>8),r,0)
          r+=16
       zta.DisplayFlushCanvas()
zta.DeleteAll()

