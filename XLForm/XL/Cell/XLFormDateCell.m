//
//  XLFormDateCell.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "XLForm.h"
#import "XLFormRowDescriptor.h"
#import "XLFormDateCell.h"
#import "UIView+XLFormAdditions.h"


@interface XLFormDateCell()

@property (nonatomic) UIDatePicker *datePicker;
@property NSArray * dynamicCustomConstraints;

@end

@implementation XLFormDateCell
{
    UIColor * _beforeChangeColor;
}

@synthesize detailTextLabel = _detailTextLabel;
@synthesize textLabel = _textLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.detailTextLabel.text = @"";
    }
    
    return self;
}

- (UIView *)inputView
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTime]){
        if (self.rowDescriptor.value){
            [self.datePicker setDate:self.rowDescriptor.value];
        }
        return self.datePicker;
    }
    return [super inputView];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)resignFirstResponder
{
    self.detailTextLabel.textColor = _beforeChangeColor;
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
    {
        NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
        NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
        XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
        if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
            XLFormSectionDescriptor * formSection = [self.formViewController.form.formSections objectAtIndex:nextRowPath.section];
            [formSection removeFormRow:nextFormRow];
        }
    }
    return [super resignFirstResponder];
}

#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
    self.formDatePickerMode = XLFormDateDatePickerModeGetFromRowDescriptor;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.detailTextLabel];
    [self.contentView addConstraints:[self layoutConstraints]];
}

-(void)update
{
    [super update];
    
    self.accessoryType =  UITableViewCellAccessoryNone;
    [self.textLabel setText:self.rowDescriptor.title];
    self.textLabel.textColor  = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.selectionStyle = self.rowDescriptor.disabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    self.textLabel.text = [NSString stringWithFormat:@"%@%@", self.rowDescriptor.title, self.rowDescriptor.required ? @"*" : @""];
    self.detailTextLabel.text = [self valueDisplayText];
    self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
    {
        if ([self isFirstResponder]){
            [self resignFirstResponder];
        }
        else{
            [self becomeFirstResponder];
            _beforeChangeColor = self.detailTextLabel.textColor;
            self.detailTextLabel.textColor = self.formViewController.view.tintColor;
            NSIndexPath * selectedRowPath = [controller.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:(selectedRowPath.row + 1) inSection:selectedRowPath.section];
            XLFormSectionDescriptor * formSection = [controller.form.formSections objectAtIndex:nextRowPath.section];
            XLFormRowDescriptor * datePickerRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeDatePicker];
            XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[datePickerRowDescriptor cellForFormController:controller];
            [self setModeToDatePicker:datePickerCell.datePicker];
            if (self.rowDescriptor.value){
                [datePickerCell.datePicker setDate:self.rowDescriptor.value];
            }
            [datePickerCell.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
            [formSection addFormRow:datePickerRowDescriptor afterRow:self.rowDescriptor];
        }
        [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTime])
    {
        [self becomeFirstResponder];
        [controller.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return YES;
}

#pragma mark - helpers

-(NSString *)valueDisplayText
{
    return self.rowDescriptor.value ? [self formattedDate:self.rowDescriptor.value] : self.rowDescriptor.noValueDisplayText;
}


- (NSString *)formattedDate:(NSDate *)date
{
    if (self.dateFormatter){
        return [self.dateFormatter stringFromDate:date];
    }
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline]){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline]){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

-(void)setModeToDatePicker:(UIDatePicker *)datePicker
{
    if ((([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate]) && self.formDatePickerMode == XLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == XLFormDateDatePickerModeDate){
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ((([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime]) && self.formDatePickerMode == XLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == XLFormDateDatePickerModeTime){
        datePicker.datePickerMode = UIDatePickerModeTime;
    }
    else{
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
    if (self.minuteInterval)
        datePicker.minuteInterval = self.minuteInterval;
    
    if (self.minimumDate)
        datePicker.minimumDate = self.minimumDate;
    
    if (self.maximumDate)
        datePicker.maximumDate = self.maximumDate;
    
}

#pragma mark - Properties

-(UIDatePicker *)datePicker
{
    if (_datePicker) return _datePicker;
    _datePicker = [[UIDatePicker alloc] init];
    [self setModeToDatePicker:_datePicker];
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    return _datePicker;
}


#pragma mark - Target Action

- (void)datePickerValueChanged:(UIDatePicker *)sender
{
    self.detailTextLabel.text = [self formattedDate:sender.date];
    self.rowDescriptor.value = sender.date;
    [self setNeedsLayout];
    
}

-(void)setFormDatePickerMode:(XLFormDateDatePickerMode)formDatePickerMode
{
    _formDatePickerMode = formDatePickerMode;
    if ([self isFirstResponder] ){
        if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
        {
            NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
            XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
            if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
                XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[nextFormRow cellForFormController:self.formViewController];
                [self setModeToDatePicker:datePickerCell.datePicker];
            }
        }
    }
}

#pragma mark - Properties

-(UILabel *)textLabel
{
    if (_textLabel) return _textLabel;
    _textLabel = [UILabel autolayoutView];
    [_textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    return _textLabel;
}

-(UILabel *)detailTextLabel
{
    if (_detailTextLabel) return _detailTextLabel;
    _detailTextLabel = [UILabel autolayoutView];
    [_detailTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [_detailTextLabel setTextAlignment:NSTextAlignmentRight];
    return _detailTextLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    if ( self.textLabel.numberOfLines == 0 )
    {
        if ( self.textLabel.preferredMaxLayoutWidth != self.frame.size.width )
        {
            self.textLabel.preferredMaxLayoutWidth = self.frame.size.width;
            [self setNeedsUpdateConstraints];
        }
    }
}

#pragma mark - LayoutConstraints

-(NSArray *)layoutConstraints
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    [self.textLabel setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_textLabel(<=200)]-[_detailTextLabel]" options:NSLayoutFormatAlignAllBaseline metrics:0 views:NSDictionaryOfVariableBindings(_textLabel, _detailTextLabel)]];
    
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_textLabel]-8-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)];
    [result addObjectsFromArray:verticalConstraint];
    
    return result;
}

-(void)updateConstraints
{
    if (self.dynamicCustomConstraints){
        [self.contentView removeConstraints:self.dynamicCustomConstraints];
    }
    NSDictionary * views = @{@"label": self.textLabel, @"detailLabel": self.detailTextLabel, @"image": self.imageView};
    if (self.imageView.image){
        if (self.textLabel.text.length > 0){
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[label(<=200)]-[detailLabel]-10-|" options:0 metrics:0 views:views];
        }
        else{
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[detailLabel]-10-|" options:0 metrics:0 views:views];
        }
    }
    else{
        if (self.textLabel.text.length > 0){
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[label(<=200)]-[detailLabel]-10-|" options:0 metrics:0 views:views];
        }
        else{
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[detailLabel]-10-|" options:0 metrics:0 views:views];
        }
    }
    [self.contentView addConstraints:self.dynamicCustomConstraints];
    [super updateConstraints];
}


@end
