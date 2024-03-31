#
# This example performs Canny edge detection on webcam input and then display
# the result
# Execution graph:
#   1. Copy webcam input to t1. Reformat t1 to have format RR..GG...BB..
#   2. Perform canny edge detection on t1 and result to t2, t2 has a single color plane format
#   3. Copy t2 to display. During copying, reformat to format RGBRGB... with R=G=B
# Program runs until push button is pressed
#
import zta

tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
t1 = zta.Tensor()
t2= zta.Tensor()
n1=zta.GraphNodeCopyAndTransform(tensorInput,t1,zta.MONO1,zta.PLANAR)
n2=zta.GraphNodeCanny(t1,t2)
n2.SetThreshold(50,100)
n3=zta.GraphNodeCopyAndTransform(t2,tensorOutput,zta.MONO3,zta.INTERLEAVED)
graph=zta.Graph(n1,n2,n3)
while (zta.ButtonState()==0):
   if(zta.CameraCapture()) :
       graph.Run()
       zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
       zta.DisplayFlushCanvas()
zta.DeleteAll()

