#
# This example convert color input from webcam to monochrome for display
# Execution graph:
#   1. Copy webcam input to display. During copying, for each pixel, compute [R,G,B]=MonoValue(R,G,B)
# Program runs until push button is pressed
import zta

tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
n1=zta.GraphNodeCopyAndTransform(tensorInput,tensorOutput,zta.MONO3,zta.INTERLEAVED)
graph=zta.Graph(n1)
while (zta.ButtonState()==0):
   if(zta.CameraCapture()) :
       graph.Run()
       zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
       zta.DisplayFlushCanvas()
zta.DeleteAll()

