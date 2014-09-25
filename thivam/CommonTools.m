//
//  CommonTools.m
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import "CommonTools.h"

#define ARC4RANDOM_MAX 0x100000000

@implementation CommonTools

+(int)getRandomNumberFromInt:(int)from toInt:(int)to
{
    return from + arc4random() %(to+1-from);;
}

+(float)getRandomFloatFromFloat:(float)from toFloat:(float)to
{
    return ((float)arc4random() / ARC4RANDOM_MAX) * (to-from) + from;
}

+(NSString *)hmacForKey:(NSString *)key andData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [[HMAC.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (UIColor *) stringToColor:(NSString *) colorString
{
    unsigned int c;
    
    [[NSScanner scannerWithString:colorString] scanHexInt:&c];
    
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:1.0];
}

+ (UIColor *) stringToColor:(NSString *) colorString withAlpha:(CGFloat)alpha
{
    unsigned int c;
    
    [[NSScanner scannerWithString:colorString] scanHexInt:&c];
    
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:alpha];
}

@end
