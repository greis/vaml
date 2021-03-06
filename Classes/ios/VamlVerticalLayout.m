#import "VamlVerticalLayout.h"
#import "Vaml.h"

@implementation VamlVerticalLayout

-(NSLayoutAttribute)alignmentAttribute {
  NSString *align = self.vamlData[@"itemsAlignment"];
  if ([@"right" isEqualToString:align]) {
    return NSLayoutAttributeRight;
  } else if ([@"left" isEqualToString:align]) {
    return NSLayoutAttributeLeft;
  }
  return NSLayoutAttributeCenterX;
}

-(int)alignmentPadding {
  NSString *align = self.vamlData[@"itemsAlignment"];
  if ([@"right" isEqualToString:align]) {
    return -self.padding;
  } else if ([@"left" isEqualToString:align]) {
    return self.padding;
  }
  return 0;
}

-(NSLayoutAttribute)dimensionAttribute {
  return NSLayoutAttributeWidth;
}

-(NSString *)orientationForVisualFormat {
  return @"V";
}

@end
