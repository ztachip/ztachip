#
# This example performs Harris-Corner detection algorithm to find point of interests.
# Execution graph:
#   1. Copy webcam input to t1. During copying, reformat to output format MMM... where M=MonoValue(R,G,B) 
#   2. Perform Harris-Corner detection on t1. This algo expects monochrome input
#   3. Copy webcam input to display
# Program runs until push button is pressed
#
# Reference ztachip/micropython/MicropythonUserGuide.md documentation for more details.
#


import zta

tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
t1 = zta.Tensor()
n1=zta.GraphNodeCopyAndTransform(tensorInput,t1,zta.MONO1,zta.PLANAR)
n2=zta.GraphNodeHarris(t1)
n3=zta.GraphNodeCopyAndTransform(tensorInput,tensorOutput,zta.COLOR,zta.INTERLEAVED)
graph=zta.Graph(n1,n2,n3)
while (zta.ButtonState()==0):
   if(zta.CameraCapture()) :
       graph.Run()
       points=n2.GetPOI()
       for point in points:
          zta.CanvasDrawPoint(point[1],point[0])
       zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
       zta.DisplayFlushCanvas()
zta.DeleteAll()

