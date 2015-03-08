//
//  AVP2DArray.h
//  AVP2DArray
//
//  Created by Alexey Patosin on 08/03/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVP2DArray : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height;       // empty object is [NSNull null] by default

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                  emptyObject:(id)emptyObject;

+ (instancetype)arrayWithWidth:(NSUInteger)width
                        height:(NSUInteger)height;

+ (instancetype)arrayWithWidth:(NSUInteger)width
                        height:(NSUInteger)height
                   emptyObject:(id)emptyObject;

- (id)objectAtX:(NSUInteger)x y:(NSUInteger)y;
- (void)addObject:(id)obj atX:(NSUInteger)x y:(NSUInteger)y;

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
