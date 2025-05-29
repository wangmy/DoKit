//
//  DoraemonSandboxViewController.h
//  DoraemonKit
//
//  Created by yixiang on 2017/12/11.
//

#import "DoraemonBaseViewController.h"
@class DoraemonSandboxModel;

@interface DoraemonSandboxViewController : DoraemonBaseViewController
- (instancetype)initRootsPaths:(NSArray<DoraemonSandboxModel *> *)rootsPaths;
@end
