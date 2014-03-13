#import "Vaml.h"
#import "VamlTokenizer.h"
#import "VamlTreeBuilder.h"
#import "UIView+Vaml.h"
#import "VamlContext.h"
#import "VamlConstraintsHandler.h"
#import "VamlViewFactory.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation Vaml

+(void)layout:(NSString *)layout view:(UIView *)view target:(id)target {
  VamlTokenizer *tokenizer = [[VamlTokenizer alloc] initWithFileName:layout extension:@"vaml"];
  NSArray *tokens = [tokenizer tokenize];
  VamlTreeBuilder *treeBuilder = [[VamlTreeBuilder alloc] initWithTokens:tokens];
  NSDictionary *tree = [treeBuilder build];
  VamlContext *context = [[VamlContext alloc] init];
  [context setTarget:target];
  [self setVamlData:tree to:view context:context];
  [VamlConstraintsHandler addConstraintsTo:view];
}

+(void)setVamlData:(NSDictionary *)data to:(UIView *)view context:(VamlContext *)context {
  [view setVamlData:data];
  [view setVamlContext:context];
  NSArray *children = data[@"children"];
  if (children) {
    for (NSDictionary *child in children) {
      UIView *subview = [VamlViewFactory viewFromData:child context:context];
      if (subview) {
        [view addSubview:subview];
        [self setVamlData:child to:subview context:context];
      }
    }
    SEL selector = NSSelectorFromString(@"didAddAllSubviews");
    if ([view respondsToSelector:selector]) {
      [view performSelector:selector];
    }
  }
}

@end

@implementation UIView (VamlExtension)

-(void)applyVamlLayout:(NSString *)layout {
  [Vaml layout:layout view:self target:self];
}

-(UIView *)findViewById:(NSString *)viewId {
  if ([self.vamlId isEqualToString:viewId]) {
    return self;
  } else {
    for (UIView *subview in self.subviews) {
      id result = [subview findViewById:viewId];
      if (result) return result;
    }
    return nil;
  }
}

@end

@implementation UIViewController (VamlExtension)

-(void)applyVamlLayout:(NSString *)layout {
  [Vaml layout:layout view:self.view target:self];
}

-(UIView *)findViewById:(NSString *)viewId {
  return [self.view findViewById:viewId];
}

@end
