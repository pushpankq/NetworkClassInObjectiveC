
#import "RegistrationVC.h"
#import "EmailVerificationVC.h"
#import "GradientLayer.h"

@interface RegistrationVC () <RegistrationDelegate> {
    
    RegistrationModel * registrationModelObject;
    NSString * confirmCode;
    NSString * userName;
    MBProgressHUD * hud;
}

@end

@implementation RegistrationVC

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    registrationModelObject=[RegistrationModel new];
    registrationModelObject.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_loginButton setExclusiveTouch:YES];
    [_signUpButton setExclusiveTouch:YES];
    
    
    /* Access radial gradiant */
//    gradientLayer = [GradientLayer new];
//    gradientLayer.frame = self.view.bounds;
//    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    
    registrationModelObject = [[RegistrationModel alloc]init];
    
    _firstNameTextfield.delegate =self;
    _lastNameTextfield.delegate = self;
    _phoneNoTextfield.delegate = self;
    _emailTextfield.delegate = self;
    _passwordTextfield.delegate = self;

    self.firstNameTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{ NSForegroundColorAttributeName : RGBA(242.0, 232.0, 232.0, 1) }];
    
    self.lastNameTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{ NSForegroundColorAttributeName : RGBA(242.0, 232.0, 232.0, 1) }];
    
    self.phoneNoTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{ NSForegroundColorAttributeName : RGBA(242.0, 232.0, 232.0, 1) }];
    self.phoneNoTextfield.keyboardType=UIKeyboardTypeNumberPad;

    
    self.emailTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : RGBA(242.0, 232.0, 232.0, 1) }];
    self.emailTextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;

    self.passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : RGBA(242.0, 232.0, 232.0, 1) }];;
    self.passwordTextfield.secureTextEntry=YES;

}

#pragma mark - Status Bar Customization
- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpTapped:(id)sender {

    [self.view endEditing:YES];
    
    registrationModelObject =[registrationModelObject initWithObjects:self.firstNameTextfield.text lastName:self.lastNameTextfield.text phoneNumber:self.phoneNoTextfield.text emailId:self.emailTextfield.text password:self.passwordTextfield.text];
    
    BOOL checkAlert=[registrationModelObject validateStrings];
    
    if (checkAlert) {
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        [hud.bezelView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]];
        hud.contentColor = [UIColor whiteColor];
        hud.label.text = @"Loading";        [registrationModelObject userRegistration];
        
    } else {
        
        [self showAlertWithVC:kAlertTitle message:registrationModelObject.alertMessage];
    }
}


-(void)registrationServiceCompletion:(NSDictionary*) responseDictionary moveForward:(BOOL)moveForward {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if(moveForward){
        
                confirmCode = [[responseDictionary valueForKey:kData] valueForKey:kConfirmCode];
                userName = [[responseDictionary valueForKey:kData]valueForKey:kUserName];
                [self performSegueWithIdentifier:kEmailVerificationIdentifier sender:self];
    } else {
    
            [self showAlertWithVC:kAlertTitle message:[[responseDictionary valueForKey:kResponse]valueForKey:kResponseMessage]];
    }
}
              
-(void)errorFromService:(NSString *)errorString moveForward:(BOOL)moveForward{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self showAlertWithVC:kAlertTitle message:errorString];
}

- (IBAction)loginViaFacebook:(id)sender {
    
}

- (IBAction)alreadyHaveAnAccount:(id)sender {
}

- (IBAction)dismissViewController:(id)sender {
    
    // two view controller dismiss together
[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark UIAlertController
-(void)showAlertWithVC :(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertObject=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnOk=[UIAlertAction actionWithTitle:kAlertButtonTitle style:UIAlertActionStyleCancel handler:nil];
    [alertObject addAction:btnOk];
    [self presentViewController:alertObject animated:YES completion:nil];
}


#pragma mark  TextField Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return TRUE;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view  endEditing:YES]; //may be not required
    [super touchesBegan:touches withEvent:event]; //may be not required
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    //textField.text=@"";
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
   // static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect;
    CGRect viewRect;
    
    textFieldRect =[self.view.window convertRect:textField.bounds fromView:textField];
    viewRect =[self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    
    CGRect viewFrame;
    
    viewFrame= self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == _phoneNoTextfield) {
    NSString *resultText = [textField.text stringByReplacingCharactersInRange:range
                                                                   withString:string];
    return resultText.length <= 10;
    }
    else {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if(textField.tag==0)
    {
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        CGRect viewFrame;
        
        viewFrame= self.view.frame;
        viewFrame.origin.y += animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
        
    }
    
}

-(IBAction)unwindFromEmailVerification:(UIStoryboardSegue *)segue {
}


#pragma mark -  Resign Keyboard on touch Method
- (void)dismissControls {
    
    [self.firstNameTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.phoneNoTextfield resignFirstResponder];
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:kEmailVerificationIdentifier]) {
        
        EmailVerificationVC *emailVarification = [segue destinationViewController];
        emailVarification.confirmCode = confirmCode;
        emailVarification.userName = userName;
        emailVarification.email = _emailTextfield.text;
        
    }
}



@end
