//
//  KNDetailViewController.h
//  KeepANote
//
//  Created by Claire Reynaud on 10/17/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNNote.h"

@interface KNDetailViewController : UIViewController

@property (strong, nonatomic) KNNote *detailItem;
@property (weak, nonatomic) IBOutlet UITextField *titleView;
@property (weak, nonatomic) IBOutlet UITextField *textView;

@end
