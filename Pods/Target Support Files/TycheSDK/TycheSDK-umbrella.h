#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "debugLog.h"
#import "libdefines.h"
#import "libEpdApi.h"
#import "libexports.h"
#import "libSpeexApi.h"
#import "libtypes.h"
#import "libWakeupApi.h"
#import "TycheSDK.h"

FOUNDATION_EXPORT double TycheSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char TycheSDKVersionString[];

