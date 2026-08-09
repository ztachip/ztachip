#
# This is an advanced example, it is recommended to you familiarize with other examples first
# before learning this example.
# This example performs multiple vision tasks+LLM and display the results on different
# region of the display. Display is partitioned into 4 tiles to display the results of...
#   - Object detection with SSD-Mobinet (top-left display tile)
#   - Edge detection (top-right display tile)
#   - Harris-Corner for point of interests (bottom-left display tile)
#   - OpticalFlow (bottom-right display tile)
#   - Running a finetuned LLM model SmolLM2-135M-Instruct so that it can do function calling 
#       Download SMOLFC.ZUF from https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLFC.ZUF 
#       Copy SMOLFC.ZUF to the TFTP download directory
#       Ask: Turn on light --> LED is turned on
#       Ask: Turn off light --> LED is turned off
#       Reference LORA documentation on how to fine tune model 
# Reference on other examples on how the graph is setup for each of the tasks above.
# This example also demonstrates the use of multi graph processing. There are 2 graphs...
# Graph1:
#    graph1 is performing faster,non-AI tasks such as edge-detetion,harris-corner and optical-flow 
#    and this graph is allowed to run till completion
# Graph2:
#    graph2 is performing slower AI task SSD-Mobinet, it is allowed to run only upto 40msec before it is paused 
#    and to be resumed later. This allows for graph1 to run on new image without having to wait for graph2 
#    to complete first.
# GraphLLM:
#    Graph to run LLM node
# Program runs until push button is pressed
#
# Reference ztachip/micropython/MicropythonUserGuide.md documentation for more details.
#

import zta

FONTSZ=16

LINE_MAX_LEN=40-1

lines=["","Ask LLM to turn on or off the LED",""]

inputMode=True;

blinkOn=False;

userPrompt=""

#######
### Implement AI chatbot window 
#######

def ui(_s):
    global lines
    if(_s == "\n") :
        lines[2]=lines[1]
        lines[1]=lines[0]
        lines[0]=""
    elif(_s == "\b") :
        lineLen = len(lines[0])
        if(lineLen > 0) :
            lines[0] = lines[0][0:lineLen-1]
    else :
        lines[0] = lines[0] + _s;
        lineLen = len(lines[0])
        if(lineLen > LINE_MAX_LEN) :
            lines[2]=lines[1]
            lines[1]=lines[0][0:LINE_MAX_LEN]
            lines[0]=lines[0][LINE_MAX_LEN:lineLen]


#####
## Main loop
#####

zta.ConsoleCapture(True);
tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
t1=zta.Tensor()
t2=zta.Tensor()
t3=zta.Tensor()
t4=zta.Tensor()
t5=zta.Tensor()
t6=zta.Tensor()
t7=zta.Tensor()
n1=zta.GraphNodeCopyAndTransform(tensorInput,t1,zta.COLOR,zta.PLANAR);
n2=zta.GraphNodeResize(t1,t2,320,240);
n3=zta.GraphNodeCopyAndTransform(t2,tensorOutput,zta.COLOR,zta.INTERLEAVED,0,0) # Display @ r=0,c=0
n4=zta.GraphNodeCopyAndTransform(t2,t3,zta.MONO1,zta.PLANAR);
n5=zta.GraphNodeCanny(t3,t4);
n6=zta.GraphNodeCopyAndTransform(t4,tensorOutput,zta.MONO3,zta.INTERLEAVED,0,320) # Display @ r=0,c=320
n7=zta.GraphNodeHarris(t3)
n8=zta.GraphNodeCopyAndTransform(t2,tensorOutput,zta.COLOR,zta.INTERLEAVED,240,0) # Display @ r=240,c=0
n9=zta.GraphNodeOpticalFlow(t3,t5)
n10=zta.GraphNodeCopyAndTransform(t5,tensorOutput,zta.COLOR,zta.INTERLEAVED,240,320) # Display @ r=240,c=320
n11=zta.GraphNodeCopyAndTransform(tensorInput,t6,zta.COLOR,zta.PLANAR);
n12=zta.GraphNodeResize(t6,t7,300,300)
n13=zta.GraphNodeObjectDetection(t7)
n14=zta.GraphNodeLLM("SMOLFC.ZUF","You are a helpful assistant",0.6,0.9,0.05,40,40)
graph=zta.Graph(n1,n2,n3,n4,n5,n6,n7,n8,n9,n10)
graphNN=zta.Graph(n11,n12,n13)
graphLLM=zta.Graph(n14)
objectsValid=False
while (zta.ButtonState()==0):
	if(zta.CameraCapture()) :
		graph.Run()
		zta.CanvasDrawText('{} msec'.format(zta.GetElapsedTimeMsec()),0,0)
		points=n7.GetPOI()
		for point in points:
			zta.CanvasDrawPoint(point[1]+240,point[0])
		if(objectsValid) :
			for object in objects:
				zta.CanvasDrawText(object[5],object[1]>>1,object[0]>>1)
				zta.CanvasDrawRectangle((object[1]>>1,object[0]>>1),(object[3]>>1,object[2]>>1))
		zta.CanvasDrawText(lines[2],27*FONTSZ-1,0)
		zta.CanvasDrawText(lines[1],28*FONTSZ-1,0)
		zta.CanvasDrawText(lines[0],29*FONTSZ-1,0)
		if(inputMode==True) :
			if(blinkOn==True) :
				blinkOn=False
				zta.CanvasDrawText("_",29*FONTSZ-1,FONTSZ*len(lines[0]))
			else :
				blinkOn=True
				zta.CanvasDrawText(" ",29*FONTSZ-1,FONTSZ*len(lines[0]))
		zta.DisplayFlushCanvas()
	graphNN.RunWithTimeout(40)
	if(graphNN.IsBusy()==False):
		objects=n13.GetObjects()
		objectsValid=True

	s=n14.Response()
	if(len(s) > 0) :
		if(inputMode==False) : 
			ui(s)
	ch = zta.ConsoleRead()
	if(ch != 0) :
		if(inputMode == False) :
			ui("\n")
		inputMode = True
		if(ch == 13) :
			ui("\n")
			n14.UserPrompt(userPrompt)
			userPrompt = ""
			inputMode = False
			graphLLM.RunWithTimeout(10)
		elif(ch==8) :
			if(len(userPrompt)>0) :
				ui("\b")
				userPrompt = userPrompt[0:len(userPrompt)-1]
		else :
			ui(chr(ch))
			userPrompt = userPrompt+chr(ch)
	if(graphLLM.IsBusy()) :
		graphLLM.RunWithTimeout(40)
	else :
		if(inputMode==False) :
			inputMode=True
			if "!LED_ON" in lines[0]:
				zta.SetLed(15)
			elif "!LED_OFF" in lines[0] :
				zta.SetLed(0)
			ui("\n")

zta.ConsoleCapture(False);
zta.DeleteAll()

