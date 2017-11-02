//
//  ViewController.m
//  imagestore
//
//  Created by oddman on 11/1/15.
//  Copyright © 2015 oddman. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewController.h"
#import "BinaryDAO.h"
#import "AppDelegate.h"

@interface RotatingUIImagePickerController : UIImagePickerController
@end

@implementation RotatingUIImagePickerController
- (UIInterfaceOrientationMask) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
@end

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation ViewController {
    NSMutableArray<NSString *> *_fileList;
    BinaryDAO *_binData;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    _binData = [[BinaryDAO alloc] initWithPath:[appDelegate dbFilePath]];

    UIBarButtonItem *add = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                            target:self
                            action:@selector(addNewItem:)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, add];

    _fileList = [_binData selectBinaryStoredList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    NSString *fileName = _fileList[indexPath.row];

    cell.textLabel.text = fileName;

    NSData *data = [_binData displaySelectedFile:fileName];
    cell.imageView.image = [UIImage imageWithData:data];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    ImageViewController *imgCtrl = [[ImageViewController alloc] init];
    imgCtrl.keyWindow = [[UIApplication sharedApplication] keyWindow];
    imgCtrl.image = cell.imageView.image;
    imgCtrl.declineImage = YES;
    imgCtrl.returnBlock = ^ {
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    [self presentViewController:imgCtrl animated:NO completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fileName = _fileList[indexPath.row];

        if ( [_binData deleteSelectedFile:fileName] ) {
            [_fileList removeObjectAtIndex:indexPath.row];
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void) addNewItem:(UIBarButtonItem *)sender {
    UIImagePickerController *picker = [[RotatingUIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)    imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = info[UIImagePickerControllerOriginalImage];

    [_binData insertBinaryData:UIImageJPEGRepresentation(image, 0.9)
                       binName:[[self class] generateUUID]];

    _fileList = [_binData selectBinaryStoredList];
    [self.tableView reloadData];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

+ (NSString *) generateUUID {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_str_ref = CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_str_ref];
    CFRelease(uuid_str_ref);
    return uuid;
}

@end
