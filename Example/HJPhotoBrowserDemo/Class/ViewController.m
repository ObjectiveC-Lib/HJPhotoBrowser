//
//  ViewController.m
//  HJPhotoBrowserDemo
//
//  Created by navy on 2018/12/4.
//  Copyright © 2018 navy. All rights reserved.
//

#import "ViewController.h"
#import "HJViewController.h"
#import "HJAccessory.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, HJPhotoBrowserDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [self footerView];
    [self.view addSubview:_tableView];
}

#pragma mark - Action

- (void)buttonWithImageOnScreenPressed:(UIButton *)button {
    NSLog(@"buttonWithImageOnScreenPressed");
    NSMutableArray *photos = @[].mutableCopy;
    HJPhoto *photo;
    
    if (button.tag == 101) {
        NSString *path_photo1l = [[NSBundle  mainBundle] pathForResource:@"photo1l" ofType:@"jpg"];
        photo = [HJPhoto photoWithFilePath:path_photo1l];
        photo.caption = @"";
        [photos addObject:photo];
    }
    
    NSString *path_photo3l = [[NSBundle  mainBundle] pathForResource:@"photo3l" ofType:@"jpg"];
    photo = [HJPhoto photoWithFilePath:path_photo3l];
    photo.caption = @"";
    [photos addObject:photo];
    
    NSString *path_photo2l = [[NSBundle  mainBundle] pathForResource:@"photo2l" ofType:@"jpg"];
    photo = [HJPhoto photoWithFilePath:path_photo2l];
    photo.caption = @"";
    [photos addObject:photo];

    NSString *path_photo4l = [[NSBundle  mainBundle] pathForResource:@"photo4l" ofType:@"jpg"];
    photo = [HJPhoto photoWithFilePath:path_photo4l];
    photo.caption = @"";
    [photos addObject:photo];
    
    if (button.tag == 102) {
        NSString *path_photo1l = [[NSBundle  mainBundle] pathForResource:@"photo1l" ofType:@"jpg"];
        photo = [HJPhoto photoWithFilePath:path_photo1l];
        photo.caption = @"";
        [photos addObject:photo];
    }
    
    HJViewController *browser = [[HJViewController alloc] initWithPhotos:photos animatedFromView:button];
    browser.delegate = self;
    browser.dismissOnTouch = NO;
    browser.usePopAnimation = YES;
    browser.forceHideStatusBar = NO;
    browser.disableVerticalSwipe = NO;
    browser.disablePhotoAnimation = NO;
    browser.useWhiteBackgroundColor = NO;
    browser.displayAccessoryView = NO;
    browser.scaleImage = button.currentImage;
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *photos = @[].mutableCopy;
    HJPhoto *photo;
    
    if (indexPath.section == 0) {
        NSString *path_photo2l = [[NSBundle  mainBundle] pathForResource:@"photo2l" ofType:@"jpg"];
        photo = [HJPhoto photoWithFilePath:path_photo2l];
        photo.caption = @"";
        [photos addObject:photo];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *path_photo1l = [[NSBundle  mainBundle] pathForResource:@"photo1l" ofType:@"jpg"];
            photo = [HJPhoto photoWithFilePath:path_photo1l];
            photo.caption = @"走在通往天空之城的印加古道，当清澈悦耳的音符飘浮在云端，迷幻升腾的云雾为我们带来马丘比丘迎客的祝福。西方外来文明踏上了美洲的土地。印加文明在西班牙殖民者血与火的征服中最终毁灭。设计师决定做一个折叠的咖啡桌与改变的梦想。与现场的场景非常相似。虽然价格标签不那么诱人，但如果你想在房子里放上咖啡桌，你就得放弃欧元。如果你想要的话，可以在这里买到。";
            [photos addObject:photo];
            
            NSString *path_photo2l = [[NSBundle  mainBundle] pathForResource:@"photo2l" ofType:@"jpg"];
            photo = [HJPhoto photoWithFilePath:path_photo2l];
            photo.caption = @"眼前是传说中的世界新七大奇迹之一马丘比丘，被印加帝国称为失落之城。走在通往天空之城的印加古道，当清澈悦耳的音符飘浮在云端，迷幻升腾的云雾为我们带来马丘比丘迎客的祝福。西方外来文明踏上了美洲的土地。印加文明在西班牙殖民者血与火的征服中最终毁灭。设计师决定做一个折叠的咖啡桌与改变的梦想。与现场的场景非常相似。虽然价格标签不那么诱人，但如果你想在房子里放上咖啡桌，你就得放弃欧元。如果你想要的话，可以在这里买到。眼前是传说中的世界新七大奇迹之一马丘比丘，被印加帝国称为失落之城。走在通往天空之城的印加古道，当清澈悦耳的音符飘浮在云端，迷幻升腾的云雾为我们带来马丘比丘迎客的祝福。西方外来文明踏上了美洲的土地。印加文明在西班牙殖民者血与火的征服中最终毁灭。设计师决定做一个折叠的咖啡桌与改变的梦想。与现场的场景非常相似。虽然价格标签不那么诱人，但如果你想在房子里放上咖啡桌，你就得放弃欧元。如果你想要的话，可以在这里买到。眼前是传说中的世界新七大奇迹之一马丘比丘，被印加帝国称为失落之城。走在通往天空之城的印加古道，当清澈悦耳的音符飘浮在云端，迷幻升腾的云雾为我们带来马丘比丘迎客的祝福。西方外来文明踏上了美洲的土地。印加文明在西班牙殖民者血与火的征服中最终毁灭。设计师决定做一个折叠的咖啡桌与改变的梦想。与现场的场景非常相似。虽然价格标签不那么诱人，但如果你想在房子里放上咖啡桌，你就得放弃欧元。如果你想要的话，可以在这里买到。眼前是传说中的世界新七大奇迹之一马丘比丘，被印加帝国称为失落之城。走在通往天空之城的印加古道，当清澈悦耳的音符飘浮在云端，迷幻升腾的云雾为我们带来马丘比丘迎客的祝福。西方外来文明踏上了美洲的土地。印加文明在西班牙殖民者血与火的征服中最终毁灭。设计师决定做一个折叠的咖啡桌与改变的梦想。与现场的场景非常相似。虽然价格标签不那么诱人，但如果你想在房子里放上咖啡桌，你就得放弃欧元。如果你想要的话，可以在这里买到。";
            [photos addObject:photo];
            
            NSString *path_photo3l = [[NSBundle  mainBundle] pathForResource:@"photo3l" ofType:@"jpg"];
            photo = [HJPhoto photoWithFilePath:path_photo3l];
            photo.caption = @"虽然价格标签不那么诱人，但如果你想在房子里放上咖啡桌，你就得放弃欧元。如果你想要的话，可以在这里买到。";
            [photos addObject:photo];
            
            NSString *path_photo4l = [[NSBundle  mainBundle] pathForResource:@"photo4l" ofType:@"jpg"];
            photo = [HJPhoto photoWithFilePath:path_photo4l];
            photo.caption = @"为我们带来马丘比丘迎客的祝福。西方外来文明踏上了美洲的土地。印加文明在西班牙殖民者血与火的征服中最终毁灭。设计师决定做一个折叠的咖啡桌与改变的梦想。与现场的场景非常相似。虽然价格标签不那么诱人，但如果你想在房子里放上咖啡桌，你就得放弃欧元。如果你想要的话，可以在这里买到。";
            [photos addObject:photo];
        } else if (indexPath.row == 1 || indexPath.row == 2) {
            NSArray *photosWithURLArray = @[
                                            [NSURL URLWithString:@"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7usmc8j20i543zngx.jpg"],
                                            [NSURL URLWithString:@"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"],
                                            [NSURL URLWithString:@"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7orgqfj20i80ht15x.jpg"],
                                            [NSURL URLWithString:@"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"],
                                            [NSURL URLWithString:@"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7n9eorj20i60hsann.jpg"],
                                            [NSURL URLWithString:@"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7orgqfj20i80ht15x.jpg"],
                                            [NSURL URLWithString:@"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg"],
                                            [NSURL URLWithString:@"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7qjop4j20i00hw4c6.jpg"],
                                            [NSURL URLWithString:@"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7usmc8j20i543zngx.jpg"],
                                            [NSURL URLWithString:@"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg"],
                                            [NSURL URLWithString:@"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7tekewj20i20i4aoy.jpg"],
                                            [NSURL URLWithString:@"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg"],
                                            [NSURL URLWithString:@"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7tekewj20i20i4aoy.jpg"],
                                            [NSURL URLWithString:@"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7usmc8j20i543zngx.jpg"],
                                            ];
            [photos addObjectsFromArray:[HJPhoto photosWithURLs:photosWithURLArray]];
        }
    }
    
    HJAccessory *accessory = [HJAccessory new];
    accessory.userPic = @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg";
    accessory.userNick = @"咕噜咕噜";
    accessory.time = @"2018.11.20 21:10:20";
    accessory.title = @"迷幻升腾的云雾为我们带来马丘比丘迎客的祝福西方外来文明的土地迷幻升腾的云雾为我们带来马丘比丘迎客的祝福西方外来文明的土地迷幻升腾的云雾为我们带来马丘比丘迎客的祝福西方外来文明的土地";
    
    HJViewController *browser = [[HJViewController alloc] initWithPhotos:photos];
    browser.delegate = self;
    browser.accessory = accessory;
    browser.dismissOnTouch = NO;
    browser.usePopAnimation = YES;
    browser.forceHideStatusBar = NO;
    browser.disableVerticalSwipe = NO;
    browser.disablePhotoAnimation = NO;
    browser.useWhiteBackgroundColor = NO;
    if ((indexPath.section == 1)) {
        if (indexPath.row == 0) {
            browser.displayAccessoryView = YES;
        } else if ((indexPath.row == 1 || indexPath.row == 2)) {
            browser.displayAccessoryView = NO;
        }
    }
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 3;
        case 2:
            return 0;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Single photo";
        case 1:
            return @"Multiple photos";
        case 2:
            return @"Photos on screen";
        default:
            return @"";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Local photo";
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Local photo";
                break;
            case 1:
                cell.textLabel.text = @"Photos from Web";
                break;
            case 2:
                cell.textLabel.text = @"Photos from Web Custom";
                break;
            default:
                break;
        }
    }
    return cell;
}

#pragma mark - LazyLoad

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 426 * 0.9 + 40)];
        UIButton *button1 = [UIButton new];
        button1.tag = 101;
        button1.frame = CGRectMake(15, 0, 640/3 * 0.9, 426/2 * 0.9);
        [button1 setImage:[UIImage imageNamed:@"photo1m.jpg"] forState:UIControlStateNormal];
        button1.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button1 addTarget:self action:@selector(buttonWithImageOnScreenPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:button1];

        UIButton *button2 = [UIButton new];
        button2.tag = 102;
        button2.frame = CGRectMake(15, 426/2 * 0.9 + 20, 640/3 * 0.9, 426/2 * 0.9);
        [button2 setImage:[UIImage imageNamed:@"photo3m.jpg"] forState:UIControlStateNormal];
        button2.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button2 addTarget:self action:@selector(buttonWithImageOnScreenPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:button2];
    }
    return _footerView;
}

@end
