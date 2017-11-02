//
//  BinaryDAO.h
//  imagestore
//
//  Created by oddman on 11/1/15.
//  Copyright © 2015 oddman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BinaryDAO : NSObject

@property(nonatomic, strong) NSString *fullDbPath;

- (instancetype) initWithPath:(NSString *)path;
- (void) createBinaryDB;

- (void) insertBinaryData:(NSData*)binData binName:(NSString*)binName;
- (NSMutableArray *) selectBinaryStoredList;
- (NSData*) displaySelectedFile:(NSString*)selectedFile;
- (BOOL) deleteSelectedFile:(NSString *)selectedFile;

@end
