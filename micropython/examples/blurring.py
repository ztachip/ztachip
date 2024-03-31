#
# This example performs gaussian blurring algorithm
# Execution graph:
#   1. Copy webcam input to t1. During copying, reformat to output format RR..GG..BB.. 
#   2. Perform blurring on t1 and output result to t2, t2 has format RR..GG..BB..
#   3. Copy t2 to display, reformat to output format RGBRGB..
# Program runs until push button is pressed

import zta

tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
t1 = zta.Tensor()
t2= zta.Tensor()
n1=zta.GraphNodeCopyAndTransform(tensorInput,t1,zta.COLOR,zta.PLANAR)
n2=zta.GraphNodeGaussian(t1,t2)
n2.SetSigma(3.0)
n3=zta.GraphNodeCopyAndTransform(t2,tensorOutput,zta.COLOR,zta.INTERLEAVED)
graph=zta.Graph(n1,n2,n3)
while (zta.ButtonState()==0):
   if(zta.CameraCapture()) :
       graph.Run()
       zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
       zta.DisplayFlushCanvas()
zta.DeleteAll()

