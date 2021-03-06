//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

#define EGOLocalizedString(key, comment) \
[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"EGOTableViewPullRefresh"   \
ofType:@"bundle"]] localizedStringForKey:(key) \
value:@""    \
table:nil]


static const float kOffsetYWhenSpinnerStartingShowing = 30;

@interface EGORefreshTableHeaderView ()
{
    BOOL centerAll_;
}
@property (nonatomic, strong) CALayer<EGOSpinnerLayerDelegate> *spinnerLayer;
@property (nonatomic, assign) CGFloat lastContentOffsetY;

- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
                 spinnerLayer:(CALayer<EGOSpinnerLayerDelegate> *)spinnerLayer
         showLastUpdatedLabel:(BOOL)showLastUpdatedLabel
                    textColor:(UIColor *)textColor
                    centerAll:(BOOL)centerAll
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        centerAll_ = centerAll;
        UILabel *label = nil;
        if (showLastUpdatedLabel) {
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont systemFontOfSize:12.0f];
            if (textColor) {
                label.textColor = textColor;
            }
            else {
                label.textColor = TEXT_COLOR;
            }
            label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            _lastUpdatedLabel=label;
        }
		
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        if (textColor) {
            label.textColor = textColor;
        }
        else {
            label.textColor = TEXT_COLOR;
        }
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        
        if (!spinnerLayer) {
            CALayer *layer = [CALayer layer];
            layer.contentsGravity = kCAGravityResizeAspect;
            layer.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                layer.contentsScale = [[UIScreen mainScreen] scale];
            }
#endif
            
            [[self layer] addSublayer:layer];
            _arrowImage=layer;
            
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self addSubview:view];
            _activityView = view;
        }
        else {
            _spinnerLayer = spinnerLayer;
            [self.layer addSublayer:_spinnerLayer];
        }
		
		[self setState:EGOOPullRefreshNormal];
    }
    
    return self;
    
}

- (instancetype)initWithFrame:(CGRect)frame
                 spinnerLayer:(CALayer<EGOSpinnerLayerDelegate> *)spinnerLayer
         showLastUpdatedLabel:(BOOL)showLastUpdatedLabel
{
    return [self initWithFrame:frame spinnerLayer:spinnerLayer showLastUpdatedLabel:showLastUpdatedLabel textColor:nil centerAll:NO];
}

- (instancetype)initWithFrame:(CGRect)frame spinnerLayer:(CALayer<EGOSpinnerLayerDelegate> *)spinnerLayer {
    if (self = [self initWithFrame:frame spinnerLayer:spinnerLayer showLastUpdatedLabel:YES]) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame spinnerLayer:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self relayout];
}

- (void)relayout {
    NSAssert(self.superview != nil, @"need to have a superview!!");
    static float kFixCenter = 0;
    static float kFixEn = 0;
    static float kFixMargin = 50;
    if (centerAll_) {
        kFixCenter = 21;
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if (![language hasPrefix:@"zh"]) {
            kFixEn = 20;
            if (_lastUpdatedLabel) {
                kFixMargin += 16;
            }
        }
        else {
            if (_lastUpdatedLabel) {
                kFixMargin += 12;
            }
        }
    }
    else {
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if (![language hasPrefix:@"zh"]) {
            kFixEn = 25;
            if (_lastUpdatedLabel) {
                kFixMargin += 16;
            }
        }
        else {
            if (_lastUpdatedLabel) {
                kFixMargin += 12;
            }
        }
    }
    
    float layerOffsetX = self.superview.center.x - 140 + kFixCenter;
    float width = self.superview.bounds.size.width;
    if (!self.spinnerLayer) {
        _arrowImage.frame = CGRectMake(layerOffsetX, self.frame.size.height - 65.0f, 30.0f, 55.0f);
        _activityView.frame = CGRectMake(layerOffsetX, self.frame.size.height - 38.0f, 20.0f, 20.0f);
    }
    else {
        layerOffsetX = self.superview.center.x - (_spinnerLayer.bounds.size.width + kFixMargin) + kFixCenter - kFixEn;
        self.spinnerLayer.frame = CGRectMake(layerOffsetX, self.frame.size.height - _spinnerLayer.bounds.size.height - 15,
                                             _spinnerLayer.bounds.size.width, _spinnerLayer.bounds.size.height);
    }
    
    if (_lastUpdatedLabel) {
        _lastUpdatedLabel.frame = CGRectMake(kFixCenter, self.frame.size.height - 30.0f, width, 20.0f);
        _statusLabel.frame = CGRectMake(kFixCenter, self.frame.size.height - 48.0f, width, 20.0f);
    }
    else {
        _statusLabel.frame = CGRectMake(kFixCenter, self.frame.size.height - 48.0f, width, 35.0f);
    }
}

- (void)triggerLoadingInScrollView:(UIScrollView *)scrollView {
    [self setState:EGOOPullRefreshLoading];
    [scrollView setContentOffset:CGPointMake(0, -65) animated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    scrollView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
    
    if (self.spinnerLayer) {
        [self.spinnerLayer startAnimating];
        self.lastContentOffsetY = 0;
    }
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
    if (_lastUpdatedLabel) {
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
            
            NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setAMSymbol:@"AM"];
            [formatter setPMSymbol:@"PM"];
            [formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
            _lastUpdatedLabel.text = [NSString stringWithFormat:EGOLocalizedString(@"egoPullRefreshViewLastUpdateTime", @"Last Updated"), [formatter stringFromDate:date]];
            [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } else {
            
            _lastUpdatedLabel.text = nil;
            
        }
    }
}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = EGOLocalizedString(@"egoPullRefreshViewReleaseToRefresh", @"Release to refresh status");
            
            if (!self.spinnerLayer) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                [CATransaction commit];
            }
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
                if (!self.spinnerLayer) {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                    _arrowImage.transform = CATransform3DIdentity;
                    [CATransaction commit];
                }
			}
			
			_statusLabel.text = EGOLocalizedString(@"egoPullRefreshViewPullToRefresh", @"Pull down to refresh status");
            
            if (!self.spinnerLayer) {
                [_activityView stopAnimating];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                _arrowImage.hidden = NO;
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = EGOLocalizedString(@"egoPullRefreshViewLoading", @"Loading Status");
            
            if (!self.spinnerLayer) {
                [_activityView startAnimating];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                _arrowImage.hidden = YES;
                [CATransaction commit];
            }
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 65);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
        else if (_state == EGOOPullRefreshNormal &&
                 -65.0f <= scrollView.contentOffset.y) {
            if (self.spinnerLayer) {
                if (scrollView.contentOffset.y <= -kOffsetYWhenSpinnerStartingShowing) {
                    //                NSLog(@"last=%f, curr=%f", self.lastContentOffsetY, scrollView.contentOffset.y);
                    if (self.lastContentOffsetY > scrollView.contentOffset.y) {  //show
                        [self.spinnerLayer showInProgress:((scrollView.contentOffset.y + kOffsetYWhenSpinnerStartingShowing) / (-65.0 + kOffsetYWhenSpinnerStartingShowing))];
                    }
                    else if (self.lastContentOffsetY < scrollView.contentOffset.y) {   //hide
                        [self.spinnerLayer showInProgress:((scrollView.contentOffset.y + kOffsetYWhenSpinnerStartingShowing) / (65.0 - kOffsetYWhenSpinnerStartingShowing))];
                    }
                    self.lastContentOffsetY = scrollView.contentOffset.y;
                    
                }
                else {
                    self.lastContentOffsetY = 0;
                    [self.spinnerLayer showInProgress:NSIntegerMin];
                }
            }
        }
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        
        if (self.spinnerLayer) {
            [self.spinnerLayer startAnimating];
            self.lastContentOffsetY = 0;
        }
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
    
    if (self.spinnerLayer) {
        [self.spinnerLayer stopAnimating];
    }
    
    
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
}


@end
