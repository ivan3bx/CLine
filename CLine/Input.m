//
//  Input.m
//  CLine
//
//  Created by Ivan Moscoso on 11/24/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Input.h"

@implementation Input

- (instancetype)init
{
    self = [super init];
    if (self) {
        _editLine = el_init("", stdin, stdout, stderr);
        el_set(_editLine, EL_PROMPT, &prompt);
    }
    return self;
}

char * prompt(EditLine *e) {
    return "cline > ";
}

-(NSString *)read
{
    int count;
    const char* line = el_gets(_editLine, &count);
    
    NSString *result;
    if (line) {
        result = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
    } else {
        return result = @"";
    }
    
    return [result stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

@end