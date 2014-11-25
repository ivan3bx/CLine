//
//  Input.m
//  CLine
//
//  Created by Ivan Moscoso on 11/24/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <histedit.h>

@interface Input : NSObject {
    EditLine* _editLine;
}
@end

@implementation Input

- (instancetype)init
{
    self = [super init];
    if (self) {
        _editLine = el_init("", stdin, stdout, stderr);

    }
    return self;
}

-(NSString *)read
{
    int count;
    const char* line = el_gets(_editLine, &count);
    return [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
}

@end