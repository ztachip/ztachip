//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include "soc.h"
#include "../base/zta.h"
#include "../base/util.h"
#include "../apps/llm/llm.h"


#ifndef __WIN32__
static char *getInput()
{
    static int inputLen=0;
    static char input[256];
    char ch;

    printf("\r\n>");
    fflush(stdout);
    while(UartReadAvailable())
        ch = UartRead();
    inputLen = 0;
    for(;;) {    
        if(UartReadAvailable()) {
            ch = UartRead();
            printf("%c",ch);
            fflush(stdout);
            if(ch==0x3) {
                input[0] = 0x3;
                input[1] = 0;
                return input;
            }
            else if(ch=='\n' || ch=='\r') {
                printf("\r\n");
                fflush(stdout);
                input[inputLen]=0;
                return input;
            } else if(ch=='\b') {
                if(inputLen > 0)
                    inputLen--;
            } else {
                if(inputLen < (int)(sizeof(input)-1)) {
                    input[inputLen++]=ch;
                }
            } 
        }
    }
    return 0;
}
#endif

static GraphNodeLLM ai;

static Graph graph;

int chat() {
    static std::string output_ref_0,output_ref_1;
    static std::string output;
    int failCount=0;
    int goodCount=0;
    int i;

    ai.Create();
#ifdef __WIN32__
    if (ai.Open("C:\\Users\\vuong\\VM\\XXX.ZUF") != ZtaStatusOk)
        return -1;
#else
    if(ai.Open("SMOLLM2.ZUF") != ZtaStatusOk)
        return -1;
#endif
#ifdef __WIN32__
    ai.SetSamplingPolicyGreedy();
#else
    ai.SetSamplingPolicy(0.6,0.9,0.05,40,40); // temperature=0.7,p-threshold=0.9;min_p=0.05,
#endif
    ai.SystemPrompt((char*)"You answer questions briefly");
    graph.Add(&ai);
    graph.Verify();
    
    for(;;) {
#ifdef __WIN32__
        char* prompt = (char *)"Who is Issac Newton";
#else
        char *prompt = getInput();
#endif
        if(prompt) {
            if(prompt[0]==0x3)
                ai.Clear();
            else {
                // Since this is a small model. It does not handle long context well.
                // Clear previous context before answering new query
                ai.Clear(); 
                ai.ClearStat();
                ai.UserPrompt(prompt);
                graph.Prepare();
#ifdef __WIN32__
                graph.RunUntilCompletion();
#else
                for(;;) {
                    graph.Run(20);
                    if(!graph.IsRunning())
                        break;
                }
#endif
//                while(ai.UserPrompt(0,0,20)==ZtaStatusPending);
                printf(" (tok=%d tok/sec=%.2f)",ai.GetStatNumTokens(),ai.GetStatTokPerSec());
            }
        }
    }

    return 0;
}
