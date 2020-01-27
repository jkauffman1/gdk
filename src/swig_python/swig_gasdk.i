/*
  The automatic module importing varies between Swig3 and Swig4.
  Make explicit so should work for both versions.
  (Basically the swig3 version).

  NOTE:
  The behaviour of pybuffer_binary varies wrt a Py_None argument between Swig3
  (raises TypeError) and Swig4 (passes through as NULL) - we don't seem to use
  it here so shouldn't be a problem, but if we need it in future there are
  explicit implementations of 'nullable' and 'non-null' macros in libwally-core
  providing consistent behaviour across swig versions - copy those if required.
*/
%define MODULEIMPORT
"
def swig_import_helper():
    import importlib
    pkg = __name__.rpartition('.')[0]
    mname = '.'.join((pkg, '$module')).lstrip('.')
    try:
        return importlib.import_module(mname)
    except ImportError:
        return importlib.import_module('$module')
$module = swig_import_helper()
del swig_import_helper
"
%enddef
%module(moduleimport=MODULEIMPORT) greenaddress
%{
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#define SWIG_FILE_WITH_INIT
#include "../../include/gdk.h"
#include <limits.h>

static int check_result(int result)
{
    switch (result) {
    case GA_OK:
        break;
    case GA_ERROR:
        PyErr_SetString(PyExc_RuntimeError, "Failed");
        break;
    case GA_NOT_AUTHORIZED:
        PyErr_SetString(PyExc_RuntimeError, "Not Authorized");
        break;
    default: /* FIXME */
        PyErr_SetString(PyExc_RuntimeError, "Connection Error");
        break;
    }
    return result;
}

%}

%include pybuffer.i
%include exception.i

/* Raise an exception whenever a function fails */
%exception{
    $action
    if (check_result(result))
        SWIG_fail;
};

/* Return None if we didn't throw instead of 0 */
%typemap(out) int %{
    Py_IncRef(Py_None);
    $result = Py_None;
%}

/* Output strings are converted to native python strings and returned */
%typemap(in, numinputs=0) char** (char* txt) {
   txt = NULL;
   $1 = ($1_ltype)&txt;
}
%typemap(argout) char** {
   if (*$1 != NULL) {
       Py_DecRef($result);
       $result = PyString_FromString(*$1);
       GA_destroy_string(*$1);
   }
}

/* Opaque types are passed along as capsules */
%define %py_struct(NAME)
%typemap(in, numinputs=0) struct NAME ** (struct NAME * w) {
   w = 0; $1 = ($1_ltype)&w;
}
%typemap (in) const struct NAME * {
    $1 = $input == Py_None ? NULL : PyCapsule_GetPointer($input, "struct NAME *");
}
%typemap (in) struct  NAME * {
    $1 = $input == Py_None ? NULL : PyCapsule_GetPointer($input, "struct NAME *");
}
%typemap(argout) struct NAME ** {
   if (*$1 != NULL) {
       Py_DecRef($result);
       $result = PyCapsule_New(*$1, "struct NAME *", destroy_ ## NAME);
   }
}
%enddef

%py_struct(GA_session);
%py_struct(GA_auth_handler);

/* GA_json is auto converted to/from python strings */
%typemap(in, numinputs=0) GA_json ** (GA_json * w) {
   w = 0; $1 = ($1_ltype)&w;
}
%typemap (in) const GA_json * {
}
%typemap (in) GA_json * {
}
%typemap (freearg) GA_json * {
}
%typemap(argout) GA_json ** {
}
%typemap(in, numinputs=0) uint32_t * (uint32_t temp) {
   $1 = &temp;
}
%typemap(argout) uint32_t* {
    Py_DecRef($result);
    $result = PyInt_FromLong(*$1);
}

/* Tell swig about uin32_t */
typedef unsigned int uint32_t;

%pybuffer_mutable_binary(unsigned char *output_bytes, size_t len)

%rename("%(regex:/^GA_(.+)/\\1/)s", %$isfunction) "";

%include "../include/gdk.h"
