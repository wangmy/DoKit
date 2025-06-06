//
//  DoraemonSandboxViewController.m
//  DoraemonKit
//
//  Created by yixiang on 2017/12/11.
//

#import "DoraemonSandboxViewController.h"
#import "DoraemonSandboxModel.h"
#import "DoraemonSanboxDetailViewController.h"
#import "DoraemonNavBarItemModel.h"
#import "DoraemonAppInfoUtil.h"
#import "DoraemonDefine.h"
#import "DoraemonSandboxCell.h"
#import "DoraemonUtil.h"

@interface DoraemonSandboxViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DoraemonSandboxModel *currentDirModel;
@property (nonatomic, strong) NSMutableArray<NSArray<DoraemonSandboxModel *> *> *datas;
@property (nonatomic, copy) NSSet<NSString *> *rootsPathsSet;
@property (nonatomic, strong) NSArray<DoraemonSandboxModel *> *rootsPaths;
@property (nonatomic, copy) NSString *rootPathName;
@property (nonatomic, assign) BOOL isRoot;

@property (nonatomic, strong) DoraemonNavBarItemModel *leftModel;

@end

@implementation DoraemonSandboxViewController
- (instancetype)initRootsPaths:(NSArray<DoraemonSandboxModel *> *)rootsPaths {
    self = [super init];
    if (self) {
        self.rootsPaths = rootsPaths;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadPath:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                self.leftModel.image = [UIImage doraemon_xcassetImageNamed:@"doraemon_back_dark"];
            } else {
                self.leftModel.image = [UIImage doraemon_xcassetImageNamed:@"doraemon_back"];
            }
        }
    }
#endif
}

- (BOOL)needBigTitleView {
    return YES;
}

- (void)initData {
    _datas = [NSMutableArray array];
    self.rootPathName = DoraemonLocalizedString(@"沙盒浏览器");
    if (_rootsPaths.count == 0) {
        DoraemonSandboxModel *rootModel = [[DoraemonSandboxModel alloc] init];
        rootModel.path = NSHomeDirectory();
        rootModel.name = @"HomeDirectory";
        rootModel.type = DoraemonSandboxFileTypeRoot;
        self.rootsPaths = @[rootModel];
    }
    NSMutableSet *set = [NSMutableSet set];
    for (DoraemonSandboxModel *rootModel in self.rootsPaths) {
        [set addObject:rootModel.path];
    }
    self.rootsPathsSet = [set copy];
}

- (void)initUI {
    self.title = DoraemonLocalizedString(@"沙盒浏览器");
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bigTitleView.doraemon_bottom, self.view.doraemon_width, self.view.doraemon_height-self.bigTitleView.doraemon_bottom) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}


- (void)loadPath:(NSString *)filePath {
    [self.datas removeAllObjects];
    NSString *targetPath = filePath;
    //该目录信息
    DoraemonSandboxModel *model = [[DoraemonSandboxModel alloc] init];
    BOOL isRoort = (targetPath.length == 0 || [self.rootsPathsSet containsObject:targetPath]);
    if (isRoort) {
        model.name = DoraemonLocalizedString(@"根目录");
        model.type = DoraemonSandboxFileTypeRoot;
        self.tableView.frame = CGRectMake(0, self.bigTitleView.doraemon_bottom, self.view.doraemon_width, self.view.doraemon_height-self.bigTitleView.doraemon_bottom);
        self.bigTitleView.hidden = NO;
        self.navigationController.navigationBarHidden = YES;
        self.rootPathName = DoraemonLocalizedString(@"沙盒浏览器");
        self.title = self.rootPathName;
        [self setLeftNavBarItems:nil];
    }else{
        model.name = DoraemonLocalizedString(@"返回上一级");
        model.type = DoraemonSandboxFileTypeBack;
        self.bigTitleView.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
        self.tableView.frame = CGRectMake(0, IPHONE_NAVIGATIONBAR_HEIGHT, self.view.doraemon_width, self.view.doraemon_height-IPHONE_NAVIGATIONBAR_HEIGHT);
        NSString *dirTitle =  [[NSFileManager defaultManager] displayNameAtPath:targetPath];
        self.title = [NSString stringWithFormat:@"%@-%@",self.rootPathName,dirTitle];
        UIImage *image = [UIImage doraemon_xcassetImageNamed:@"doraemon_back"];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
        if (@available(iOS 13.0, *)) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                image = [UIImage doraemon_xcassetImageNamed:@"doraemon_back_dark"];
            }
        }
#endif
        self.leftModel = [[DoraemonNavBarItemModel alloc] initWithImage:image selector:@selector(leftNavBackClick:)];
        
        [self setLeftNavBarItems:@[self.leftModel]];
    }
    model.path = filePath;
    _currentDirModel = model;
    
    NSMutableArray *filesDatas = [NSMutableArray array];
    if (isRoort) {
        for (DoraemonSandboxModel *rootModel in self.rootsPaths) {
            targetPath = rootModel.path;
            [self.datas addObject:[self _getFilesDataWithPath:targetPath]];
        }
    } else {
        [self.datas addObject:[self _getFilesDataWithPath:targetPath]];
    }
    
    [self.tableView reloadData];
}

- (NSArray *)_getFilesDataWithPath:(NSString *)targetPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    //该目录下面的内容信息
    NSMutableArray *files = @[].mutableCopy;
    NSError *error = nil;
    NSArray *paths = [fm contentsOfDirectoryAtPath:targetPath error:&error];
    for (NSString *path in paths) {
        BOOL isDir = false;
        NSString *fullPath = [targetPath stringByAppendingPathComponent:path];
        [fm fileExistsAtPath:fullPath isDirectory:&isDir];
        
        DoraemonSandboxModel *model = [[DoraemonSandboxModel alloc] init];
        model.path = fullPath;
        if (isDir) {
            model.type = DoraemonSandboxFileTypeDirectory;
        }else{
            model.type = DoraemonSandboxFileTypeFile;
        }
        model.name = path;
        
        [files addObject:model];
    }
    
    //_dataArray = files.copy;
    
    // 按名称排序，并保持文件夹在上
    NSArray *filesData = [files sortedArrayUsingComparator:^NSComparisonResult(DoraemonSandboxModel * _Nonnull obj1, DoraemonSandboxModel * _Nonnull obj2) {
        
        BOOL isObj1Directory = (obj1.type == DoraemonSandboxFileTypeDirectory);
        BOOL isObj2Directory = (obj2.type == DoraemonSandboxFileTypeDirectory);
        
        // 都是目录 或 都不是目录
        BOOL isSameType = ((isObj1Directory && isObj2Directory) || (!isObj1Directory && !isObj2Directory));
        
        if (isSameType) { // 都是目录 或 都不是目录
            
            // 按名称排序
            return [obj1.name.lowercaseString compare:obj2.name.lowercaseString];
        }
        
        // 以下是一个为目录，一个不为目录的情况
        
        if (isObj1Directory) { // obj1是目录
            
            // 升序，保持文件夹在上
            return NSOrderedAscending;
        }
        
        // obj2是目录，降序
        return NSOrderedDescending;
    }];
    if (filesData.count > 0) {
        return filesData;
    }
    return  @[];
}

#pragma mark- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   if (self.datas.count > 1) {
        if (self.rootsPaths.count > section) {
            return [self.rootsPaths objectAtIndex:section].name;
        }
    }
    return @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    DoraemonSandBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[DoraemonSandBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    DoraemonSandboxModel *model = self.datas[indexPath.section][indexPath.row];
    [cell renderUIWithData:model];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return DoraemonLocalizedString(@"删除");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DoraemonSandboxModel *model = self.datas[indexPath.section][indexPath.row];
    [self deleteByDoraemonSandboxModel:model];
}


#pragma mark- UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DoraemonSandBoxCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DoraemonSandboxModel *model = self.datas[indexPath.section][indexPath.row];
    if (model.type == DoraemonSandboxFileTypeFile) {
        [self handleFileWithPath:model.path];
    } else if (model.type == DoraemonSandboxFileTypeDirectory) {
        if (self.datas.count > 1 && self.rootsPaths.count > indexPath.section) {
            self.rootPathName = self.rootsPaths[indexPath.section].name;
        }
        [self loadPath:model.path];
    }
}


- (void)leftNavBackClick:(id)clickView {
    if (_currentDirModel.type == DoraemonSandboxFileTypeRoot) {
        [super leftNavBackClick:clickView];
    } else {
        [self loadPath:[_currentDirModel.path stringByDeletingLastPathComponent]];
    }
}

- (void)handleFileWithPath:(NSString *)filePath {
    UIAlertControllerStyle style;
    if ([DoraemonAppInfoUtil isIpad]) {
        style = UIAlertControllerStyleAlert;
    } else {
        style = UIAlertControllerStyleActionSheet;
    }
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:DoraemonLocalizedString(@"请选择操作方式") message:nil preferredStyle:style];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *previewAction = [UIAlertAction actionWithTitle:DoraemonLocalizedString(@"本地预览") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf previewFile:filePath];
    }];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:DoraemonLocalizedString(@"分享") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf shareFileWithPath:filePath];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DoraemonLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:previewAction];
    [alertVc addAction:shareAction];
    [alertVc addAction:cancelAction];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)previewFile:(NSString *)filePath {
    DoraemonSanboxDetailViewController *detalVc = [[DoraemonSanboxDetailViewController alloc] init];
    detalVc.filePath = filePath;
    [self.navigationController pushViewController:detalVc animated:YES];
}


- (void)shareFileWithPath:(NSString *)filePath {
    [DoraemonUtil shareURL:[NSURL fileURLWithPath:filePath] formVC:self];
}

- (void)deleteByDoraemonSandboxModel:(DoraemonSandboxModel *)model {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:model.path error:nil];
    [self loadPath:_currentDirModel.path];
}


@end
