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

#include <assert.h>
#include <string.h>
#include <malloc.h>
#include <vector>
#include "../base/zta.h"
#include "util.h"

//---------------------------------------------------------------------
// Link list utilities
//---------------------------------------------------------------------

cList::cList(void *owner):
   m_owner(owner),
   m_first(0),
   m_last(0)
{
}

cList::~cList()
{
}

void cList::create(void *owner)
{
   m_owner=owner;
   m_first=0;
   m_last=0;
}

bool cList::isEmpty()
{
   return !m_first && !m_last;
}

void cList::insertList(cListItem *items,cListItem *beforeItem)
{
   cListItem *item,*nextItem;
   item=items;
   while(item)
   {
      nextItem=item->m_next;
      cList::remove(item);
      insert(item,beforeItem);
      beforeItem=item;
      item=nextItem;
   }
}

void cList::append(cListItem *item)
{
   insert(item,m_last);
}

void cList::insert(cListItem *item,cListItem *beforeItem)
{
   cList::remove(item);
   item->m_parent=this;
   if(beforeItem)
   {
      assert(beforeItem->m_parent==this);
      item->m_next=beforeItem->m_next;
      beforeItem->m_next=item;
      if(beforeItem==m_last)
         m_last=item;
      item->m_prev=beforeItem;
      if(item->m_next)
         item->m_next->m_prev=item;
   }
   else
   {
      item->m_next=m_first;
      item->m_prev=0;
      if(m_first)
         m_first->m_prev=item;
      m_first=item;
      if(!m_last)
         m_last=item;
   }
}

void cList::insert(cList *items,cListItem *beforeItem)
{
   cListItem *item;
   while((item=items->getLast()))
   {
      cList::remove(item);
      insert(item,beforeItem);
   }
}

void cList::append(cList *items)
{
   cListItem *item;
   while((item=items->getFirst()))
   {
      cList::remove(item);
      append(item);
   }
}

void cList::remove(cListItem *item)
{
   cList *list=item->m_parent;
   if(!list)
      return;
   if(item->m_prev)
      item->m_prev->m_next=item->m_next;
   if(item->m_next)
      item->m_next->m_prev=item->m_prev;
   if(list->m_first==item)
      list->m_first=item->m_next;
   if(list->m_last==item)
      list->m_last=item->m_prev;
   item->m_parent=0;
   item->m_next=0;
   item->m_prev=0;
}

cListItem::cListItem() :
   m_parent(0),
   m_next(0),
   m_prev(0)

{
}

cListItem::~cListItem()
{
}


// Check if character is white space
bool isWS(char ch)
{
   return ch==' ' || ch=='\t' || ch=='\r' || ch=='\n';
}

// Check if string is numeric
bool isNumeric(char *str)
{
   char *p;
   if(str[0]==0)
      return false;
   p=str;
   while(*p)
   {
      if(!(*p >= '0' && *p <= '9'))
         return false;
      p++;
   }
   return true;
}

// Trim leading and trailing white spaces
void trim(char *token)
{
   int i,len;
   char *p2;
   // Trim at the front
   p2=token;
   while(*p2)
   {
      if(!isWS(*p2))
         break;
      p2++;
   }
   memcpy(token,p2,strlen(token)+1);

   // Trim at the back

   len=strlen(token);
   for(i=len-1;i >=0;i--)
   {
      if(isWS(token[i]))
         token[i]=0;
      else
         break;
   }
}

void str_replace(char *str,char from_ch,char to_ch)
{
   while(*str)
   {
      if(*str==from_ch)
         *str=to_ch;
      str++;
   }
}

char *str_scan(char *str,char *token,char *matchSeq)
{
   int matchLen=strlen(matchSeq);
   char *p,*p2;
   int i;
   p=str;
   p2=token;
   while(*p && isWS(*p)) // Skip leading whitespace
      p++;
   while(*p)
   {
      for(i=0;i < matchLen;i++)
      {
         if(*p==matchSeq[i])
            break;
      }
      if(i >= matchLen)
         break;
      *p2++=*p;
      p++;
   }
   *p2=0;
   while(*p && isWS(*p))
      p++;
   return p;
}

// Check is name has the format xxx::yyy
bool IsValidScopedName(char *name)
{
   char temp[MAX_STRING_LEN];
   char *p,*name1,*name2;
   strcpy(temp,name);
   name=temp;
   p=strstr(name,"::");
   if(!p)
      return false;
   name1=name;
   name2=p+2;
   p[0]=0;
   if(strlen(name1)==0)
      return false;
   if(strstr(name1,":"))
      return false;
   if(strlen(name2)==0)
      return false;
   if(strstr(name2,":"))
      return false;
   return true;
}

// Return number of parameters defined in a function parameter list
int ParseName(char *fullname,std::string *name,std::string *context)
{
   char buf[MAX_STRING_LEN];
   char *p;

   if(!IsValidScopedName(fullname))
   {
      if(strstr(fullname,":"))
         return -1;
      context->clear();
      *name=fullname;
      return 0;
   }
   strcpy(buf,fullname);
   if((p=strstr(buf,"::")))
   {
      *name=p+2;
      *p=0;
      *context=buf;
   }
   else
   {
      *name=buf;
      context->clear();
   }
   return 0;
}
