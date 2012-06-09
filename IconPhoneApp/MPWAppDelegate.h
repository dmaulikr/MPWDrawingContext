//
//  MPWAppDelegate.h
//  IconPhoneApp
//
//  Created by Marcel Weiher on 2/17/12.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MethodServer;

@interface MPWAppDelegate : UIResponder <UIApplicationDelegate>
{
    MethodServer *methodServer;
}

@property (strong, nonatomic) UIWindow *window;

@end
