#import "VamlHorizontalLayout.h"
#import "Vaml.h"

@implementation VamlHorizontalLayout

-(NSLayoutAttribute)alignmentAttribute {
  NSString *align = self.vamlData[@"itemsAlignment"];
  if ([@"top" isEqualToString:align]) {
    return NSLayoutAttributeTop;
  } else if ([@"bottom" isEqualToString:align]) {
    return NSLayoutAttributeBottom;
  }
  return NSLayoutAttributeCenterY;
}

-(int)alignmentPadding {
  NSString *align = self.vamlData[@"itemsAlignment"];
  if ([@"top" isEqualToString:align]) {
    return self.padding;
  } else if ([@"bottom" isEqualToString:align]) {
    return -self.padding;
  }
  return 0;
}

-(NSLayoutAttribute)dimensionAttribute {
  return NSLayoutAttributeHeight;
}

-(NSString *)orientationForVisualFormat {
  return @"H";
}

@end
