//
//  XLFormCurrencyCell.m
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

#import "NSObject+XLFormAdditions.h"
#import "UIView+XLFormAdditions.h"
#import "XLFormRowDescriptor.h"
#import "XLForm.h"
#import "XLFormCurrencyCell.h"

@interface XLFormCurrencyCell() <UITextFieldDelegate>

@property NSArray * dynamicCustomConstraints;

@end

@implementation XLFormCurrencyCell

@synthesize textField = _textField;
@synthesize textLabel = _textLabel;
@synthesize currencySymbolLabel = _currencySymbolLabel;

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self.textLabel && [keyPath isEqualToString:@"text"]) ||  (object == self.imageView && [keyPath isEqualToString:@"image"])){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            [self.contentView setNeedsUpdateConstraints];
        }
    }
}

-(void)dealloc
{
    [self.textLabel removeObserver:self forKeyPath:@"text"];
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

#pragma mark - XLFormDescriptorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.currencySymbolLabel.text = @"$";
    }
    
    return self;
}

-(void)configure
{
    [super configure];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.textField];
    //[self.contentView addSubview:self.currencySymbolLabel];
    [self.contentView addConstraints:[self layoutConstraints]];
    [self.textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    [self.imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void)update
{
    [super update];
    self.textField.delegate = self;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;

    self.textLabel.text = ((self.rowDescriptor.required && self.rowDescriptor.title) ? [NSString stringWithFormat:@"%@*", self.rowDescriptor.title] : self.rowDescriptor.title);
    
    self.textField.text = self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText;
    [self.textField setEnabled:!self.rowDescriptor.disabled];
    self.textLabel.textColor  = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.textField.textColor = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.currencySymbolLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

-(BOOL)formDescriptorCellResignFirstResponder
{
    return [self.textField resignFirstResponder];
}

#pragma mark - Properties

-(UILabel *)textLabel
{
    if (_textLabel) return _textLabel;
    _textLabel = [UILabel autolayoutView];
    [_textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    return _textLabel;
}

-(UITextField *)textField
{
    if (_textField) return _textField;
    _textField = [UITextField autolayoutView];
    [_textField setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [_textField setTextAlignment:NSTextAlignmentRight];
    return _textField;
}

-(UILabel *)currencySymbolLabel
{
    if (_currencySymbolLabel) return _currencySymbolLabel;
    _currencySymbolLabel = [UILabel autolayoutView];
    [_currencySymbolLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    return _currencySymbolLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    if ( self.textLabel.numberOfLines == 0 )
    {
        if ( self.textLabel.preferredMaxLayoutWidth != self.frame.size.width )
        {
            //keep max width
            //self.textLabel.preferredMaxLayoutWidth = self.frame.size.width;
            [self setNeedsUpdateConstraints];
        }
    }
}

#pragma mark - LayoutConstraints

-(NSArray *)layoutConstraints
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    [self.textLabel setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_textLabel(<=175)]-5-[_textField]" options:NSLayoutFormatAlignAllBaseline metrics:0 views:NSDictionaryOfVariableBindings(_textLabel, _textField)]];
    
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_textLabel]-8-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)];
    [result addObjectsFromArray:verticalConstraint];
    
    return result;
}

-(void)updateConstraints
{
    if (self.dynamicCustomConstraints){
        [self.contentView removeConstraints:self.dynamicCustomConstraints];
    }
    NSDictionary * views = @{@"label": self.textLabel, @"textField": self.textField, @"image": self.imageView};
    if (self.imageView.image){
        if (self.textLabel.text.length > 0){
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[label(<=175)]-5-[textField]-10-|" options:0 metrics:0 views:views];
        }
        else{
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[textField]-10-|" options:0 metrics:0 views:views];
        }
    }
    else{
        if (self.textLabel.text.length > 0){
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[label(<=175)]-5-[textField]-10-|" options:0 metrics:0 views:views];
        }
        else{
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[textField]-10-|" options:0 metrics:0 views:views];
        }
    }
    [self.contentView addConstraints:self.dynamicCustomConstraints];
    [super updateConstraints];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 200.0f;
}

- (CGSize) intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    NSLog(@"Intrinsic size: %f", s.height);
    s.height += 1;
    
    return s;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return [self.formViewController textFieldShouldClear:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self.formViewController textFieldShouldReturn:textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [self.formViewController textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return [self.formViewController textFieldShouldEndEditing:textField];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    return [self.formViewController textField:textField shouldChangeCharactersInRange:range replacementString:string];
//}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.formViewController textFieldDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textFieldDidChange:textField];
    [self.formViewController textFieldDidEndEditing:textField];
}


#pragma mark - Helper

- (void)textFieldDidChange:(UITextField *)textField{
    if([self.textField.text length] > 0) {
        if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeNumber]){
            self.rowDescriptor.value =  @([self.textField.text doubleValue]);
        } else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeInteger]){
            self.rowDescriptor.value = @([self.textField.text integerValue]);
        } else {
            self.rowDescriptor.value = self.textField.text;
        }
    } else {
        self.rowDescriptor.value = nil;
    }
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSInteger MAX_DIGITS = 11; // $999,999,999.99
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
    
    NSString *stringMaybeChanged = [NSString stringWithString:string];
    if (stringMaybeChanged.length > 1)
    {
        NSMutableString *stringPasted = [NSMutableString stringWithString:stringMaybeChanged];
        
        [stringPasted replaceOccurrencesOfString:numberFormatter.currencySymbol
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [stringPasted length])];
        
        [stringPasted replaceOccurrencesOfString:numberFormatter.groupingSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [stringPasted length])];
        
        NSDecimalNumber *numberPasted = [NSDecimalNumber decimalNumberWithString:stringPasted];
        stringMaybeChanged = [numberFormatter stringFromNumber:numberPasted];
    }
    
    UITextRange *selectedRange = [textField selectedTextRange];
    UITextPosition *start = textField.beginningOfDocument;
    NSInteger cursorOffset = [textField offsetFromPosition:start toPosition:selectedRange.start];
    NSMutableString *textFieldTextStr = [NSMutableString stringWithString:textField.text];
    NSUInteger textFieldTextStrLength = textFieldTextStr.length;
    
    [textFieldTextStr replaceCharactersInRange:range withString:stringMaybeChanged];
    
    [textFieldTextStr replaceOccurrencesOfString:numberFormatter.currencySymbol
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];
    
    [textFieldTextStr replaceOccurrencesOfString:numberFormatter.groupingSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];
    
    [textFieldTextStr replaceOccurrencesOfString:numberFormatter.decimalSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];
    
    if (textFieldTextStr.length <= MAX_DIGITS)
    {
        NSDecimalNumber *textFieldTextNum = [NSDecimalNumber decimalNumberWithString:textFieldTextStr];
        NSDecimalNumber *divideByNum = [[[NSDecimalNumber alloc] initWithInt:10] decimalNumberByRaisingToPower:numberFormatter.maximumFractionDigits];
        NSDecimalNumber *textFieldTextNewNum = [textFieldTextNum decimalNumberByDividingBy:divideByNum];
        NSString *textFieldTextNewStr = [numberFormatter stringFromNumber:textFieldTextNewNum];
        
        textField.text = textFieldTextNewStr;
        
        if (cursorOffset != textFieldTextStrLength)
        {
            NSInteger lengthDelta = textFieldTextNewStr.length - textFieldTextStrLength;
            NSInteger newCursorOffset = MAX(0, MIN(textFieldTextNewStr.length, cursorOffset + lengthDelta));
            UITextPosition* newPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCursorOffset];
            UITextRange* newRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
            [textField setSelectedTextRange:newRange];
        }
    }
    
    return NO;
}
@end
