//
//  QUConfigureViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/12.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AlivcBase_ConfigureViewController.h"
#import "AliyunMediaConfig.h"
#import "AliyunPhotoViewController.h"
#import "AliyunVideoBase.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AliyunVideoUIConfig.h"
#import "AliyunIConfig.h"
#import "MBProgressHUD+AlivcHelper.h"
@interface AlivcBase_ConfigureViewController ()<AliyunPhotoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldFPS;
@property (weak, nonatomic) IBOutlet UITextField *textFieldGOP;
@property (weak, nonatomic) IBOutlet UITextField *textFieldBitrate;

@property (weak, nonatomic) IBOutlet UISlider *bpsSilder;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
@property (weak, nonatomic) IBOutlet UISlider *ratioSlider;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoSize;
@property (weak, nonatomic) IBOutlet UILabel *ratioLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoQualityLabel;
@property (weak, nonatomic) IBOutlet UIView *roundViewCut;
@property (weak, nonatomic) IBOutlet UIView *roundViewFill;
@property (weak, nonatomic) IBOutlet UISwitch *encodeSwitch;


@property (weak, nonatomic) IBOutlet UISwitch *cropSwitch;

@property (nonatomic, strong) CALayer *fillLayer;

@property (nonatomic, strong) NSArray *qualities;
@property (nonatomic, strong) AliyunMediaConfig *mediaInfo;

@property (nonatomic, assign) CGFloat videoOutputRatio;
@property (nonatomic, assign) CGFloat videoOutputWidth;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UILabel *cropTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *FPSLabel;
@property (weak, nonatomic) IBOutlet UILabel *GOPLabel;
@property (weak, nonatomic) IBOutlet UILabel *QualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *ResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *RatioTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *CropTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *CropButton;
@property (weak, nonatomic) IBOutlet UIButton *PaddingButton;
@property (weak, nonatomic) IBOutlet UILabel *BitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *GPUCropLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation AlivcBase_ConfigureViewController

- (instancetype)init {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcCropBasic.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return [self initWithNibName:@"AlivcBase_ConfigureViewController" bundle:bundle];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.cropTitleLabel.text = NSLocalizedString(@"????????????", nil);
    self.FPSLabel.text = NSLocalizedString(@"??????", nil);
    self.GOPLabel.text = NSLocalizedString(@"???????????????", nil);
    self.QualityLabel.text =  NSLocalizedString(@"????????????", nil);
    self.ResolutionLabel.text = NSLocalizedString(@"?????????", nil);
    
    self.RatioTypeLabel.text =  NSLocalizedString(@"????????????", nil);
    self.CropTypeLabel.text = NSLocalizedString(@"????????????", nil);
    
    [self.CropButton setTitle:NSLocalizedString(@"????????????", nil) forState:UIControlStateNormal];
    [self.PaddingButton setTitle:NSLocalizedString(@"????????????", nil) forState:UIControlStateNormal];
    
    self.BitrateLabel.text = NSLocalizedString(@"??????", nil);
    self.GPUCropLabel.text = NSLocalizedString(@"GPU??????", nil);
    [self.rightButton setTitle:NSLocalizedString(@"??????", nil) forState:UIControlStateNormal];
    self.videoQualityLabel.text = NSLocalizedString(@"???", nil);
    
    self.textFieldFPS.placeholder = NSLocalizedString(@"??????20-30?????????25", nil);
    self.textFieldGOP.placeholder =NSLocalizedString(@"??????1-300?????????5", nil);
    
    
    
    _roundViewCut.layer.cornerRadius = 9;
    _roundViewCut.layer.masksToBounds = YES;
    _roundViewFill.layer.cornerRadius = 9;
    _roundViewFill.layer.masksToBounds = YES;
    
//    [_textFieldFPS setValue:RGBToColor(110, 118, 139) forKeyPath:@"_placeholderLabel.textColor"];
//    [_textFieldGOP setValue:RGBToColor(110, 118, 139) forKeyPath:@"_placeholderLabel.textColor"];
    
    _sizeSlider.minimumTrackTintColor = RGBToColor(240, 84, 135);
    [_sizeSlider setThumbTintColor:RGBToColor(240, 84, 135)];
    
    _bpsSilder.minimumTrackTintColor = RGBToColor(240, 84, 135);
    [_bpsSilder setThumbTintColor:RGBToColor(240, 84, 135)];
    _bpsSilder.value = 0.25;
    
    _ratioSlider.minimumTrackTintColor = RGBToColor(240, 84, 135);
    [_ratioSlider setThumbTintColor:RGBToColor(240, 84, 135)];
    _ratioSlider.value = 0.6;
    
    
    _mediaInfo = [[AliyunMediaConfig alloc] init];
    _mediaInfo.minDuration = 2.0;
    _mediaInfo.maxDuration = 10.0*60;
    _mediaInfo.fps = 25;
    _mediaInfo.gop = 5;
    _mediaInfo.videoQuality = 1;
    _mediaInfo.outputSize = CGSizeMake(540, 720);
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectFill;
    _mediaInfo.videoOnly = YES;//?????????????????????????????????
    _mediaInfo.backgroundColor = [UIColor blackColor];
    _qualities = @[NSLocalizedString(@"??????", nil),NSLocalizedString(@"???", nil),NSLocalizedString(@"???", nil),NSLocalizedString(@"???", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil)];
    
    self.videoOutputRatio = 0.75;
    self.videoOutputWidth = 540;
    [self setupSDKBaseVersionUI];
    self.rightButton.hidden = NO;
    
    [self.nextButton setImage:[AlivcImage imageNamed:@"next"] forState:UIControlStateNormal];
    [self.backButton setImage:[AlivcImage imageNamed:@"back"] forState:UIControlStateNormal];
}
- (IBAction)rightButtonClick:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"??????", nil)]) {
        [sender setTitle:NSLocalizedString(@"??????", nil) forState:UIControlStateNormal];
        _mediaInfo.encodeMode = AliyunEncodeModeSoftFFmpeg;
    }else{
        [sender setTitle:NSLocalizedString(@"??????", nil) forState:UIControlStateNormal];
        _mediaInfo.encodeMode = AliyunEncodeModeHardH264;
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.textFieldFPS resignFirstResponder];
    [self.textFieldGOP resignFirstResponder];
    [self.textFieldBitrate resignFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_mediaInfo.cutMode == AliyunMediaCutModeScaleAspectFill) {
        self.fillLayer.position = _roundViewFill.center;
    } else {
        self.fillLayer.position = _roundViewCut.center;
    }
}

- (IBAction)textFieldFPSEndEdit:(id)sender {
    _mediaInfo.fps = [_textFieldFPS.text intValue];
}
- (IBAction)textFieldGOPEndEdit:(id)sender {
    _mediaInfo.gop = [_textFieldGOP.text intValue];
}

- (IBAction)textFieldBitrateEndEdit:(id)sender {
       
}


- (IBAction)silderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSString *str = @"540P";
    if (slider.value < 1/4.0) {
        self.videoOutputWidth = 360;
        str = @"360P";
    } else if (slider.value < 2/4.0) {
        self.videoOutputWidth = 480;
        str = @"480P";
    } else if (slider.value < 3/4.0) {
        self.videoOutputWidth = 540;
        str = @"540P";
    } else {
        self.videoOutputWidth = 720;
        str = @"720P";
    }
    _labelVideoSize.text = str;
}

- (IBAction)bpsSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int value = slider.value * 100;
    _mediaInfo.videoQuality = value / (100 / 5);
//    if ((int)_mediaInfo.videoQuality == 4) _mediaInfo.videoQuality = 3;
    _videoQualityLabel.text = _qualities[_mediaInfo.videoQuality];
}

- (IBAction)ratioSliderValueChanged:(UISlider *)sender {
    
    NSString *ratio = @"3:4";
    if (sender.value < 1/3.0) {
        self.videoOutputRatio = 9.0/16.0;
        ratio = @"9:16";
    } else if (sender.value < 2/3.0) {
        self.videoOutputRatio = 3.0/4.0;
        ratio = @"3:4";
    } else {
        self.videoOutputRatio = 1.0;
        ratio = @"1:1";
    }
    _ratioLabel.text = ratio;
}

- (IBAction)buttonCencelCLick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonNextClick:(id)sender {
    
    [self updatevideoOutputVideoSize];
    [self configureDidFinishWithMedia:_mediaInfo];
}

- (IBAction)buttonCutModeClick:(id)sender {
    self.fillLayer.position = _roundViewCut.center;
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectCut;
}

- (IBAction)buttonFillModeClick:(id)sender {
    self.fillLayer.position = _roundViewFill.center;
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectFill;
}

-(IBAction)switchEncode:(UISwitch *)sender {
//    _mediaInfo.encodeMode = sender.on;
}

- (IBAction)switchCrop:(UISwitch *)sender {
    _mediaInfo.gpuCrop = sender.on;
}

- (CALayer *)fillLayer {
    if (!_fillLayer) {
        _fillLayer = [CALayer layer];
        _fillLayer.backgroundColor = RGBToColor(240, 84, 135).CGColor;
        _fillLayer.bounds = CGRectMake(0, 0, 8, 8);
        _fillLayer.cornerRadius = 4;
        _fillLayer.masksToBounds = YES;
        [self.view.layer addSublayer:_fillLayer];
    }
    return _fillLayer;
}

//?????????????????????
- (void)setupSDKBaseVersionUI {
    AliyunVideoUIConfig *config = [[AliyunVideoUIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.cutTopLineColor = [UIColor redColor];
    config.cutBottomLineColor = [UIColor redColor];
    config.noneFilterText = NSLocalizedString(@"?????????", nil);
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"??????", nil),NSLocalizedString(@"?????????", nil),NSLocalizedString(@"??????", nil)];
    config.imageBundleName = @"QPSDK";
    config.filterBundleName = @"FilterResource";
    config.recordType = AliyunVideoRecordTypeCombination;
    config.showCameraButton = NO;
    
    [[AliyunVideoBase shared] registerWithAliyunIConfig:config];
}

// ????????????????????????videoSize
- (void)updatevideoOutputVideoSize {
    
    CGFloat width = self.videoOutputWidth;
    CGFloat height = ceilf(self.videoOutputWidth / self.videoOutputRatio); // ?????????videoSize???????????????
    _mediaInfo.outputSize = CGSizeMake(width, height);
    NSLog(@"videoSize:w:%f  h:%f", _mediaInfo.outputSize.width, _mediaInfo.outputSize.height);
    
}

#pragma mark - ConfigureViewControllerdelegate

- (void)configureDidFinishWithMedia:(AliyunMediaConfig *)mediaConfig {
    AliyunPhotoViewController *vc = [[AliyunPhotoViewController alloc]init];
    vc.cutInfo = mediaConfig;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - PhotoViewControllerDelgate
- (void)recodBtnClick:(UIViewController *)vc {
    Class c = NSClassFromString(@"AlivcBase_RecordViewController");
    UIViewController *recordVC = (UIViewController *)[[c alloc] init];
    [recordVC setValue:self forKey:@"delegate"];
    [recordVC setValue:[vc valueForKey:@"cutInfo"] forKey:@"quVideo"];
    [recordVC setValue:@(NO) forKey:@"isSkipEditVC"];
    [AliyunIConfig config].hiddenImportButton = YES;
    [self.navigationController pushViewController:recordVC animated:YES];
}

- (void)videoBase:(AliyunVideoBase *)base cutCompeleteWithCropViewController:(UIViewController *)cropVC image:(UIImage *)image {
    //????????????
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)cropFinished:(UIViewController *)cropViewController videoPath:(NSString *)videoPath sourcePath:(NSString *)sourcePath {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"????????????????????????????????????");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"????????????", nil) message:NSLocalizedString(@"????????????????????????", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//            [alert show];
             [MBProgressHUD showMessage:NSLocalizedString(@"????????????????????????", nil) inView:self.view];
        });
    }];
}

- (void)cropFinished:(UIViewController *)cropViewController mediaType:(kPhotoMediaType)type photo:(UIImage *)photo videoPath:(NSString *)videoPath {
    if (type == kPhotoMediaTypePhoto) {
        UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error != NULL){
        NSLog(@"????????????????????????????????????");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"????????????", nil) message:NSLocalizedString(@"????????????????????????", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [alert show];
        
        [MBProgressHUD showMessage:NSLocalizedString(@"????????????????????????", nil) inView:self.view];
    });
}

- (void)backBtnClick:(UIViewController *)vc {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RecordViewControllerDelegate
- (void)exitRecord {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recoderFinish:(UIViewController *)vc videopath:(NSString *)videoPath {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"????????????????????????????????????");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
//    UIViewController *editVC = [[AliyunMediator shared] editViewController];
//    // ??????????????????????????????
//    //    NSString *outputPath = [[vc valueForKey:@"recorder"] valueForKey:@"taskPath"];
//    //    [editVC setValue:outputPath forKey:@"videoPath"];
//    // ???????????????????????????
//    [editVC setValue:videoPath forKey:@"videoPath"];
//    [editVC setValue:[vc valueForKey:@"quVideo"] forKey:@"config"];
//    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)recordViewShowLibrary:(UIViewController *)vc {

    NSLog(@"????????????????????????????????????????????????");
    
}

#pragma mark - ????????????
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
@end
