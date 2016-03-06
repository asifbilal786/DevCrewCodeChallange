//
//  FooterView.m
//  TweetManager
//
//  Created by Awais Arshad Chatha on 2016-03-06.
//  Copyright © 2016 DevCrew. All rights reserved.
//

#import "FooterView.h"

@implementation FooterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)valueChanged:(UISegmentedControl *)sender {

    switch (sender.selectedSegmentIndex) {
        case 0: //searched
            if ([self.footerDelegate respondsToSelector:@selector(didSelectSearchButton:)]) {
                [self.footerDelegate didSelectSearchButton:self];
            }
            break;
        
        case 1://saved
            if ([self.footerDelegate respondsToSelector:@selector(didSelectSavedButton:)]) {
                [self.footerDelegate didSelectSavedButton:self];
            }
            break;
            
        default:
            break;
    }
}

@end
