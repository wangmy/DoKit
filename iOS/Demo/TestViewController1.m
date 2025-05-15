//
//  TestViewController1.m
//  Demo
//
//  Created by yoyomwang on 2025/5/15.
//

#import "TestViewController1.h"

@interface TestViewController1 ()

@end

@implementation TestViewController1
+ (void) load {
    NSLog(@"DLA >>>> TestViewController1 call load");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
