//
//  DoraemonSettingViewController.m
//  DoraemonKit
//
//  Created by didi on 2020/4/24.
//

#import "DoraemonSettingViewController.h"
#import "DoraemonDefine.h"
#import "DoraemonCellButton.h"
#import "DoraemonKitManagerViewController.h"
#import "DoraemonSettingCell.h"
#import "DoraemonDefaultWebViewController.h"
#import "UIViewController+Doraemon.h"

@interface DoraemonSettingViewController ()<DoraemonCellButtonDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DoraemonCellButton *kitManagerBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation DoraemonSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DoraemonLocalizedString(@"更多");
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self loadData];
    [self.tableView registerClass:[DoraemonSettingCell class] forCellReuseIdentifier:@"dokit.setting.cell"];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = [self fullscreen];
}

- (void)loadData {
    WEAKSELF(weakSelf)
    NSString *jsonString = @"{\"success\":true,\"data\":{\"group\":[{\"group\":\"本地功能\",\"list\":[{\"type\":\"native\",\"name\":\"功能管理\",\"desc\":\"介绍:可以针对dokit的内置工具列表进行自定义排序\",\"link\":\"dokit:\/\/native\/function_manager\"}]},{\"group\":\"官方消息\",\"list\":[{\"type\":\"web\",\"name\":\"dokit官网\",\"desc\":\"介绍:dokit.cn你值得拥有的APP研发助手一站式解决方案。\",\"link\":\"https:\/\/www.dokit.cn\"},{\"type\":\"web\",\"name\":\"dokit操作手册\",\"desc\":\"介绍:dokit官方操作手册\",\"link\":\"http:\/\/xingyun.xiaojukeji.com\/docs\/dokit\/#\/intro\"}]}]},\"code\":200}";
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"Error converting JSON string to dictionary: %@", error.localizedDescription);
    } else {
        NSLog(@"%@", dataDic);
        weakSelf.dataArr = [[dataDic objectForKey:@"data"] objectForKey:@"group"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
    
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURL *url = [NSURL URLWithString:@"https://star.xiaojukeji.com/config/get.node?city=-1&areaid=&name=group"];
//    NSURLSessionTask *task = [session dataTaskWithURL:url
//                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError* error) {
//        if (error == nil) {
////            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
//            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            weakSelf.dataArr = [[dataDic objectForKey:@"data"] objectForKey:@"group"];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.tableView reloadData];
//            });
//        }
//    }];
//
//    [task resume];
}

#pragma mark -- DoraemonCellButtonDelegate
- (void)cellBtnClick:(id)sender{
    DoraemonKitManagerViewController *vc = [[DoraemonKitManagerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *listArr = [self.dataArr[section] objectForKey:@"list"];
    return listArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoraemonSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dokit.setting.cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.cellData = self.dataArr[indexPath.section][@"list"][indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataArr[section] objectForKey:@"group"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *cellData = self.dataArr[indexPath.section][@"list"][indexPath.row];
    
    if ([[cellData objectForKey:@"type"] isEqualToString:@"native"]) {
        DoraemonKitManagerViewController *vc = [[DoraemonKitManagerViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([[cellData objectForKey:@"type"] isEqualToString:@"web"]) {
        DoraemonDefaultWebViewController *webVc = [[DoraemonDefaultWebViewController alloc] init];
        webVc.h5Url = cellData[@"link"];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}
#pragma mark -- Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return _tableView;
}

@end
