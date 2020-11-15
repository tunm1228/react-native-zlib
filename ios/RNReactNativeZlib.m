
#import "RNReactNativeZlib.h"
#include "compression.h"

@implementation RNReactNativeZlib

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(inflate: (NSArray *) data
                  resolver: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject) {


    unsigned long dataSize = data.count;

    uint8_t *srcBuffer = (uint8_t*)malloc(dataSize);
    for (unsigned long i = 2; i < dataSize; i++) {
        srcBuffer[i-2] = (uint8_t) [[data objectAtIndex:i] longValue];
    }
    @try {

        for (int att = 1; att < 6; att++) {
            size_t dstSize = dataSize << att;
            size_t outSize;
            uint8_t *dstBuffer = (uint8_t*)malloc(dstSize);
            outSize = compression_decode_buffer(dstBuffer, dstSize, srcBuffer, dataSize-6, nil, COMPRESSION_ZLIB);
            if (outSize == dstSize) {
                free(dstBuffer);
                continue;
            }

            free(srcBuffer);
            NSMutableArray* result = [[NSMutableArray alloc] init];
            for (unsigned long i = 0; i < outSize; i++) {
                [result addObject:[[NSNumber alloc] initWithLong:(long) dstBuffer[i]]];
            }
            free(dstBuffer);
            resolve(result);
            break;
        }


    }
    @catch (NSException * ex) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:ex.name forKey:@"ExceptionName"];
        [info setValue:ex.reason forKey:@"ExceptionReason"];
        [info setValue:ex.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
        [info setValue:ex.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
        [info setValue:ex.userInfo forKey:@"ExceptionUserInfo"];

        NSError *error = [[NSError alloc] initWithDomain:@"RNReactNativeZlib" code:-1 userInfo:info];
        reject(@"Error", @"And error occurred while retrieving current time", error);
    }

}
@end

