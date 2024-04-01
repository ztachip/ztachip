#
# This example performs optical-flow algorithm to detect motion
# Execution graph:
#   1. Copy webcam input to t1. During copying, reformat to output format MMM... where M=MonoValue(R,G,B) 
#   2. Perform OpticalFlow algo on t1 and result to t2. Motion information is encoded as colored pixel on t2.
#   3. Copy t2 to display. Display has format RGBRGB...
# Program runs until push button is pressed
#
# Reference ztachip/micropython/MicropythonUserGuide.md documentation for more details.
#


import zta

tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
t1 = zta.Tensor()
t2= zta.Tensor()
n1=zta.GraphNodeCopyAndTransform(tensorInput,t1,zta.MONO1,zta.PLANAR)
n2=zta.GraphNodeOpticalFlow(t1,t2)
n3=zta.GraphNodeCopyAndTransform(t2,tensorOutput,zta.COLOR,zta.INTERLEAVED)
graph=zta.Graph(n1,n2,n3)
while (zta.ButtonState()==0):
   if(zta.CameraCapture()) :
       graph.Run()
       zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
       zta.DisplayFlushCanvas()
zta.DeleteAll()

