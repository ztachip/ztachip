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

#ifndef _UTIL_H_
#define _UTIL_H_

#include <string>
#include "../base/util.h"

#define bool int
#define true 1
#define false 0
#define RETCODE int
#define OK 0
#define FAIL -1

#define MAX_STRING_LEN  256      // Maximum string size

class cList;
class cListItem;

class cList
{
friend cListItem;
public:
   cList(void *owner=0);
   ~cList();
   void create(void *owner);
   void *getOwner() {return m_owner;}
   bool isEmpty();
   void insertList(cListItem *items,cListItem *beforeItem);
   void append(cListItem *item);
   void append(cList *items);
   void insert(cListItem *item,cListItem *beforeItem);
   void insert(cList *items,cListItem *beforeItem);
   static void remove(cListItem *item);
   cListItem *getFirst() {return m_first;}
   cListItem *getLast() {return m_last;}

private:
   void *m_owner;
   cListItem *m_first;
   cListItem *m_last;
};

class cListItem
{
friend cList;
public:
   cListItem();
   ~cListItem();
   cListItem *getNext() {return m_next;}
   cListItem *getPrev() {return m_prev;}
   cList *getParent() {return m_parent;}
   void *getOwner() {return m_parent?m_parent->m_owner:0;}
private:
   cList *m_parent;
   cListItem *m_next;
   cListItem *m_prev;
};

// String utilities
extern bool isWS(char ch);
extern bool isNumeric(char *str);
extern void trim(char *token);
extern void str_replace(char *str,char from_ch,char to_ch);
extern char *str_scan(char *str,char *token,char *matchSeq);
extern bool IsValidScopedName(char *name);
extern int ParseName(char *fullname,std::string *name,std::string *context);
#endif
