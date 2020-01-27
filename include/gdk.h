#ifndef GDK_GDK_H
#define GDK_GDK_H
#pragma once

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#ifdef GDK_BUILD
#define GDK_API __declspec(dllexport)
#else
#define GDK_API
#endif
#elif defined(__GNUC__) && defined(GDK_BUILD)
#define GDK_API __attribute__((visibility("default")))
#else
#define GDK_API
#endif

/** Error codes for API calls */
#define GA_OK 0
#define GA_ERROR (-1)
#define GA_RECONNECT (-2)
#define GA_SESSION_LOST (-3)
#define GA_TIMEOUT (-4)
#define GA_NOT_AUTHORIZED (-5)

/** Logging levels */
#define GA_NONE 0
#define GA_INFO 1
#define GA_DEBUG 2

/** Boolean values */
#define GA_TRUE 1
#define GA_FALSE 0

/** Values for transaction memo type */
#define GA_MEMO_USER 0
#define GA_MEMO_BIP70 1

/**
 * Set the global configuration and run one-time initialization code. This function must
 * be called once and only once before calling any other functions. When used in a
 * multi-threaded context this function should be called before starting any other
 * threads that call other gdk functions.
 *
 * :param config: The :ref:`init-config-arg`.
 */
GDK_API int GA_init();

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* GDK_GDK_H */
