//
//  DataClass.h
//  RePay
//
//  Created by Philip Olsson on 2015-01-13.
//  Copyright (c) 2015 Philip Olsson. All rights reserved.
//

#ifndef RePay_DataClass_h
#define RePay_DataClass_h

//DataClass.h
@interface DataClass : NSObject {
    
    NSString *str;
}

@property(nonatomic,retain)NSString *str;
+(DataClass*)getInstance;
@end


//DataClass.m
@implementation DataClass
@synthesize str;

static DataClass *instance = nil;

+(DataClass *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [DataClass new];
        }
    }
    return instance;
}

@end

#endif
