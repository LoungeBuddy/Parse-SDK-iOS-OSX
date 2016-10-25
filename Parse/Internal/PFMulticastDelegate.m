/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "PFMulticastDelegate.h"

@interface PFMulticastDelegate () {
    NSPointerArray *_callbacks;
    NSObject *_lock;
}

@end

@implementation PFMulticastDelegate

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _callbacks = [NSPointerArray strongObjectsPointerArray];
    _lock = [[NSObject alloc] init];

    return self;
}

- (void)dealloc {
    @synchronized (_lock) {
        [self clear];
    }
}

- (void)subscribe:(PFMulticastDelegateCallback)block {
    @synchronized (_lock) {
        [_callbacks addPointer:(__bridge void *)[block copy]];
    }
}

- (void)unsubscribe:(PFMulticastDelegateCallback)block {
    @synchronized (_lock) {
        for (NSUInteger i = 0; i < _callbacks.count; i++) {
            void *subscriber = [_callbacks pointerAtIndex:i];
            if (subscriber != NULL && subscriber == block) {
                [_callbacks removePointerAtIndex:i];
            }
        }
        [_callbacks compact];
    }
}

- (void)invoke:(id)result error:(NSError *)error {
    @synchronized (_lock) {
        for (PFMulticastDelegateCallback block in _callbacks) {
            block(result, error);
        }
    }
}
- (void)clear {
    @synchronized (_lock) {
        for (NSUInteger i = 0; i < _callbacks.count; i++) {
            [_callbacks removePointerAtIndex:i];
        }
        [_callbacks compact];
    }
}

@end
