 //
//  Movies ViewController.m
//  flix_vids
//
//  Created by rhaypapenfuzz on 6/26/19.
//  Copyright © 2019 rhaypapenfuzz. All rights reserved.
//

#import "Movies ViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface Movies_ViewController () <UITableViewDataSource, UITableViewDelegate >
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation Movies_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents: UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}
- (void)fetchMovies{

    // Start the activity indicator
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            //NSLog(@"%@",dataDictionary );
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"%@",dataDictionary );
            self.movies = dataDictionary[@"results"];
            for(NSDictionary *movie in self.movies) {
                NSLog(@"%@", movie[@"title"]);
            }
            [self.tableView reloadData];
            // TODO: Get the array of movies
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
        }
        [self.refreshControl endRefreshing];
        // Stop the activity indicator
        // Hides automatically if "Hides When Stopped" is enabled
      //  [self.activityIndicator stopAnimating];
    }];
    [task resume];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
    NSLog(@"Tapping on movie");

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.movies.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell   *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    
    NSDictionary *movie  = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString =  movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];

    cell.posterView.image = nil; 
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}


@end
