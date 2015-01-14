//
//  NSObject+Debt.h
//  RePay
//
//  Created by Philip Olsson on 2014-12-09.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Debt : NSObject
@property NSString* fromName;
@property NSString* fromFbId;
@property NSString* message;
@property NSString* toName;
@property NSString* toFbId;
@property NSNumber* amount;
@property BOOL      approved;
@property NSDate*   createdAt;
@property NSString* objectId;

@end