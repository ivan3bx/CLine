//
//  Input.h
//  CLine
//
//  Created by Ivan Moscoso on 11/26/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

#import <histedit.h>

#ifndef CLine_Input_h
#define CLine_Input_h

@interface Input : NSObject {
    EditLine* _editLine;
    const char* _prompt;
}

-(instancetype)init;
-(NSString *)read;

@end

#endif
