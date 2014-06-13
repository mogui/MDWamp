//
//  NSString+MDString.m
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "NSString+MDString.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation NSString (MDString)

+ (NSString*) stringWithRandomId
{
	NSInteger ii;
    NSString *allletters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuwxyz0123456789";
	NSString *outstring = @"";
    for (ii=0; ii<20; ii++) {
        outstring = [outstring stringByAppendingString:[allletters substringWithRange:[allletters rangeOfComposedCharacterSequenceAtIndex:random()%[allletters length]]]];
    }
	
    return outstring;
}

- (NSString *) hmacSHA256DataWithKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    

    return [[NSData dataWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] base64Encoding];
}


@end
