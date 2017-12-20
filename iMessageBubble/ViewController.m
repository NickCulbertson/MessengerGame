//
//  ViewController.m
//  iMessageBubble
//
//  Created by Prateek Grover on 19/09/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import "ViewController.h"
#import "ContentView.h"
#import "ChatTableViewCell.h"
#import "ChatTableViewCellXIB.h"
#import "ChatCellSettings.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface iMessage: NSObject

-(id) initIMessageWithName:(NSString *)name
                     message:(NSString *)message
                        time:(NSString *)time
                      type:(NSString *)type;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userMessage;
@property (strong, nonatomic) NSString *userTime;
@property (strong, nonatomic) NSString *messageType;


@end

@implementation iMessage

-(id) initIMessageWithName:(NSString *)name
                     message:(NSString *)message
                        time:(NSString *)time
                      type:(NSString *)type
{
    self = [super init];
    if(self)
    {
        self.userName = name;
        self.userMessage = message;
        self.userTime = time;
        self.messageType = type;
    }
    
    return self;
}

@end

@interface ViewController (){
    NSArray *encounters;
}

@property (weak, nonatomic) IBOutlet UITableView *chatTable;
@property (weak, nonatomic) IBOutlet ContentView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;
@property (strong, nonatomic) NSString *myMessage;
@property (weak, nonatomic) IBOutlet UIButton *optionbut1;
@property (weak, nonatomic) IBOutlet UIButton *optionbut2;
@property (weak, nonatomic) IBOutlet UIButton *optionbut3;
@property (weak, nonatomic) IBOutlet UIButton *optionbut4;



@property (strong,nonatomic) ChatTableViewCell *chatCell;


@property (strong,nonatomic) ContentView *handler;


@end

@implementation ViewController
{
    NSMutableArray *currentMessages;
    ChatCellSettings *chatCellSettings;
    int jsonvalues[5];
    int jsonints[5];

    NSString* jsonstrings[5];
    int countencounter;
    int countselection;

}
@synthesize chatCell;


- (void)fetchedData:(NSData *)responseData {
  
    
    if(responseData==nil){
        
        
    }else{
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData                options:kNilOptions error:&error];
        encounters = [json objectForKey:@"encounters"];
        [self startgame];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentMessages = [[NSMutableArray alloc] init];
    chatCellSettings = [ChatCellSettings getInstance];
    
    
    //Local json
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"%@",filePath);
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data                options:kNilOptions error:&error];
    encounters = [json objectForKey:@"encounters"];
    [self startgame];
    //
    
    //Remote json
//    dispatch_async(kBgQueue, ^{
//        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: @"https://"]];
//        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
//    });
    //
    
    self.optionbut1.hidden=YES;
    self.optionbut2.hidden=YES;
    self.optionbut3.hidden=YES;
    self.optionbut4.hidden=YES;
    
    [chatCellSettings setSenderBubbleColorHex:@"007AFF"];
    [chatCellSettings setReceiverBubbleColorHex:@"DFDEE5"];
    [chatCellSettings setSenderBubbleNameTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleNameTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleMessageTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleMessageTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleTimeTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleTimeTextColorHex:@"000000"];
    
    [chatCellSettings setSenderBubbleFontWithSizeForName:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [chatCellSettings setReceiverBubbleFontWithSizeForName:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [chatCellSettings setSenderBubbleFontWithSizeForMessage:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [chatCellSettings setReceiverBubbleFontWithSizeForMessage:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [chatCellSettings setSenderBubbleFontWithSizeForTime:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [chatCellSettings setReceiverBubbleFontWithSizeForTime:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    
    [chatCellSettings senderBubbleTailRequired:YES];
    [chatCellSettings receiverBubbleTailRequired:YES];
    
    self.navigationItem.title = @"Unknown Contact";
    
    [[self chatTable] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    
    
    
    [[self chatTable] registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatSend"];
    
    [[self chatTable] registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatReceive"];
    
    
    
    
    //Instantiating custom view that adjusts itself to keyboard show/hide
    self.handler = [[ContentView alloc] initWithTextView:self.chatTextView ChatTextViewHeightConstraint:self.chatTextViewHeightConstraint contentView:self.contentView ContentViewHeightConstraint:self.contentViewHeightConstraint andContentViewBottomConstraint:self.contentViewBottomConstraint];
    
    //Setting the minimum and maximum number of lines for the textview vertical expansion
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:3];
    
    //Tap gesture on table view so that when someone taps on it, the keyboard is hidden
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.chatTable addGestureRecognizer:gestureRecognizer];
    
 
    self.optionbut1.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.optionbut1.titleLabel.numberOfLines = 2;
    self.optionbut1.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.optionbut2.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.optionbut2.titleLabel.numberOfLines = 2;
    self.optionbut2.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.optionbut3.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.optionbut3.titleLabel.numberOfLines = 2;
    self.optionbut3.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.optionbut4.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.optionbut4.titleLabel.numberOfLines = 2;
    self.optionbut4.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissKeyboard
{
    [self.chatTextView resignFirstResponder];
}

- (void)option
{
   
    
    if(![jsonstrings[countselection] isEqualToString:@"_"])
    {
        //Shows answer from previous set
        [self performSelector:@selector(sendMessage:) withObject:jsonstrings[countselection]  afterDelay:0];
    }

    
    
    
    
    jsonints[1] = [[encounters[countencounter] objectForKey:@"gotoencounter1"] intValue];
    jsonints[2] = [[encounters[countencounter] objectForKey:@"gotoencounter2"] intValue];
    jsonints[3] = [[encounters[countencounter] objectForKey:@"gotoencounter3"] intValue];
    jsonints[4] = [[encounters[countencounter] objectForKey:@"gotoencounter4"] intValue];
    
    
    //get the order of the new selection
    countencounter = [[encounters[jsonints[countselection]] objectForKey:@"order"] intValue];
    NSLog(@"The order %d",jsonints[1]);
    
    NSString *encounter = [encounters[countencounter] objectForKey:@"text"];
    NSString *followup = [encounters[countencounter] objectForKey:@"followup"];
    
    
    jsonstrings[1] = [encounters[countencounter] objectForKey:@"option1text"];
    jsonstrings[2] = [encounters[countencounter] objectForKey:@"option2text"];
    jsonstrings[3] = [encounters[countencounter] objectForKey:@"option3text"];
    jsonstrings[4] = [encounters[countencounter] objectForKey:@"option4text"];
    
    
    
    
    
    
    [self.optionbut1 setTitle:[encounters[countencounter] objectForKey:@"option1"] forState: UIControlStateNormal];
    [self.optionbut2 setTitle:[encounters[countencounter] objectForKey:@"option2"] forState: UIControlStateNormal];
    [self.optionbut3 setTitle:[encounters[countencounter] objectForKey:@"option3"] forState: UIControlStateNormal];
    [self.optionbut4 setTitle:[encounters[countencounter] objectForKey:@"option4"] forState: UIControlStateNormal];
    
    
    
    
    
    [self performSelector:@selector(receiveMessage:) withObject:encounter afterDelay:2];
    
    if(![followup isEqualToString:@"_"])
    {
        [self performSelector:@selector(receiveMessageFollowup:) withObject:followup afterDelay:2.1];
    }
}
- (IBAction)option1
{
    self.optionbut1.hidden=YES;
    countselection=1;
    [self option];
}

- (IBAction)option2
{
    self.optionbut2.hidden=YES;
    countselection=2;
    [self option];
}
- (IBAction)option3
{
    self.optionbut3.hidden=YES;
   countselection=3;
    [self option];
}
- (IBAction)option4
{
    self.optionbut4.hidden=YES;
   countselection=4;
    [self option];
}

- (IBAction)testalert
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Alert"
                                  message:@"Close app to restart game."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel1 = [UIAlertAction
                              actionWithTitle:@"Thanks!"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    
    [alert addAction:cancel1];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startgame
{
    countselection=0;
    jsonstrings[0]=@"_";
    countencounter=0;
    [self option];
    
}

- (void)sendMessage:(NSString *)textlabel
{
    
    self.optionbut1.hidden=YES;
    self.optionbut2.hidden=YES;
    self.optionbut3.hidden=YES;
    self.optionbut4.hidden=YES;
    
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSString *time =[NSString stringWithFormat:@"%ld:%ld",(long)hour,(long)minute];
    
    
        iMessage *sendMessage1;
    
        sendMessage1 = [[iMessage alloc] initIMessageWithName:@"PLAYER" message:textlabel time:time type:@"self"];
    
        [self updateTableView:sendMessage1];
    //}
}

- (IBAction)receiveMessage:(NSString *)textlabel
{
    if([self.optionbut1.titleLabel.text isEqualToString:@"_"]){
        self.optionbut1.hidden=YES;
    }else{
        self.optionbut1.hidden=NO;
    }
    if([self.optionbut2.titleLabel.text isEqualToString:@"_"]){
        self.optionbut2.hidden=YES;
    }else{
        self.optionbut2.hidden=NO;
    }
    if([self.optionbut3.titleLabel.text isEqualToString:@"_"]){
        self.optionbut3.hidden=YES;
    }else{
        self.optionbut3.hidden=NO;
    }
    
    NSLog(@"The label says %@",self.optionbut4.titleLabel.text);
    
    if([self.optionbut4.titleLabel.text isEqualToString:@"_"]){
        self.optionbut4.hidden=YES;
    }else{
        self.optionbut4.hidden=NO;
    }
   
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];

    NSString *time =[NSString stringWithFormat:@"%ld:%ld",(long)hour,(long)minute];
    
    
        iMessage *receiveMessage;
    
        receiveMessage = [[iMessage alloc] initIMessageWithName:@"CPU" message:textlabel time:time type:@"other"];
    
        [self updateTableView:receiveMessage];
    //}
}

- (void)receiveMessageFollowup:(NSString *)textlabel
{
    if([self.optionbut1.titleLabel.text isEqualToString:@"_"]){
        self.optionbut1.hidden=YES;
    }else{
        self.optionbut1.hidden=NO;
    }
    if([self.optionbut2.titleLabel.text isEqualToString:@"_"]){
        self.optionbut2.hidden=YES;
    }else{
        self.optionbut2.hidden=NO;
    }
    if([self.optionbut3.titleLabel.text isEqualToString:@"_"]){
        self.optionbut3.hidden=YES;
    }else{
        self.optionbut3.hidden=NO;
    }
    
    NSLog(@"The label says %@",self.optionbut4.titleLabel.text);
    
    if([self.optionbut4.titleLabel.text isEqualToString:@"_"]){
        self.optionbut4.hidden=YES;
    }else{
        self.optionbut4.hidden=NO;
    }
    
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSString *time =[NSString stringWithFormat:@"%ld:%d",(long)hour,minute];
    
    
    iMessage *receiveMessage;
    
    receiveMessage = [[iMessage alloc] initIMessageWithName:@"CPU" message:textlabel time:time type:@"other"];
    
    [self updateTableView:receiveMessage];
    //}
}
    
- (void)receiveMessageLoop:(NSString *)textlabel
{
        if([self.optionbut1.titleLabel.text isEqualToString:@"_"]){
            self.optionbut1.hidden=YES;
        }else{
            self.optionbut1.hidden=NO;
        }
        if([self.optionbut2.titleLabel.text isEqualToString:@"_"]){
            self.optionbut2.hidden=YES;
        }else{
            self.optionbut2.hidden=NO;
        }
        if([self.optionbut3.titleLabel.text isEqualToString:@"_"]){
            self.optionbut3.hidden=YES;
        }else{
            self.optionbut3.hidden=NO;
        }
        if([self.optionbut4.titleLabel.text isEqualToString:@"_"]){
            self.optionbut4.hidden=YES;
        }else{
            self.optionbut4.hidden=NO;
        }
    
        
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        
        NSString *time =[NSString stringWithFormat:@"%ld:%ld",(long)hour,(long)minute];
    
        
        iMessage *receiveMessage;
        
        receiveMessage = [[iMessage alloc] initIMessageWithName:@"CPU" message:textlabel time:time type:@"other"];
        
        [self updateTableView:receiveMessage];
        //}
}
    

-(void) updateTableView:(iMessage *)msg
{
    [self.chatTextView setText:@""];
    [self.handler textViewDidChange:self.chatTextView];
    
    [self.chatTable beginUpdates];
    
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:currentMessages.count inSection:0];
    
    [currentMessages insertObject:msg atIndex:currentMessages.count];
    
    [self.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1, nil] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.chatTable endUpdates];
    
    //Always scroll the chat table when the user sends the message
    if([self.chatTable numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.chatTable numberOfRowsInSection:0]-1 inSection:0];
        [self.chatTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}



#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    iMessage *message = [currentMessages objectAtIndex:indexPath.row];
    
    if([message.messageType isEqualToString:@"self"])
    {
        /*Uncomment second line and comment first to use XIB instead of code*/
        chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chatSend"];
        //chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatSend"];
        
        chatCell.chatMessageLabel.text = message.userMessage;
        
        chatCell.chatNameLabel.text = message.userName;
        
        chatCell.chatTimeLabel.text = message.userTime;
        
        chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];
        
        /*Comment this line is you are using XIB*/
        chatCell.authorType = iMessageBubbleTableViewCellAuthorTypeSender;
    }
    else
    {
        /*Uncomment second line and comment first to use XIB instead of code*/
        chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        //chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        
        chatCell.chatMessageLabel.text = message.userMessage;
        
        chatCell.chatNameLabel.text = message.userName;
        
        chatCell.chatTimeLabel.text = message.userTime;
        
        chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];

        /*Comment this line is you are using XIB*/
        chatCell.authorType = iMessageBubbleTableViewCellAuthorTypeReceiver;
    }
    
    return chatCell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    iMessage *message = [currentMessages objectAtIndex:indexPath.row];
    
    CGSize size;
    
    CGSize Namesize;
    CGSize Timesize;
    CGSize Messagesize;
    
    NSArray *fontArray = [[NSArray alloc] init];
    
    //Get the chal cell font settings. This is to correctly find out the height of each of the cell according to the text written in those cells which change according to their fonts and sizes.
    //If you want to keep the same font sizes for both sender and receiver cells then remove this code and manually enter the font name with size in Namesize, Messagesize and Timesize.
    if([message.messageType isEqualToString:@"self"])
    {
        fontArray = chatCellSettings.getSenderBubbleFontWithSize;
    }
    else
    {
        fontArray = chatCellSettings.getReceiverBubbleFontWithSize;
    }
    
    //Find the required cell height
    Namesize = [@"Name" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontArray[0]}
                                     context:nil].size;
    
    
    
    Messagesize = [message.userMessage boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:fontArray[1]}
                                                   context:nil].size;
    
    
    Timesize = [@"Time" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontArray[2]}
                                     context:nil].size;
    
    
    size.height = Messagesize.height + Namesize.height + Timesize.height + 48.0f;
    
    return size.height;
}
@end
