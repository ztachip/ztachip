#
# Running LLM model smolLM2-135M-Instruct from Hugging face
# Reference ztachip github page on how to generate SMOLLM2.ZUF from SmolLM2-135M-Instruct.gguf
# Or download SMOLLM2.ZUF from https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLLM2.ZUF
# Then copy SMOLLM2.ZUF to TFTP download directory
# Then chat with the chatbot
# Reference ztachip/micropython/MicropythonUserGuide.md documentation for more details.
#


import zta

FONTSZ=16

LINE_MAX_LEN=40-1

lines=["","Enter a question","ztachip chatbot"]

inputMode=True;

blinkOn=False;

userPrompt=""

SYSTEM_PROMPT = (
"You are a helpful assistant"
)


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

zta.CanvasDrawText("Downloading model file...",0,0)
zta.DisplayFlushCanvas()

zta.ConsoleCapture(True);
tensorInput = zta.TensorCamera()
tensorOutput = zta.TensorDisplay()
n1=zta.GraphNodeCopyAndTransform(tensorInput,tensorOutput,zta.COLOR,zta.INTERLEAVED)
graph=zta.Graph(n1)
n2=zta.GraphNodeLLM("SMOLLM2.ZUF",SYSTEM_PROMPT,0.6,0.9,0.05,40,40)
graphLLM=zta.Graph(n2)
while (zta.ButtonState()==0):
    if(zta.CameraCapture()) :
        graph.Run()
        zta.CanvasDrawText(lines[2],0,0)
        zta.CanvasDrawText(lines[1],16,0)
        zta.CanvasDrawText(lines[0],32,0)
        if(inputMode==True) :
            if(blinkOn==True) :
                blinkOn=False
                zta.CanvasDrawText("_",32,FONTSZ*len(lines[0]))
            else :
                blinkOn=True
                zta.CanvasDrawText(" ",32,FONTSZ*len(lines[0]))
        zta.DisplayFlushCanvas()
    s=n2.Response()
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
            n2.UserPrompt(userPrompt)
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
            # We have the full response ready...
            inputMode=True
            if "!LED_ON" in lines[0]:
                zta.SetLed(15)
            elif "!LED_OFF" in lines[0] :
                zta.SetLed(0)
            ui("\n")
zta.ConsoleCapture(False)
zta.DeleteAll()

