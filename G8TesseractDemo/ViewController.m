//
//  ViewController.m
//  G8TesseractDemo
//
//  Created by April on 2017/4/24.
//  Copyright © 2017年 April. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, G8TesseractDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *tessercatTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhotoButtonPressed:(id)sender {
    
    [self showTakePhotoActionSheet];
}


#pragma mark - open imagePicker

- (void)showTakePhotoActionSheet {
    UIAlertController *imagePickerActionSheet = [UIAlertController alertControllerWithTitle:@"Snap/Upload Photo"
                                                                                    message:nil
                                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
        UIAlertAction *cameraButton = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
            cameraPicker.delegate = self;
            cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:cameraPicker animated:YES completion:nil];
        }];
        
        [imagePickerActionSheet addAction:cameraButton];
    }
    
    UIAlertAction *photoLibraryButton = [UIAlertAction actionWithTitle:@"Choose Existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *photoLibraryPicker = [[UIImagePickerController alloc] init];
        photoLibraryPicker.delegate = self;
        photoLibraryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:photoLibraryPicker animated:YES completion:nil];
    }];
    
    [imagePickerActionSheet addAction:photoLibraryButton];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [imagePickerActionSheet addAction:cancelButton];
    
    [self presentViewController:imagePickerActionSheet animated:YES completion:nil];
}

#pragma mark - activity Indicator 

- (void)addActivityIndicator {
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    [_activityIndicator startAnimating];
    
    [self.view addSubview:_activityIndicator];
}

- (void)removeCusActivityIndicator {
    [_activityIndicator removeFromSuperview];
    _activityIndicator = nil;
}

#pragma mark - scale image

- (UIImage *)scaleImage:(UIImage *)image maxDimension:(CGFloat)maxDimension {
    CGSize scaleSize = CGSizeMake(maxDimension, maxDimension);
    CGFloat scaleFactor = 0.0;
    
    if (image.size.width > image.size.height) {
        scaleFactor = image.size.height / image.size.width;
        scaleSize.width = maxDimension;
        scaleSize.height = scaleSize.width * scaleFactor;
    } else {
        scaleFactor = image.size.width / image.size.height;
        scaleSize.height = maxDimension;
        scaleSize.width = scaleSize.height * scaleFactor;
    }
    
    UIGraphicsBeginImageContext(scaleSize);
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    
    UIImage *scalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scalImage;
}

#pragma mark - Tesseract

- (void)performImageRecognition:(UIImage *)image {
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng+chi_tra"];
    tesseract.engineMode = G8OCREngineModeTesseractOnly;
    tesseract.pageSegmentationMode = G8PageSegmentationModeAuto;
    tesseract.maximumRecognitionTime = 60.0;
    tesseract.image = [image g8_blackAndWhite];
    tesseract.delegate = self;
    [tesseract recognize];
    
    _tessercatTextView.text = tesseract.recognizedText;
    
    [self removeCusActivityIndicator];
    
}

#pragma mark - Tesseract Delegate

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    //NSLog(@"Recognition progress %lu", (unsigned long)tesseract.progress);
}

#pragma mark - UIImagePickerConproller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *selectedPhoto = info[UIImagePickerControllerOriginalImage];
    UIImage *scaleImage = [self scaleImage:selectedPhoto maxDimension:640];
    
    [self addActivityIndicator];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performImageRecognition:scaleImage];
    }];
}




@end
