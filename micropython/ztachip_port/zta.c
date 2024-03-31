// Include MicroPython API.
#include "py/runtime.h"
#include "SW/src/mpy.h"

#include "py/mphal.h"

// Constant definition

#define CONST_INTERLEAVED 0
#define CONST_PLANAR 1
#define CONST_MONO1 2
#define CONST_MONO3 1
#define CONST_COLOR 0

//-----------------------------------------------------------
// Button function
//-----------------------------------------------------------

STATIC mp_obj_t zta_ButtonState() {
    return mp_obj_new_int(MPY_PushButtonState());
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_0(zta_ButtonState_obj, zta_ButtonState);

//-----------------------------------------------------------
// Get time function
//-----------------------------------------------------------

STATIC mp_obj_t zta_GetTimeMsec() {
    return mp_obj_new_int_from_uint(MPY_GetTimeMsec());
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_0(zta_GetTimeMsec_obj, zta_GetTimeMsec);

//-----------------------------------------------------------
// Get elapsed time function
//-----------------------------------------------------------

STATIC mp_obj_t zta_GetElapsedTimeMsec() {
    return mp_obj_new_int_from_uint(MPY_GetElapsedTimeMsec());
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_0(zta_GetElapsedTimeMsec_obj, zta_GetElapsedTimeMsec);



//-----------------------------------------------------------
// LED function
//-----------------------------------------------------------

STATIC mp_obj_t zta_SetLed(mp_obj_t _ledState) {
    uint32_t ledState;
    ledState=mp_obj_get_int(_ledState);
    MPY_LedSet(ledState);
    return mp_const_none;
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_SetLed_obj, zta_SetLed);


//-----------------------------------------------------------
// Camera capture function
//-----------------------------------------------------------

STATIC mp_obj_t zta_CameraCapture() {
    bool retval;
    retval=MPY_Camera_Capture();
    if(retval)
        MPY_TENSOR_GetCameraCapture(0);
    return mp_obj_new_bool(retval);
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_0(zta_CameraCapture_obj, zta_CameraCapture);

//-----------------------------------------------------------
// Display update function
//-----------------------------------------------------------

STATIC mp_obj_t zta_DisplayFlushCanvas() {
    MPY_Display_FlushScreenCanvas();
    MPY_TENSOR_GetScreenCanvas(0);
    return mp_const_none;
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_0(zta_DisplayFlushCanvas_obj, zta_DisplayFlushCanvas);

//-----------------------------------------------------------
// Canvas drawing function
//-----------------------------------------------------------

STATIC mp_obj_t zta_CanvasDrawText(mp_obj_t str,mp_obj_t r,mp_obj_t c) {
    MPY_Canvas_DrawText(mp_obj_str_get_str(str),mp_obj_get_int(r),mp_obj_get_int(c));
    return mp_const_none;
}

// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_3(zta_CanvasDrawText_obj, zta_CanvasDrawText);

STATIC mp_obj_t zta_CanvasDrawPoint(mp_obj_t r,mp_obj_t c) {
    MPY_Canvas_DrawPoint(mp_obj_get_int(r),mp_obj_get_int(c));
    return mp_const_none;
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_2(zta_CanvasDrawPoint_obj, zta_CanvasDrawPoint);

// Draw rectangle. Show the corner of rectangle only

STATIC mp_obj_t zta_CanvasDrawRectangle(mp_obj_t _topleft,mp_obj_t _botright) {
    mp_obj_tuple_t *topleft = MP_OBJ_TO_PTR(_topleft);
    mp_obj_tuple_t *botright = MP_OBJ_TO_PTR(_botright);
    MPY_Canvas_DrawRectangle(mp_obj_get_int(topleft->items[0]),
                            mp_obj_get_int(topleft->items[1]),
                            mp_obj_get_int(botright->items[0]),
                            mp_obj_get_int(botright->items[1]));
    return mp_const_none;
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_2(zta_CanvasDrawRectangle_obj, zta_CanvasDrawRectangle);

//------------------------------------------------------------
// Delete all previously allocated objects such as tensor,graphNode and graph
//------------------------------------------------------------

STATIC mp_obj_t zta_DeleteAll() {
    MPY_DeleteAll();
    return mp_const_none;
}
// Define a Python reference to the function above.
STATIC MP_DEFINE_CONST_FUN_OBJ_0(zta_DeleteAll_obj, zta_DeleteAll);

//----------------------------------------------------------
// Delete all objects
//-----------------------------------------------------------

//------------------------------------------------------------
// Tensor base definition
//------------------------------------------------------------
typedef struct _zta_Tensor_obj_t {
    // All objects start with the base.
    mp_obj_base_t base;
    eMPY_TensorType tensorType;
    MPY_HANDLE hwd;
} zta_Tensor_obj_t;

//---------------------------------------------------------------
// TensorCamera class represents image capture from camera
//---------------------------------------------------------------

STATIC mp_obj_t zta_TensorCamera_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_Tensor_obj_t *self = mp_obj_malloc(zta_Tensor_obj_t, type);
    self->tensorType=eMPY_TensorTypeCamera;
    self->hwd=MPY_TENSOR_Create(eMPY_TensorTypeCamera);
    MPY_TENSOR_GetCameraCapture(self->hwd);
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_TensorCamera_Delete(mp_obj_t self_in) {
    zta_Tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_TENSOR_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_TensorCamera_Delete_obj, zta_TensorCamera_Delete);

STATIC const mp_rom_map_elem_t zta_TensorCamera_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_TensorCamera_Delete_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_TensorCamera_locals_dict, zta_TensorCamera_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_TensorCamera,
    MP_QSTR_TensorCamera,
    MP_TYPE_FLAG_NONE,
    make_new, zta_TensorCamera_make_new,
    locals_dict, &zta_TensorCamera_locals_dict
    );

//---------------------------------------------------------------
// TensorDisplay class represents data of the display
// Drawing is done first to this object's data before flushed to
// screen display
//---------------------------------------------------------------

STATIC mp_obj_t zta_TensorDisplay_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_Tensor_obj_t *self = mp_obj_malloc(zta_Tensor_obj_t, type);
    self->tensorType=eMPY_TensorTypeDisplay;
    self->hwd=MPY_TENSOR_Create(eMPY_TensorTypeDisplay);
    MPY_TENSOR_GetScreenCanvas(self->hwd);
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_TensorDisplay_Delete(mp_obj_t self_in) {
    zta_Tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_TENSOR_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_TensorDisplay_Delete_obj, zta_TensorDisplay_Delete);

STATIC const mp_rom_map_elem_t zta_TensorDisplay_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_TensorDisplay_Delete_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_TensorDisplay_locals_dict, zta_TensorDisplay_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_TensorDisplay,
    MP_QSTR_TensorDisplay,
    MP_TYPE_FLAG_NONE,
    make_new, zta_TensorDisplay_make_new,
    locals_dict, &zta_TensorDisplay_locals_dict
    );

//---------------------------------------------------------------
// Tensor class. General tensor data objects normally used to 
// carry intermediate data within an execution graph
//---------------------------------------------------------------

STATIC mp_obj_t zta_Tensor_print(mp_obj_t self_in) {
    zta_Tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_Tensor_print_obj, zta_Tensor_print);

STATIC mp_obj_t zta_Tensor_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_Tensor_obj_t *self = mp_obj_malloc(zta_Tensor_obj_t, type);
    self->tensorType=eMPY_TensorTypeData;
    self->hwd=MPY_TENSOR_Create(eMPY_TensorTypeData);
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_Tensor_Delete(mp_obj_t self_in) {
    zta_Tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_TENSOR_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_Tensor_Delete_obj, zta_Tensor_Delete);

STATIC const mp_rom_map_elem_t zta_Tensor_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_Tensor_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_print), MP_ROM_PTR(&zta_Tensor_print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_Tensor_locals_dict, zta_Tensor_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_Tensor,
    MP_QSTR_Tensor,
    MP_TYPE_FLAG_NONE,
    make_new, zta_Tensor_make_new,
    locals_dict, &zta_Tensor_locals_dict
    );

//----------------------------------------------------------
// Create GraphNode

typedef struct _zta_GraphNode_obj_t {
    // All objects start with the base.
    mp_obj_base_t base;
    MPY_HANDLE hwd;
    int numTensor;
    MPY_HANDLE tensor[8];
} zta_GraphNode_obj_t;

//---------------------------------------------------------
// This graph node performs data copy and transformation such
// as color plane reformatting (between interleaved and planar mode)
//--------------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeCopyAndTransform_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeCopyAndTransform_Print_obj, zta_GraphNodeCopyAndTransform_Print);

STATIC mp_obj_t zta_GraphNodeCopyAndTransform_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    zta_Tensor_obj_t *tensorOutput = MP_OBJ_TO_PTR(args[1]);
    eMPY_TensorColorSpace dstColorSpace = mp_obj_get_int(args[2]);
    eMPY_TensorFormat dstFormat = mp_obj_get_int(args[3]);
    int dst_x,dst_y,dst_w,dst_h;

    if(tensorOutput->tensorType==eMPY_TensorTypeDisplay) {
        if(n_args == 6) {
           dst_y = mp_obj_get_int(args[4]);
           dst_x = mp_obj_get_int(args[5]);
        }
        else {
           dst_x = 0;
           dst_y = 0;
        }
        dst_w = MPY_DisplayWidth();
        dst_h = MPY_DisplayHeight();
    }
    else {
        dst_x=dst_y=dst_w=dst_h=0;
    }
    self->hwd=MPY_GraphNodeCopyAndTransform_Create(
                  tensorInput->hwd,
                  tensorOutput->hwd,
                  dstColorSpace,
                  dstFormat,
                  dst_x,dst_y,dst_w,dst_h);
    self->numTensor=0;
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_GraphNodeCopyAndTransform_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeCopyAndTransform_Delete_obj, zta_GraphNodeCopyAndTransform_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeCopyAndTransform_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeCopyAndTransform_Print_obj) },
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeCopyAndTransform_Delete_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeCopyAndTransform_locals_dict, zta_GraphNodeCopyAndTransform_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeCopyAndTransform,
    MP_QSTR_GraphNodeCopyAndTransform,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeCopyAndTransform_make_new,
    locals_dict, &zta_GraphNodeCopyAndTransform_locals_dict
    );

//----------------------------------------------------------
// Create GraphNodeCanny
// This node performs edge detection
//----------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeCanny_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeCanny_Print_obj, zta_GraphNodeCanny_Print);

STATIC mp_obj_t zta_GraphNodeCanny_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    zta_Tensor_obj_t *tensorOutput = MP_OBJ_TO_PTR(args[1]);
    self->hwd=MPY_GraphNodeCanny_Create(
                  tensorInput->hwd,
                  tensorOutput->hwd);
    self->numTensor=0;
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_GraphNodeCanny_SetThreshold(mp_obj_t self_in,mp_obj_t _loThreshold,mp_obj_t _hiThreshold) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    int loThreshold=mp_obj_get_int(_loThreshold);
    int hiThreshold=mp_obj_get_int(_hiThreshold);
    MPY_GraphNodeCanny_SetThreshold(self->hwd,loThreshold,hiThreshold);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_3(zta_GraphNodeCanny_SetThreshold_obj, zta_GraphNodeCanny_SetThreshold);

// DEL operator

STATIC mp_obj_t zta_GraphNodeCanny_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeCanny_Delete_obj, zta_GraphNodeCanny_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeCanny_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeCanny_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_SetThreshold), MP_ROM_PTR(&zta_GraphNodeCanny_SetThreshold_obj) },
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeCanny_Print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeCanny_locals_dict, zta_GraphNodeCanny_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeCanny,
    MP_QSTR_GraphNodeCanny,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeCanny_make_new,
    locals_dict, &zta_GraphNodeCanny_locals_dict
    );

//----------------------------------------------------------
// Create GraphNodeGaussian
// This node performs image blurring
//-----------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeGaussian_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeGaussian_Print_obj, zta_GraphNodeGaussian_Print);

STATIC mp_obj_t zta_GraphNodeGaussian_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    zta_Tensor_obj_t *tensorOutput = MP_OBJ_TO_PTR(args[1]);
    self->hwd=MPY_GraphNodeGaussian_Create(
                  tensorInput->hwd,
                  tensorOutput->hwd);
    self->numTensor=0;
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_GraphNodeGaussian_SetSigma(mp_obj_t self_in,mp_obj_t _sigma) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    float sigma=mp_obj_get_float(_sigma);
    MPY_GraphNodeGaussian_SetSigma(self->hwd,sigma);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_2(zta_GraphNodeGaussian_SetSigma_obj, zta_GraphNodeGaussian_SetSigma);

// DEL operator

STATIC mp_obj_t zta_GraphNodeGaussian_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeGaussian_Delete_obj, zta_GraphNodeGaussian_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeGaussian_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeGaussian_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_SetSigma), MP_ROM_PTR(&zta_GraphNodeGaussian_SetSigma_obj) },
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeGaussian_Print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeGaussian_locals_dict, zta_GraphNodeGaussian_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeGaussian,
    MP_QSTR_GraphNodeGaussian,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeGaussian_make_new,
    locals_dict, &zta_GraphNodeGaussian_locals_dict
    );

//----------------------------------------------------------
// Create GraphNodeHarris
// This graph node performs harris-corner algorithm to find 
// point of interests in an image
//----------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeHarris_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeHarris_Print_obj, zta_GraphNodeHarris_Print);

STATIC mp_obj_t zta_GraphNodeHarris_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    MPY_HANDLE tensorOutput = MPY_TENSOR_Create(eMPY_TensorTypeData);
    self->hwd=MPY_GraphNodeHarris_Create(
                  tensorInput->hwd,
                  tensorOutput);
    self->numTensor=1;
    self->tensor[0]=tensorOutput;
    return MP_OBJ_FROM_PTR(self);
}

#define MAX_POINTS 32

// Retrieve the list of point-of-interests

STATIC mp_obj_t zta_GraphNodeHarris_GetPOI(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    int w,h;
    int i,j;
    uint16_t *p;
    int count;
    mp_obj_tuple_t *tuple[MAX_POINTS];

    w=MPY_TENSOR_GetDim(self->tensor[0],1);
    h=MPY_TENSOR_GetDim(self->tensor[0],0);
    p=(uint16_t *)MPY_TENSOR_GetBuf(self->tensor[0]);
    count=0;

    for(i=0;i < h;i++) {
        for(j=0;j < w;j++,p++) {
            if(*p != 0) {
                tuple[count] = MP_OBJ_TO_PTR(mp_obj_new_tuple(2, NULL));
                tuple[count]->items[0] = MP_OBJ_NEW_SMALL_INT(j);
                tuple[count]->items[1] = MP_OBJ_NEW_SMALL_INT(i);
                count++;
                if(count >= MAX_POINTS)
                    break;
            }
        }
        if(j < w)
            break;
    }
    return mp_obj_new_list(count, (mp_obj_t *)tuple);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeHarris_GetPOI_obj, zta_GraphNodeHarris_GetPOI);

STATIC mp_obj_t zta_GraphNodeHarris_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeHarris_Delete_obj, zta_GraphNodeHarris_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeHarris_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_GetPOI), MP_ROM_PTR(&zta_GraphNodeHarris_GetPOI_obj) },
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeHarris_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeHarris_Print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeHarris_locals_dict, zta_GraphNodeHarris_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeHarris,
    MP_QSTR_GraphNodeHarris,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeHarris_make_new,
    locals_dict, &zta_GraphNodeHarris_locals_dict
    );

//----------------------------------------------------------
// Create GraphNodeOpticalFlow
// This graph node performs motion detection and the motion are
// encoded as colored pixel to represent motion speed and direction
//-------------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeOpticalFlow_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeOpticalFlow_Print_obj, zta_GraphNodeOpticalFlow_Print);

STATIC mp_obj_t zta_GraphNodeOpticalFlow_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    zta_Tensor_obj_t *tensorOutput = MP_OBJ_TO_PTR(args[1]);
    self->hwd=MPY_GraphNodeOpticalFlow_Create(
                  tensorInput->hwd,
                  tensorOutput->hwd);
    self->numTensor=0;
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_GraphNodeOpticalFlow_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeOpticalFlow_Delete_obj, zta_GraphNodeOpticalFlow_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeOpticalFlow_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeOpticalFlow_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeOpticalFlow_Print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeOpticalFlow_locals_dict, zta_GraphNodeOpticalFlow_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeOpticalFlow,
    MP_QSTR_GraphNodeOpticalFlow,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeOpticalFlow_make_new,
    locals_dict, &zta_GraphNodeOpticalFlow_locals_dict
    );

//----------------------------------------------------------
// Create GraphNodeResize
// This graph node performs image resize
// Only image reduction is supported at the moment 
//----------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeResize_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeResize_Print_obj, zta_GraphNodeResize_Print);

STATIC mp_obj_t zta_GraphNodeResize_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    zta_Tensor_obj_t *tensorOutput = MP_OBJ_TO_PTR(args[1]);
    int w=mp_obj_get_int(args[2]);
    int h=mp_obj_get_int(args[3]);
    self->hwd=MPY_GraphNodeResize_Create(
                  tensorInput->hwd,
                  tensorOutput->hwd,
                  w,h);
    self->numTensor=0;
    return MP_OBJ_FROM_PTR(self);
}

STATIC mp_obj_t zta_GraphNodeResize_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeResize_Delete_obj, zta_GraphNodeResize_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeResize_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeResize_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeResize_Print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeResize_locals_dict, zta_GraphNodeResize_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeResize,
    MP_QSTR_GraphNodeResize,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeResize_make_new,
    locals_dict, &zta_GraphNodeResize_locals_dict
    );

//----------------------------------------------------------
// GraphNodeImageClassifier
// This graph node performs image classification using TensorFlowLite
// Mobinet. It uses the Google model as is without any retrainig
// or modifications required
//----------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeImageClassifier_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeImageClassifier_Print_obj, zta_GraphNodeImageClassifier_Print);

STATIC mp_obj_t zta_GraphNodeImageClassifier_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    MPY_HANDLE tensorOutput = MPY_TENSOR_Create(eMPY_TensorTypeData);
    self->hwd=MPY_GraphNodeNeuralNet_Create(
                                        "mobilenet_v2_1_0_224_quant.tflite",
                                        "labels_mobilenet_quant_v1_224.txt",
                                        tensorInput->hwd,
                                        1,tensorOutput,0,0,0);
    self->numTensor=1;
    self->tensor[0]=tensorOutput;
    return MP_OBJ_FROM_PTR(self);
}

// Getting the top5 results from the image classification

STATIC mp_obj_t zta_GraphNodeImageClassifier_GetTop5(mp_obj_t self_in)
{
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    unsigned int v;
    unsigned int t;
    unsigned int i0;
    unsigned int i1;
    unsigned int i2;
    unsigned int i3;
    unsigned int i4;
    uint8_t *prediction;
    int predictionSize;
    mp_obj_tuple_t *tuple[5];
    int index;
    const char *label;

    prediction=MPY_TENSOR_GetBuf(self->tensor[0]);
    predictionSize=MPY_TENSOR_GetBufLen(self->tensor[0]);
    i0=0x00000000;
    i1=0x00000000;
    i2=0x00000000;
    i3=0x00000000;
    i4=0x00000000;

    for(int i=0;i < predictionSize;i++) {
        v=(prediction[i] << 16)+i;
        if(v > i4) {
            i4=v; 
            if(i4 > i3) {
                t=i3;i3=i4;i4=t;
                if(i3 > i2) { 
                    t=i2;i2=i3;i3=t;
                    if(i2 > i1) {
                        t=i1;i1=i2;i2=t;
                        if(i1 > i0) {
                            t=i0;i0=i1;i1=t;
                        }
                    }
                }
            }
        }
    }

    index = (int)(i0&0xFFFF);
    label = MPY_GraphNodeNeuralNet_GetLabel(self->hwd,index);
    tuple[0] = MP_OBJ_TO_PTR(mp_obj_new_tuple(2, NULL));
    tuple[0]->items[0] = MP_OBJ_NEW_SMALL_INT(prediction[index]);
    tuple[0]->items[1] = mp_obj_new_str(label,strlen(label));

    index = (int)(i1&0xFFFF);
    label = MPY_GraphNodeNeuralNet_GetLabel(self->hwd,index);
    tuple[1] = MP_OBJ_TO_PTR(mp_obj_new_tuple(2, NULL));
    tuple[1]->items[0] = MP_OBJ_NEW_SMALL_INT(prediction[index]);
    tuple[1]->items[1] = mp_obj_new_str(label,strlen(label));

    index = (int)(i2&0xFFFF);
    label = MPY_GraphNodeNeuralNet_GetLabel(self->hwd,index);
    tuple[2] = MP_OBJ_TO_PTR(mp_obj_new_tuple(2, NULL));
    tuple[2]->items[0] = MP_OBJ_NEW_SMALL_INT(prediction[index]);
    tuple[2]->items[1] = mp_obj_new_str(label,strlen(label));

    index = (int)(i3&0xFFFF);
    label = MPY_GraphNodeNeuralNet_GetLabel(self->hwd,index);
    tuple[3] = MP_OBJ_TO_PTR(mp_obj_new_tuple(2, NULL));
    tuple[3]->items[0] = MP_OBJ_NEW_SMALL_INT(prediction[index]);
    tuple[3]->items[1] = mp_obj_new_str(label,strlen(label));

    index = (int)(i4&0xFFFF);
    label = MPY_GraphNodeNeuralNet_GetLabel(self->hwd,index);
    tuple[4] = MP_OBJ_TO_PTR(mp_obj_new_tuple(2, NULL));
    tuple[4]->items[0] = MP_OBJ_NEW_SMALL_INT(prediction[index]);
    tuple[4]->items[1] = mp_obj_new_str(label,strlen(label));

    return mp_obj_new_list(5, (mp_obj_t *)tuple);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeImageClassifier_GetTop5_obj, zta_GraphNodeImageClassifier_GetTop5);

STATIC mp_obj_t zta_GraphNodeImageClassifier_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeImageClassifier_Delete_obj, zta_GraphNodeImageClassifier_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeImageClassifier_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_GetTop5), MP_ROM_PTR(&zta_GraphNodeImageClassifier_GetTop5_obj) },
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeImageClassifier_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeImageClassifier_Print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeImageClassifier_locals_dict, zta_GraphNodeImageClassifier_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeImageClassifier,
    MP_QSTR_GraphNodeImageClassifier,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeImageClassifier_make_new,
    locals_dict, &zta_GraphNodeImageClassifier_locals_dict
    );

//----------------------------------------------------------
// GraphNodeObjectDetection
// This graph node performs object detection using TensorFlowLite
// SSD-Mobinet.
// It uses the Google SSD-Mobinet model as is without any retrainig
// or modifications required
//----------------------------------------------------------

STATIC mp_obj_t zta_GraphNodeObjectDetection_Print(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeObjectDetection_Print_obj, zta_GraphNodeObjectDetection_Print);

STATIC mp_obj_t zta_GraphNodeObjectDetection_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_GraphNode_obj_t *self = mp_obj_malloc(zta_GraphNode_obj_t, type);
    zta_Tensor_obj_t *tensorInput = MP_OBJ_TO_PTR(args[0]);
    MPY_HANDLE tensorOutput0 = MPY_TENSOR_Create(eMPY_TensorTypeData);
    MPY_HANDLE tensorOutput1 = MPY_TENSOR_Create(eMPY_TensorTypeData);
    MPY_HANDLE tensorOutput2 = MPY_TENSOR_Create(eMPY_TensorTypeData);
    MPY_HANDLE tensorOutput3 = MPY_TENSOR_Create(eMPY_TensorTypeData);
    self->hwd=MPY_GraphNodeNeuralNet_Create(
                                        "detect.tflite",
                                        "labelmap.txt",
                                        tensorInput->hwd,
                                        4,
                                        tensorOutput0,
                                        tensorOutput1,
                                        tensorOutput2,
                                        tensorOutput3);
    self->numTensor=4;
    self->tensor[0]=tensorOutput0;
    self->tensor[1]=tensorOutput1;
    self->tensor[2]=tensorOutput2;
    self->tensor[3]=tensorOutput3;
    return MP_OBJ_FROM_PTR(self);
}

#define MAX_SSD_RESULT 5

// Getting the list of detected objects

STATIC mp_obj_t zta_GraphNodeObjectDetection_GetObjects(mp_obj_t self_in)
{
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    mp_obj_tuple_t *tuple[MAX_SSD_RESULT];
    int ssd_result_cnt;
    int i;
    int w,h;
    const char *label;
    int probability;
    int x1,y1,x2,y2;
    float *box_p=(float *)MPY_TENSOR_GetBuf(self->tensor[0]);
    float *classes_p=(float *)MPY_TENSOR_GetBuf(self->tensor[1]);
    float *probability_p=(float *)MPY_TENSOR_GetBuf(self->tensor[2]);
    float *numDetect_p=(float *)MPY_TENSOR_GetBuf(self->tensor[3]);

    w=MPY_DisplayWidth();
    h=MPY_DisplayHeight();
    ssd_result_cnt=numDetect_p[0];
    if(ssd_result_cnt > MAX_SSD_RESULT)
        ssd_result_cnt=MAX_SSD_RESULT;
    if(ssd_result_cnt < 0)
        ssd_result_cnt=0;
    for(int i=0;i < ssd_result_cnt;i++) {
        label=MPY_GraphNodeNeuralNet_GetLabel(self->hwd,(int)classes_p[i]);
        probability=(int)(probability_p[i]*100);
        x1=box_p[4*i+1]*w;
        y1=box_p[4*i+0]*h;
        x2=box_p[4*i+3]*w;
        y2=box_p[4*i+2]*h;
        tuple[i] = MP_OBJ_TO_PTR(mp_obj_new_tuple(6, NULL));
        tuple[i]->items[0]=MP_OBJ_NEW_SMALL_INT(x1); // x1
        tuple[i]->items[1]=MP_OBJ_NEW_SMALL_INT(y1); // y1
        tuple[i]->items[2]=MP_OBJ_NEW_SMALL_INT(x2); // x2
        tuple[i]->items[3]=MP_OBJ_NEW_SMALL_INT(y2); // y2
        tuple[i]->items[4]=MP_OBJ_NEW_SMALL_INT(probability); // probability
        tuple[i]->items[5]=mp_obj_new_str(label,strlen(label)); // label
    }
    return mp_obj_new_list(ssd_result_cnt, (mp_obj_t *)tuple);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeObjectDetection_GetObjects_obj, zta_GraphNodeObjectDetection_GetObjects);

STATIC mp_obj_t zta_GraphNodeObjectDetection_Delete(mp_obj_t self_in) {
    zta_GraphNode_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_GraphNode_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_GraphNodeObjectDetection_Delete_obj, zta_GraphNodeObjectDetection_Delete);

STATIC const mp_rom_map_elem_t zta_GraphNodeObjectDetection_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_GetObjects), MP_ROM_PTR(&zta_GraphNodeObjectDetection_GetObjects_obj) },
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_GraphNodeObjectDetection_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_Print), MP_ROM_PTR(&zta_GraphNodeObjectDetection_Print_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_GraphNodeObjectDetection_locals_dict, zta_GraphNodeObjectDetection_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_GraphNodeObjectDetection,
    MP_QSTR_GraphNodeObjectDetection,
    MP_TYPE_FLAG_NONE,
    make_new, zta_GraphNodeObjectDetection_make_new,
    locals_dict, &zta_GraphNodeObjectDetection_locals_dict
    );

//----------------------------------------------------------
// Create Graph

typedef struct _zta_Graph_obj_t {
    // All objects start with the base.
    mp_obj_base_t base;
    MPY_HANDLE hwd;
} zta_Graph_obj_t;

// Is graph currently busy running

STATIC mp_obj_t zta_Graph_IsBusy(mp_obj_t self_in) {
    zta_Graph_obj_t *self = MP_OBJ_TO_PTR(self_in);
    if(!MPY_Graph_IsBusy(self->hwd))
        return mp_obj_new_bool(false);
    else
        return mp_obj_new_bool(true);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_Graph_IsBusy_obj, zta_Graph_IsBusy);


// Run the graph until completion

STATIC mp_obj_t zta_Graph_Run(mp_obj_t self_in) {
    zta_Graph_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_Graph_Run(self->hwd);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_Graph_Run_obj, zta_Graph_Run);

// Run the graph but only upto a time period. If graph execution not completed
// yet before time expiration, this function will return and must be called
// again to resume the execution where it left off.

STATIC mp_obj_t zta_Graph_RunWithTimeout(mp_obj_t self_in,mp_obj_t _timeout) {
    zta_Graph_obj_t *self = MP_OBJ_TO_PTR(self_in);
    int timeout= mp_obj_get_int(_timeout);
    MPY_Graph_RunWithTimeout(self->hwd,timeout);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_2(zta_Graph_RunWithTimeout_obj, zta_Graph_RunWithTimeout);

// DEL operator

STATIC mp_obj_t zta_Graph_Delete(mp_obj_t self_in) {
    zta_Graph_obj_t *self = MP_OBJ_TO_PTR(self_in);
    MPY_Graph_Delete(self->hwd);
    self->hwd=0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(zta_Graph_Delete_obj, zta_Graph_Delete);

// Constructor

#define MAX_NUM_NODE_PER_GRAPH 32

STATIC mp_obj_t zta_Graph_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    zta_Graph_obj_t *self = mp_obj_malloc(zta_Graph_obj_t,type);
    MPY_HANDLE nodeLst[MAX_NUM_NODE_PER_GRAPH];
    zta_GraphNode_obj_t *node;
    int i;

    if(n_args > MAX_NUM_NODE_PER_GRAPH)
        n_args = MAX_NUM_NODE_PER_GRAPH;
    for(i=0;i < n_args;i++) {
        node = MP_OBJ_TO_PTR(args[i]);
        nodeLst[i]=node->hwd;
    }
    self->hwd=MPY_Graph_Create(n_args,nodeLst);
    return MP_OBJ_FROM_PTR(self);
}

STATIC const mp_rom_map_elem_t zta_Graph_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_Delete), MP_ROM_PTR(&zta_Graph_Delete_obj) },
    { MP_ROM_QSTR(MP_QSTR_IsBusy), MP_ROM_PTR(&zta_Graph_IsBusy_obj) },
    { MP_ROM_QSTR(MP_QSTR_Run), MP_ROM_PTR(&zta_Graph_Run_obj) },
    { MP_ROM_QSTR(MP_QSTR_RunWithTimeout), MP_ROM_PTR(&zta_Graph_RunWithTimeout_obj) },
};
STATIC MP_DEFINE_CONST_DICT(zta_Graph_locals_dict, zta_Graph_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    zta_type_Graph,
    MP_QSTR_Graph,
    MP_TYPE_FLAG_NONE,
    make_new, zta_Graph_make_new,
    locals_dict, &zta_Graph_locals_dict
    );

//---------------------------------------------------------------------------
// Module definition
//---------------------------------------------------------------------------

STATIC const mp_rom_map_elem_t zta_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_zta) },
    { MP_ROM_QSTR(MP_QSTR_DeleteAll), MP_ROM_PTR(&zta_DeleteAll_obj) },
    { MP_ROM_QSTR(MP_QSTR_SetLed), MP_ROM_PTR(&zta_SetLed_obj) },
    { MP_ROM_QSTR(MP_QSTR_ButtonState), MP_ROM_PTR(&zta_ButtonState_obj) },
    { MP_ROM_QSTR(MP_QSTR_GetTimeMsec), MP_ROM_PTR(&zta_GetTimeMsec_obj) },
    { MP_ROM_QSTR(MP_QSTR_GetElapsedTimeMsec), MP_ROM_PTR(&zta_GetElapsedTimeMsec_obj) },
    { MP_ROM_QSTR(MP_QSTR_CameraCapture), MP_ROM_PTR(&zta_CameraCapture_obj) },
    { MP_ROM_QSTR(MP_QSTR_DisplayFlushCanvas), MP_ROM_PTR(&zta_DisplayFlushCanvas_obj) },
    { MP_ROM_QSTR(MP_QSTR_CanvasDrawText), MP_ROM_PTR(&zta_CanvasDrawText_obj) },
    { MP_ROM_QSTR(MP_QSTR_CanvasDrawPoint), MP_ROM_PTR(&zta_CanvasDrawPoint_obj) },
    { MP_ROM_QSTR(MP_QSTR_CanvasDrawRectangle), MP_ROM_PTR(&zta_CanvasDrawRectangle_obj) },
    { MP_ROM_QSTR(MP_QSTR_TensorCamera), MP_ROM_PTR(&zta_type_TensorCamera) },
    { MP_ROM_QSTR(MP_QSTR_TensorDisplay), MP_ROM_PTR(&zta_type_TensorDisplay) },
    { MP_ROM_QSTR(MP_QSTR_Tensor), MP_ROM_PTR(&zta_type_Tensor) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeCopyAndTransform), MP_ROM_PTR(&zta_type_GraphNodeCopyAndTransform) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeCanny), MP_ROM_PTR(&zta_type_GraphNodeCanny) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeGaussian), MP_ROM_PTR(&zta_type_GraphNodeGaussian) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeHarris), MP_ROM_PTR(&zta_type_GraphNodeHarris) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeOpticalFlow), MP_ROM_PTR(&zta_type_GraphNodeOpticalFlow) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeResize), MP_ROM_PTR(&zta_type_GraphNodeResize) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeImageClassifier), MP_ROM_PTR(&zta_type_GraphNodeImageClassifier) },
    { MP_ROM_QSTR(MP_QSTR_GraphNodeObjectDetection), MP_ROM_PTR(&zta_type_GraphNodeObjectDetection) },
    { MP_ROM_QSTR(MP_QSTR_Graph), MP_ROM_PTR(&zta_type_Graph) },
    { MP_ROM_QSTR(MP_QSTR_INTERLEAVED), MP_ROM_INT(CONST_INTERLEAVED)},
    { MP_ROM_QSTR(MP_QSTR_PLANAR), MP_ROM_INT(CONST_PLANAR)},
    { MP_ROM_QSTR(MP_QSTR_MONO1), MP_ROM_INT(CONST_MONO1)},
    { MP_ROM_QSTR(MP_QSTR_MONO3), MP_ROM_INT(CONST_MONO3)},
    { MP_ROM_QSTR(MP_QSTR_COLOR), MP_ROM_INT(CONST_COLOR)},
};
STATIC MP_DEFINE_CONST_DICT(zta_module_globals, zta_module_globals_table);

// Define module object.
const mp_obj_module_t zta_user_cmodule = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&zta_module_globals,
};

MP_REGISTER_MODULE(MP_QSTR_zta, zta_user_cmodule);
