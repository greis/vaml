#import "VamlTokenizer.h"
#import "VamlAttributesParser.h"

enum TokenType {
  INDENTATION,
  TAG,
  CLASS,
  ID,
  ATTRS,
  SILENT_SCRIPT
  } INVALID;

@interface VamlTokenizer ()
@property(nonatomic) NSString* content;
@end

@implementation VamlTokenizer

-(id)initWithContent:(NSString *)content {
  self = [super init];
  if (self) {
    [self setContent:content];
  }
  return self;
}

-(NSArray *)tokenize {
  NSArray* lines = [self.content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  NSMutableArray *result = [NSMutableArray array];
  for (NSString *line in lines) {
    if ([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0) {
      NSDictionary *tokens = [self tokenizeLine:line];
      [result addObject:tokens];
    }
  }
  
  return result;
}

-(NSDictionary *)tokenizeLine:(NSString *)line {
  NSMutableDictionary *tokens = [NSMutableDictionary dictionary];
  
  int lastIndex = line.length - 1;
  char initialChar = [line characterAtIndex:0];
  int tokenType = [self tokenTypeByChar:initialChar];
  int currentIndex = 1;
  int tokenStart = 0;
  int tokenEnd = 0;
  
  while (currentIndex <= lastIndex) {
    char currentChar = [line characterAtIndex:currentIndex];
    
    switch (tokenType) {
      case INDENTATION:
        if (currentChar != ' ') tokenEnd = currentIndex;
        break;
      case TAG:
        if (currentChar < 'a' || currentChar > 'z') tokenEnd = currentIndex;
        break;
      case CLASS:
      case ID:
        if (!((currentChar >= 'a' && currentChar <= 'z') || (currentChar >= '0' && currentChar <= '9') || currentChar == '_')) tokenEnd = currentIndex;
        break;
      case ATTRS:
        if ((initialChar == '{' && currentChar == '}') ||
            ((initialChar == '(') && currentChar == ')')) {
          currentIndex++; //increment index to capture '}'
          tokenEnd = currentIndex;
        }
        break;
      default:
        break;
    }
    
    if (tokenEnd == currentIndex) {
      [self addTokenFromRange:NSMakeRange(tokenStart, currentIndex - tokenStart) tokenType:tokenType line:line tokens:tokens];
      
      if (currentIndex <= lastIndex) { //need to check index because ATTRS capture increments currentIndex
        initialChar = [line characterAtIndex:currentIndex];
        tokenType = [self tokenTypeByChar:initialChar];
        tokenStart = currentIndex;
      }
    }
    
    currentIndex++;
    
  }
  
  if (tokenEnd < line.length) {
    tokenEnd = line.length;
    [self addTokenFromRange:NSMakeRange(tokenStart, tokenEnd - tokenStart) tokenType:tokenType line:line tokens:tokens];
  }
  
  return tokens;
}

-(void)addTokenFromRange:(NSRange)range tokenType:(int)tokenType line:(NSString *)line tokens:(NSMutableDictionary *)tokens {
  switch (tokenType) {
    case INDENTATION:
      tokens[@"indentation"] = [line substringWithRange:range];
      break;
    case TAG:
      tokens[@"tag"] = [line substringWithRange:NSMakeRange(range.location + 1, range.length - 1)];
      break;
    case CLASS: {
      NSMutableArray *classes;
      if (tokens[@"classes"]) {
        classes = tokens[@"classes"];
      } else {
        classes = [NSMutableArray array];
        tokens[@"classes"] = classes;
      }
      [classes addObject:[line substringWithRange:NSMakeRange(range.location + 1, range.length - 1)]];
      break;
    }
    case ID:
      tokens[@"id"] = [line substringWithRange:NSMakeRange(range.location + 1, range.length - 1)];
      break;
    case ATTRS: {
      VamlAttributesParser *attrParser = [[VamlAttributesParser alloc] initWithString:[line substringWithRange:range]];
      tokens[@"attrs"] = [attrParser parseString];
      break;
    }
    case SILENT_SCRIPT:
      tokens[@"script"] = [line substringWithRange:range];
      break;
  }
}

-(int)tokenTypeByChar:(char)character {
  switch (character) {
    case '%':
      return TAG;
    case ' ':
    case '\t':
      return INDENTATION;
    case '.':
      return CLASS;
    case '#':
      return ID;
    case '{':
    case '(':
      return ATTRS;
    case '-':
      return SILENT_SCRIPT;
    default:
      return INVALID;
  }
}

@end
