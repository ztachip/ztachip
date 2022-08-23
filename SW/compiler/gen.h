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

#ifndef _GEN_H_
#define _GEN_H_

#include "util.h"
#include "ast.h"
#include "term.h"
#include "instruction.h"

class cGEN 
{
public:
   static bool expressionIsMU(cAstNode *node);
   static int decode_array(cInstructions *instructions,cAstNode *_root,cAstNode *_func,cIdentifier *_id,cAstNode *node,
                           cIdentifierInteger **_i,int *_c,bool *_subVector);
   static cIdentifier *findIdentifier(cAstNode *node,CLASSID clid);
   static cTerm *genTerm(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool _isExReg,bool ref,
                         bool _isMU,cTerm *_y=0);
   static cTerm *genTermConditionalExpression(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermAssignmentExpression(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermPostIncrementDecrement(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermFunction(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermFunctionCall(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermPreIncrementDecrement(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermCalculation(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool _isExReg,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermIdentifier(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermDirectIndexing(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cTerm *genTermPointerIndexing(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                                          bool _isMU,cTerm *_y);
   static cInstruction *genSelectionStatement(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,
                                          bool hasExitCode,cInstruction *exitInstruction,cInstruction *blockExitInstruction,
                                          cInstruction *blockContInstruction);
   static cInstruction *genSwitchStatement(cInstructions *instructions,cAstNode *_root,cAstNode *func,
                                          cAstNode *_node,
                                          bool hasExitCode,
                                          cInstruction *exitInstruction,
                                          cInstruction *blockExitInstruction,
                                          cInstruction *blockContInstruction);
   static cInstruction *genStatement(cInstructions *instructions,cAstNode *_root,cAstNode *func,
                                          cAstNode *_node,
                                          cAstNode *_node2,
                                          bool reverseLogic,
                                          bool hasExitCode,
                                          cInstruction *exitInstruction,
                                          cInstruction *brInstruction,
                                          bool brAfter,
                                          cInstruction *blockExitInstruction,
                                          cInstruction *blockContInstruction,
                                          bool logicStatement=false);
   static bool process_func_entry(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,cInstruction **_begin,cInstruction **_end,bool *gotEntryCode,bool *gotExitCode);
   static cInstruction *process_func_exit(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,
                                          cInstruction *exitInstruction,bool hasExitCode);
   static void process_init(cInstructions *instructions,cAstNode *node);
   static bool identifierIsMod(cAstNode *node,cIdentifier *id);
   static bool loopUnroll(cAstNode *statement1,cAstNode *statement2,cAstNode *statement3,cAstNode *statement4,int *from,int *to,int *step,cIdentifierInteger **_id);
   static void substituteGenIdentifier(cAstCompositeNode *parent,cAstNode *statement,cIdentifierInteger *for_id,int for_index);
   static cInstruction *process_code_block(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,
                                          bool hasExitCode,cInstruction *exitInstruction,cInstruction *blockExitInstruction,cInstruction *blockContInstruction);
   static int gen(cAstNode *_root);
};

extern cInstructions PROGRAM;

#endif
