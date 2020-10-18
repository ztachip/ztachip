//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
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

#ifndef _OBJECT_H_
#define _OBJECT_H_
#include <stdint.h>
#include <string.h>

typedef uintptr_t CLASSID;

extern void *cast_error(const char *errString);

#define CAST(myclass,myobj)   ((myobj)->isKindOf(myclass::getCLID())?(myclass *)myobj:(myclass *)cast_error("Invalid cast"))

#define DECLARE_ROOT_OBJECT(myclass)  \
                            private: static int M_clid; \
                            public: \
                            virtual bool isKindOf(CLASSID _clid) \
                            { \
                            if(myclass::getCLID()==_clid) \
                              return true; \
                            else \
                              return false; \
                            } \
                            static CLASSID getCLID() \
                            {  \
                              return (CLASSID)&M_clid; \
                            }

#define DECLARE_OBJECT(myclass,mybase)  \
                            private: static int M_clid; \
                            public: \
                            virtual bool isKindOf(CLASSID _clid) \
                            { \
                            if(myclass::getCLID()==_clid) \
                              return true; \
                            else \
                              return mybase::isKindOf(_clid); \
                            } \
                            static CLASSID getCLID() \
                            {  \
                              return (CLASSID)&M_clid; \
                            }

#define INSTANTIATE_OBJECT(myclass) int myclass::M_clid


#endif
