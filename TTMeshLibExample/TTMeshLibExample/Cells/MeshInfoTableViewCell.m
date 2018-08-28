//
//  MeshInfoTableViewCell.m
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "MeshInfoTableViewCell.h"
#import "TTDefine.h"

@interface MeshInfoTableViewCell()<UITextFieldDelegate> {
    
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UITextField *passwordTextField;
    NSMutableDictionary *mInfo;
}

@end

@implementation MeshInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    nameTextField.delegate = self;
    passwordTextField.delegate = self;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(NSMutableDictionary*)info
{
    mInfo = info;
    nameTextField.text = info[Storage_MeshName];
    passwordTextField.text = info[Storage_MeshPassword];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == 101) {
        [mInfo setObject:textField.text forKey:Storage_MeshName];
    }
    else
    {
        [mInfo setObject:textField.text forKey:Storage_MeshPassword];
    }
    
    return YES;
}

-(IBAction)deleteAction:(id)sender
{
    if (self.deleteBlock != nil) {
        self.deleteBlock(TRUE);
    }
}

-(IBAction)selectAction:(id)sender {
    if (self.selectedBlock != nil) {
        self.selectedBlock(TRUE);
    }
}

@end
