//
//  MDCrypto.m
//  MDWamp
//
//  Created by Mathias on 3/21/13.
//  Copyright (c) 2013 mogui. All rights reserved.
//

#import "MDCrypto.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

#import "NSData+SRB64Additions.h"

@implementation MDCrypto

+ (NSString *) hmacSHA256Data:(NSString *)data withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];

    NSString *hash = [HMAC SR_stringByBase64Encoding];
    
    return hash;
}

@end
