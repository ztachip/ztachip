#
# This example performs TensorFlowLite's SSD-Mobinet AI algorithm for object detection
# ztachip uses the same tflite model from TensorFlowLite without any retraining or adaptation.
# Execution graph:
#   1. Copy webcam input to t1. Reformat t1 to format RR..GG..BB 
#   2. Resize t1 to dimension 300x300. SSD-Mobinet expects this input size. 
#   3. Perform SSD-Mobinet object detection algo.
#   4. Copy webcam input to display. Display has format RGBRGB...
# Program runs until push button is pressed
#
# Reference ztachip/micropython/MicropythonUserGuide.md documentation for more details.
#

import zta

tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
t1 = zta.Tensor()
t2 = zta.Tensor()
n1=zta.GraphNodeCopyAndTransform(tensorInput,t1,zta.COLOR,zta.PLANAR)
n2=zta.GraphNodeResize(t1,t2,300,300)
n3=zta.GraphNodeObjectDetection(t2)
n4=zta.GraphNodeCopyAndTransform(tensorInput,tensorOutput,zta.COLOR,zta.INTERLEAVED)
graph=zta.Graph(n1,n2,n3,n4)
while (zta.ButtonState()==0):
   if(zta.CameraCapture()) :
       graph.Run()
       objects=n3.GetObjects()
       zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
       for object in objects:
          zta.CanvasDrawText(object[5],object[1],object[0])
          zta.CanvasDrawRectangle((object[1],object[0]),(object[3],object[2]))
       zta.DisplayFlushCanvas()
zta.DeleteAll()



