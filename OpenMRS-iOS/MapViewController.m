//
//  MapViewController.h
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
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

#import "UIView+XLFormAdditions.h"
#import <MapKit/MapKit.h>

#import "MapViewController.h"


@interface MapAnnotation : NSObject  <MKAnnotation>
@end

@implementation MapAnnotation
@synthesize coordinate = _coordinate;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}
@end

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic) MKMapView * mapView;

@end

@implementation MapViewController

@synthesize rowDescriptor = _rowDescriptor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    if (self.rowDescriptor.value){
        NSArray *coordinates = [self.rowDescriptor.value componentsSeparatedByString:@" "];
        CLLocationCoordinate2D cord;
        if (coordinates.count == 2) {
            cord = CLLocationCoordinate2DMake([coordinates[0] floatValue], [coordinates[1] floatValue]);
            [self.mapView setCenterCoordinate:cord];
            self.title = [NSString stringWithFormat:@"%.4f, %.4f", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude];
            MapAnnotation *annotation = [[MapAnnotation alloc] init];
            annotation.coordinate = self.mapView.centerCoordinate;
            [self.mapView addAnnotation:annotation];
        }
    }
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapMap:)];
    [self.mapView addGestureRecognizer:tapRec];
}

-(MKMapView *)mapView
{
    if (_mapView) return _mapView;
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return _mapView;
}

- (void)didTapMap:(UITapGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded)
        return;
    for (MapAnnotation *ann in self.mapView.annotations) {
        [self.mapView removeAnnotation:ann];
    }
    CGPoint touchPoint = [gesture locationInView:self.mapView];
    CLLocationCoordinate2D loc = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    annotation.coordinate = loc;
    self.rowDescriptor.value = [NSString stringWithFormat:@"%.4f %.4f", loc.latitude, loc.longitude];
    self.title = [NSString stringWithFormat:@"%.4f %.4f", loc.latitude, loc.longitude];
    [self.mapView addAnnotation:annotation];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKPinAnnotationView *pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:@"annotation"];
    pinAnnotationView.pinColor = MKPinAnnotationColorRed;
    pinAnnotationView.draggable = YES;
    pinAnnotationView.animatesDrop = YES;
    return pinAnnotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding){
        self.rowDescriptor.value = [NSString stringWithFormat:@"%.4f, %.4f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
        self.title = [NSString stringWithFormat:@"%.4f, %.4f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
    }
}


@end
