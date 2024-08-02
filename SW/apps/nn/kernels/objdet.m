#include <stdbool.h>
#include "../../../base/util.h"
#include "../../../base/ztalib.h"
#include "objdet.h"
#include "objdet.p.img"

// This structure holds all information to perform this kernel function

typedef struct {
    uint32_t score; // pointer to score buffer
    uint32_t score_result; // pointer to score result buffer
    uint32_t class_result; // pointer to class result buffer
    int numBoxes; // number of boxes
    int numClasses; // Number of classes 
} RequestObjDet;

// Finding the max score of each box by scanning through the scores of every
// classes of each box
// A box is assigned to a vector element of each thread
// Number of boxes that can be processed at same time=NUM_PCORE*NUM_THREAD*VECTOR_WIDTH=1024
// 
static void objdet(void *_p,int pid) {
    RequestObjDet *req=(RequestObjDet *)_p;
    int batchBox,batchClass;
    int i,j;
    uint32_t score;
    uint32_t score_result;
    uint32_t class_result;
    uint32_t numBoxes;
    int numBoxes2;

    batchBox = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;
    batchClass = CLASS_PER_THREAD;
    if(pid==0) {
        numBoxes = ((req->numBoxes/2)/8)*8; // To make it aligned to 64bytes memory
        score = req->score;
        score_result = req->score_result;
        class_result = req->class_result;
    }
    else {
        numBoxes2=((req->numBoxes/2)/8)*8; // Number of boxes assigned to pid=0
        numBoxes = req->numBoxes - numBoxes2;
        score = req->score+numBoxes2*req->numClasses;
        score_result = req->score_result+numBoxes2;
        class_result = req->class_result+numBoxes2;
    }

    for(i=0;i < numBoxes;i += batchBox) {
        >EXE_LOCKSTEP(objdet::init,NUM_PCORE);
        for(j=0;j < req->numClasses;j += batchClass) {
            // Transfer scores to PCORE memory
            // If there are too many classes to fit in PCORE memory, then
            // do it several times.
            // Note the order of transfer, every boxes are assigned to a vector element of
            // every thread of evey PCORE. So that we can process many boxes simultaneouly
            > CONCURRENT DTYPE(UINT8) 
            > FOR(L=0:NUM_PCORE-1) 
            >    FOR(K=0:NUM_THREAD_PER_CORE-1) 
            >       FOR(J=0:VECTOR_WIDTH-1) 
            >          FOR(I=0:CLASS_PER_THREAD-1) 
            >             PCORE(NUM_PCORE)[L].THREAD[K].objdet::score[I][J] 
            > <= 
            > DTYPE(UINT8) 
            > MEM(score,numBoxes,req->numClasses)
            >    [i:i+batchBox-1]
            >       [j:j+batchClass-1];
            
            // Find the max score 

            >EXE_LOCKSTEP(objdet::find_max,NUM_PCORE);
            ztaTaskYield();
        }
        // Copy result to external memory
        // Result is a 2D tensor of dimension [num_boxes][2]
        // Each box would have 2 word result,first word is the max score found
        // and second word is the class that has the max score

        // Send score_result
        > DTYPE(UINT8) MEM(score_result,numBoxes)[i:i+batchBox-1] 
        > <= 
        > DTYPE(UINT8)
        > FOR(L=0:NUM_PCORE-1) 
        >    FOR(K=0:NUM_THREAD_PER_CORE-1) 
        >       FOR(J=0:VECTOR_WIDTH-1) 
        >          PCORE(NUM_PCORE)[L].THREAD[K].objdet::result[0][J];

        // Send class_result
        > DTYPE(UINT8) MEM(class_result,numBoxes)[i:i+batchBox-1] 
        > <= 
        > DTYPE(UINT8)
        > FOR(L=0:NUM_PCORE-1) 
        >    FOR(K=0:NUM_THREAD_PER_CORE-1) 
        >       FOR(J=0:VECTOR_WIDTH-1) 
        >          PCORE(NUM_PCORE)[L].THREAD[K].objdet::result[1][J];
    }
}

// To find the max score for every box after scanning through all the scores of
// every class.
//    _score : scores for each box per class
//             _score is 2D tensor of this definition: _score[_numBoxes][_numClasses]
//    _result: buffer to send back result of class+score 
//             _result is 2D tensor of this definition: _result[numBoxes][2]
//    _numBoxes: number of boxes 
//    _numClasses: number of object classes whose score are assigned for each box

void kernel_objdet_exe(
   unsigned int _req_id,
   unsigned int _score,
   unsigned int _score_result,
   unsigned int _class_result,
   int _numBoxes,
   int _numClasses
)
{
    RequestObjDet req;
    uint32_t resp;

    ztaInitPcore(zta_pcore_img);

    req.score=_score;
    req.score_result=_score_result;
    req.class_result=_class_result;
    req.numBoxes=_numBoxes;
    req.numClasses=_numClasses;

    ztaDualHartExecute(objdet,&req);

    ztaJobDone(_req_id);

    // Wait for response....
    for(;;) {
        if(ztaReadResponse(&resp))
            break;
    }  
}
