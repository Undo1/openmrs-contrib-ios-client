//
//  XFormElement.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//

#import "XFormElement.h"

@implementation XFormElement

- (GDataXMLElement *)parentNodeFromDoc:(GDataXMLDocument *)doc {
    GDataXMLElement *model = [doc.rootElement elementsForName:@"xf:model"][0];
    GDataXMLElement *instance = [model elementsForName:@"xf:instance"][0];
    
    NSString *parentXPath = @"";
    NSArray *path = [self.XPathNode componentsSeparatedByString:@"/"];
    for (int i=0;i<path.count-1;i++) {
        parentXPath = [parentXPath stringByAppendingString:[NSString stringWithFormat:@"/%@", path[i]]];
    }
    NSLog(@"parent: %@", parentXPath);
    GDataXMLElement *parentNode = [instance nodesForXPath:parentXPath error:nil][0];
    return parentNode;
}
@end
