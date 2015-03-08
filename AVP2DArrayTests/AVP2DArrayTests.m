//
//  AVP2DArrayTests.m
//  AVP2DArrayTests
//
//  Created by Alexey Patosin on 08/03/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AVP2DArray.h"

@interface AVP2DArrayTests : XCTestCase

@end

@interface HelperClass : NSObject
@property (nonatomic) BOOL isProcessed;
@end

@implementation AVP2DArrayTests

- (void)testNilEmptyObjectShouldThrowException {
    XCTAssertThrows([AVP2DArray arrayWithWidth:10 height:10 emptyObject:nil], @"nil empty object should throw exception");
}

- (void)testZeroWidthShouldThrowException {
    XCTAssertThrows([AVP2DArray arrayWithWidth:0 height:10], @"zero width 2d array should throw exception");
}

- (void)testZeroHeightShouldThrowException {
    XCTAssertThrows([AVP2DArray arrayWithWidth:10 height:0], @"zero height 2d array should throw exception");
}

- (void)testArrayShouldReturnsEmptyObjects {
    NSUInteger width = 5;
    NSUInteger height = 3;
    
    NSObject *emptyObject = [NSObject new];
    
    AVP2DArray *array = [AVP2DArray arrayWithWidth:width height:height emptyObject:emptyObject];
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            XCTAssert([array objectAtX:i y:j] == emptyObject, @"array should return certain empty object by default");
        }
    }
}

- (void)testArrayShouldReturnsNSNullObjectByDefault {
    NSUInteger width = 5;
    NSUInteger height = 3;
    
    AVP2DArray *array = [AVP2DArray arrayWithWidth:width height:height];
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            XCTAssert([array objectAtX:i y:j] == [NSNull null], @"array should return certain empty object by default");
        }
    }
}

- (void)testArrayShouldStoreItems {
    NSUInteger width = 5;
    NSUInteger height = 3;
    
    AVP2DArray *array = [AVP2DArray arrayWithWidth:width height:height];

    NSUInteger k = 0;
    
    NSMutableArray *row = [NSMutableArray array];
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            NSString *object = [NSString stringWithFormat:@"%lu", k];
            [array addObject:object atX:i y:j];
            [row addObject:object];
            k++;
        }
    }

    k = 0;
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            XCTAssert([array objectAtX:i y:j] == row[k], @"array must return the same objects which were appended %@ should be %@",
                      [array objectAtX:i y:j], row[k]);
            k++;
        }
    }
}

- (void)testArrayShouldBeCopiedProperly {
    NSUInteger width = 5;
    NSUInteger height = 3;
    
    AVP2DArray *array = [AVP2DArray arrayWithWidth:width height:height];
    
    NSUInteger k = 0;
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            NSMutableString *object = [NSMutableString stringWithFormat:@"%lu", k];
            [array addObject:object atX:i y:j];
            k++;
        }
    }

    AVP2DArray *arrayCopy = [array copy];
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            XCTAssert([array objectAtX:i y:j] != [arrayCopy objectAtX:i y:j] &&
                      [[array objectAtX:i y:j] isEqualTo:[arrayCopy objectAtX:i y:j]],
                      @"array should be possible to copy, elements must be not the same, but equal");
        }
    }
}

- (void)testArrayShouldBeEncodedProperly {
    NSUInteger width = 5;
    NSUInteger height = 3;
    
    AVP2DArray *array = [AVP2DArray arrayWithWidth:width height:height];
    
    NSUInteger k = 0;
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            NSMutableString *object = [NSMutableString stringWithFormat:@"%lu", k];
            [array addObject:object atX:i y:j];
            k++;
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    
    AVP2DArray *decodedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            XCTAssert([array objectAtX:i y:j] != [decodedArray objectAtX:i y:j] &&
                      [[array objectAtX:i y:j] isEqualTo:[decodedArray objectAtX:i y:j]],
                      @"array should be possible to encode/decode, elements must be not the same, but equal");
        }
    }
}

- (void)testArrayShouldPerformBlockForAllElements {
    NSUInteger width = 5;
    NSUInteger height = 3;
    
    AVP2DArray *array = [AVP2DArray arrayWithWidth:width height:height];
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            HelperClass *object = [HelperClass new];
            [array addObject:object atX:i y:j];
        }
    }
    
    [array enumerateObjectsUsingBlock:^(HelperClass *obj, NSUInteger idx, BOOL *stop) {
        obj.isProcessed = YES;
    }];

    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            HelperClass *object = [array objectAtX:i y:j];
            XCTAssert(object.isProcessed, @"enumeration should process all objects of the array");
        }
    }
    
}

- (void)testArrayShouldEnumerateElements {
    NSUInteger width = 5;
    NSUInteger height = 3;
    
    AVP2DArray *array = [AVP2DArray arrayWithWidth:width height:height];
    
    NSUInteger k = 0;
    
    for (int i=0;i<width;i++) {
        for (int j=0;j<height;j++) {
            NSMutableString *object = [NSMutableString stringWithFormat:@"%lu", k];
            [array addObject:object atX:i y:j];
            k++;
        }
    }
    
    k = 0;
    for (NSString *str in array) {
        XCTAssert([str integerValue] == k, @"fast enumeration should provide elements in a row");
        k++;
    }
    
}

@end

@implementation HelperClass

- (instancetype)init {
    self = [super init];
    if (self) {
        _isProcessed = NO;
    }
    return self;
}

@end