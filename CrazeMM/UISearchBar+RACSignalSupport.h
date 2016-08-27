//
//  UISearchBar+RACSignalSupport.h
//  Pods
//
//  Created by Mao Mao on 16/4/19.
//
//

#import <UIKit/UIKit.h>
@class RACDelegateProxy;
@class RACSignal;
@interface UISearchBar (RACSignalSupport)

- (RACSignal *)rac_textSignal;

@end
