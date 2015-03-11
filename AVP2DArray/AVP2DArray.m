//
//  AVP2DArray.m
//  AVP2DArray
//
//  Created by Alexey Patosin on 08/03/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import "AVP2DArray.h"

@interface AVP2DArray ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation AVP2DArray

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height {
    return [self initWithWidth:width
                        height:height
                   emptyObject:[NSNull null]];
}

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                  emptyObject:(id)emptyObject {
    NSParameterAssert(emptyObject);
    NSAssert(width > 0, @"Width must be larger than zero! %lu", width);
    NSAssert(height > 0, @"Height must be larger than zero! %lu", width);
    
    self = [super init];
    if (self) {
        _width = width;
        _height = height;
        _array = [NSMutableArray arrayWithCapacity:width * height];

        [self basicSetup];
        
        for (NSUInteger x = 0;x<width;x++) {
            for (NSUInteger y = 0;y<height;y++) {
                [_array addObject:emptyObject];
            }
        }
    }
    return self;
}

+ (instancetype)arrayWithWidth:(NSUInteger)width
                        height:(NSUInteger)height {
    AVP2DArray *array = [[AVP2DArray alloc] initWithWidth:width height:height];
    return array;
}

+ (instancetype)arrayWithWidth:(NSUInteger)width
                        height:(NSUInteger)height
                   emptyObject:(id)emptyObject {
    
    AVP2DArray *array = [[AVP2DArray alloc] initWithWidth:width
                                                   height:height
                                              emptyObject:emptyObject];
    return array;
    
}

- (void)basicSetup {
    _queue = dispatch_queue_create("avp2darray.queue", 0);
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    AVP2DArray *copyArray = [[AVP2DArray alloc] initWithWidth:self.width height:self.height];
    
    for (NSUInteger i=0;i<self.width;i++) {
        for (NSUInteger j=0;j<self.height;j++) {
            id copiedObject = [[self objectAtX:i y:j] copy];
            
            [copyArray addObject:copiedObject atX:i y:j];
        }
    }
    
    return copyArray;
    
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _width = [decoder decodeIntegerForKey:@"width"];
    _height = [decoder decodeIntegerForKey:@"height"];
    self.array = [decoder decodeObjectForKey:@"array"];
    
    [self basicSetup];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.width forKey:@"width"];
    [encoder encodeInteger:self.height forKey:@"height"];
    [encoder encodeObject:self.array forKey:@"array"];
}

#pragma mark - NSFastEnumeration protocol methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.array countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - access methods

- (NSUInteger)indexForX:(NSUInteger)x y:(NSUInteger)y {
    NSAssert(x < self.width, @"x == %lu is out of bounds == %lu", x, self.width);
    NSAssert(y < self.height, @"y == %lu is out of bounds == %lu", y, self.height);
    
    return self.width * y + x;
}

- (id)objectAtX:(NSUInteger)x y:(NSUInteger)y {
    __block id object = nil;
    
    dispatch_sync(self.queue, ^{
        object = self.array[[self indexForX:x y:y]];
    });
    
    return object;
}

- (id)objectAtPoint:(CGPoint)point {
    return [self objectAtX:point.x y:point.y];
}

- (void)addObject:(id)obj atX:(NSUInteger)x y:(NSUInteger)y {
    dispatch_barrier_async(self.queue, ^{
        self.array[[self indexForX:x y:y]] = obj;
    });
}

#pragma mark - enumerate methods

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    dispatch_barrier_async(self.queue, ^{
        [self.array enumerateObjectsUsingBlock:block];
    });
}

@end
