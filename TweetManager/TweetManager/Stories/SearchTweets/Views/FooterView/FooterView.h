//
//  FooterView.h
//  TweetManager
//
//  Created by Awais Arshad Chatha on 2016-03-06.
//  Copyright © 2016 DevCrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FooterViewDelegate;

@interface FooterView : UITableViewHeaderFooterView

@property (nonatomic,weak) id <FooterViewDelegate> footerDelegate;

@end

@protocol FooterViewDelegate <NSObject>
- (void)didSelectSearchButton:(FooterView *)footerView;
- (void)didSelectSavedButton:(FooterView *)footerView;
@end