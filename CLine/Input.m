//
//  Input.m
//  CLine
//
//  Created by Ivan Moscoso on 11/24/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Input.h"

@implementation Input  {
    EditLine*  _editLine;
    Tokenizer* _tokenizer;

    History*  _history;
    HistEvent _histEvent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        /* Initialize editline */
        _editLine = el_init("", stdin, stdout, stderr);
        
        /* Initialize tokenizer */
        _tokenizer = tok_init(NULL);
        
        /* Initialize history */
        _history = history_init();
        if (_history == 0) {
            fprintf(stderr, "Unable to initialize history\n");
            return nil;
        }

        /* Set prompt */
        el_set(_editLine, EL_PROMPT, &prompt);
        
        /* Set edit style */
        el_set(_editLine, EL_EDITOR, "emacs");
        
        /* Set history */
        history(_history, &_histEvent, H_SETSIZE, 200);
        
        /* Set callback 'history' function */
        el_set(_editLine, EL_HIST, history, _history);
        
        /* Set auto-complete function */
        el_set(_editLine, EL_ADDFN, "complete", "Complete argument", &complete);
        el_set(_editLine, EL_BIND, "^I", "complete", NULL);
    }
    return self;
}

/*
 * function to auto-complete (invoked via 'tab')
 * will return CC_ERROR if autocomplete is not possible,
 * or CC_REFRESH if the line has been appended/inserted
 */
static unsigned char complete(EditLine *el, int ch) {

    NSSet *set = [NSSet setWithObjects:@"logout", @"list", @"help", nil];
    
    const LineInfo* line = el_line(el);
    long length = line->cursor - line->buffer;
    NSString *currentLine = [[NSString stringWithCString:line->buffer
                                                encoding:NSUTF8StringEncoding]
                             substringToIndex:length];
    for(NSString *item in set) {
        if ([item hasPrefix:currentLine]) {
            NSString *completion = [item substringFromIndex:currentLine.length];
            el_insertstr(el, [completion cStringUsingEncoding:NSUTF8StringEncoding]);
            return CC_REFRESH;
        }
    }
    return CC_ERROR;
}

- (void)dealloc
{
    history_end(_history);
    el_end(_editLine);
}

char * prompt(EditLine *e) {
    return "cline > ";
}

/*
 * Returns a tokenized line of input
 */
-(NSArray *)read
{
    int charsRead;
    const char* lineContent;

    /* Tokenization variables */
    int continuation;
    int numberOfWords, indexOfWordForCursor, offsetOfCursorInWord;
    const char **words;
    
    /* Read the line */
    lineContent = el_gets(_editLine, &charsRead);
    
    if (charsRead > 0) {
        history(_history, &_histEvent, H_ENTER, lineContent);
    }
    
    /* Tokenize */
    continuation = tok_line(_tokenizer, el_line(_editLine),
                            &numberOfWords, &words,
                            &indexOfWordForCursor, &offsetOfCursorInWord);
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:numberOfWords];
    
    for (int i = 0; i < numberOfWords; i++) {
        NSString *string = [NSString stringWithCString:words[i] encoding:NSUTF8StringEncoding];
        [array addObject:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    /* Reset the tokenizer before returning */
    tok_reset(_tokenizer);
    
    return [array copy];
}

@end