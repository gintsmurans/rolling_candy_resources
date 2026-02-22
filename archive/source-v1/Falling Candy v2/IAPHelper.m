//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//


#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "FSNConnection.h"


// TODO: Localize

#pragma mark - MutableTransaction

@implementation MutableTransaction
@synthesize productIdentifier = _productIdentifier, transactionDate = _transactionDate, transactionReceipt = _transactionReceipt, expiresDate = _expiresDate;

+ (id)mutableTransactionWithTransaction:(SKPaymentTransaction *)transaction
{
    MutableTransaction *mt = [[MutableTransaction alloc] init];
    [mt setProductIdentifier:transaction.payment.productIdentifier];
    [mt setTransactionDate:[NSNumber numberWithInt:[transaction.transactionDate timeIntervalSince1970]]];
    [mt setTransactionReceipt:transaction.transactionReceipt];
    return [mt autorelease];
}

+ (id)mutableTransactionWithTransaction:(SKPaymentTransaction *)transaction andWithExpiresDate:(NSNumber *)expiresDate
{
    MutableTransaction *mt = [MutableTransaction mutableTransactionWithTransaction:transaction];
    [mt setExpiresDate:expiresDate];
    return mt;
}

+ (id)mutableTransactionWithData:(NSData *)data
{
    if (data == nil)
    {
        return nil;
    }
    MutableTransaction *mt = (MutableTransaction *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return mt;
}
+ (id)mutableTransactionWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
    {
        return nil;
    }
    MutableTransaction *mt = [[MutableTransaction alloc] init];
    [mt setProductIdentifier:[dict objectForKey:@"product_identifier"]];
    [mt setTransactionReceipt:[[dict objectForKey:@"receipt_data"] dataUsingEncoding:NSUTF8StringEncoding]];
    [mt setTransactionDate:[dict objectForKey:@"date"]];
    [mt setExpiresDate:[dict objectForKey:@"expires_date"]];
    return [mt autorelease];
}

- (NSData *)data
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSDictionary *)dictionary
{
    if (_transactionDate == nil)
    {
        _transactionDate = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:_productIdentifier, @"product_identifier", [[[NSString alloc] initWithData:_transactionReceipt encoding:NSUTF8StringEncoding] autorelease], @"receipt_data", _transactionDate, @"date", _expiresDate, @"expires_date", nil];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        [self setProductIdentifier:[decoder decodeObjectForKey:@"productIdentifier"]];
        [self setTransactionReceipt:[decoder decodeObjectForKey:@"transactionReceipt"]];
        [self setTransactionDate:[decoder decodeObjectForKey:@"transactionDate"]];
        [self setExpiresDate:[decoder decodeObjectForKey:@"expiresDate"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.productIdentifier forKey:@"productIdentifier"];
    [encoder encodeObject:self.transactionReceipt forKey:@"transactionReceipt"];
    [encoder encodeObject:self.transactionDate forKey:@"transactionDate"];
    [encoder encodeObject:self.expiresDate forKey:@"expiresDate"];
}

@end




#pragma mark - IAPHelper

@implementation IAPHelper
@synthesize allProducts = _allProducts, apiVerifyTransactionUrl = _apiVerifyTransactionUrl, defaultReceiptVerificationCompletionHandler = _defaultReceiptVerificationCompletionHandler;


#pragma mark - Instance Methods

+ (IAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static IAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSString *receiptVerificationUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"IAPReceiptVerificationUrl"];
        NSArray *products = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"IAPProducts"];
        NSAssert(products != nil, @"IAPProducts not found in Info.plist");

        sharedInstance = [[self alloc] initWithProductInfoArray:products andReceiptVerificationUrl:receiptVerificationUrl];
    });
    return sharedInstance;
}

+ (void)showAlertWithError:(NSError *)error
{
    // Skip showing same error over and over
    static NSError *lastError;
    if (lastError != nil && [lastError isEqual:error])
    {
        return;
    }
    lastError = [error copy];
    double delayInSeconds = 20.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [lastError release], lastError = nil;
    });


    if ([error.domain isEqualToString:SKErrorDomain])
    {
        switch (error.code) {
            case SKErrorPaymentCancelled:
                return;
            break;
        }
    }

    if ([error.domain isEqualToString:IAPErrorDomain])
    {
        switch (error.code) {
            case 0: // Cancelled
                return;
                break;
        }
    }

    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[error localizedDescription]
                              message:[error localizedFailureReason]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
    alertView = nil;
}



#pragma mark - Init

- (id)initWithProductInfoArray:(NSArray *)productInfo andReceiptVerificationUrl:(NSString *)receiptVerificationUrl
{
    if ((self = [super init]))
    {
        // Make a set of product identifiers
        NSMutableSet *tmp = [[NSMutableSet alloc] init];
        for (NSDictionary *product in productInfo)
        {
            [tmp addObject:[product objectForKey:@"id"]];
        }

        // Store product identifiers
        _productIdentifiers = [tmp copy];
        _productInfo = [productInfo retain];
        _apiVerifyTransactionUrl = [receiptVerificationUrl retain];

        // Cleanup
        [tmp release];

        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}


- (void)dealloc
{
    [_allProducts release];
    [_apiVerifyTransactionUrl release];
    [_productInfo release];
    [_productIdentifiers release];
    [super dealloc];
}



#pragma mark - Helpers

- (BOOL)isProductIdentifierPurchased:(NSString *)productIdentifier
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
}

- (SKProduct *)findProductWithIdentifier:(NSString *)identifier
{
    if (_allProducts == nil)
    {
        return nil;
    }

    for (SKProduct *product in _allProducts)
    {
        if ([product.productIdentifier isEqualToString:identifier])
        {
            return product;
        }
    }
    return nil;
}



#pragma mark - Store Requests

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    // 1
    _productsRequestCompletionHandler = [completionHandler copy];

    // 2
    if (_allProducts != nil)
    {
        _productsRequestCompletionHandler(_allProducts, nil);
        _productsRequestCompletionHandler = nil;
        return;
    }

    // 3
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}


- (void)buyProductWithId:(NSString *)productId withCompletionHandler:(BuyProductCompletionHandler)completionHandler
{
    SKProduct *product = [self findProductWithIdentifier:productId];
    if (product == nil)
    {
        [self requestProductsWithCompletionHandler:^(NSArray *products, NSError *error) {
            if (error != nil)
            {
                completionHandler(nil, error);
            }
            else
            {
                SKProduct *product = [self findProductWithIdentifier:productId];
                if (product == nil)
                {
                    completionHandler(nil, [NSError errorWithDomain:IAPErrorDomain code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Product not found" forKey:NSLocalizedDescriptionKey]]);
                }
                else
                {
                    [self buyProduct:product withCompletionHandler:completionHandler];
                }
            }
        }];
    }
    else
    {
        [self buyProduct:product withCompletionHandler:completionHandler];
    }
}


- (void)buyProduct:(SKProduct *)product withCompletionHandler:(BuyProductCompletionHandler)completionHandler
{
    NSLog(@"Buying %@...", product.productIdentifier);

    if ([SKPaymentQueue canMakePayments])
    {
        _buyProductCompletionHandler = [completionHandler copy];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else if (completionHandler != nil)
    {
        completionHandler(nil, [NSError errorWithDomain:IAPErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:@"Purchases are disabled in device's settings (Settings > General > Restrictions)" forKey:NSLocalizedDescriptionKey]]);
    }
}


- (void)restoreCompletedTransactionsWithCompletionHandler:(BuyProductCompletionHandler)completionHandler withVerifyCompletionHandler:(VerifySubscriptionCompletionHandler)verifyCompletionHandler
{
    _restoreTransactionsCompletionHandler = [completionHandler copy];
    _verifySubscriptionCompletionHandler = [verifyCompletionHandler copy];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}



- (void)verifySubscriptionReceiptWithProductIdentifier:(NSString *)productIdentifier withReceiptData:(NSData *)receiptData withCompletionHandler:(VerifySubscriptionCompletionHandler)completionHandler
{
    if (_apiVerifyTransactionUrl == nil || productIdentifier == nil || receiptData == nil)
    {
        if (completionHandler != nil)
        {
            completionHandler(nil, nil, nil, [NSError errorWithDomain:IAPErrorDomain code:0 userInfo:nil]);
        }
        return;
    }

    NSString *receiptString = [[[NSString alloc] initWithData:receiptData encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary *postData = [NSDictionary dictionaryWithObjectsAndKeys:receiptString, @"receipt-data", nil];



    NSURL *url = [NSURL URLWithString:_apiVerifyTransactionUrl];
    FSNConnection *connection = [FSNConnection withUrl:url method:FSNRequestMethodPOST headers:nil parameters:postData parseBlock:^id(FSNConnection *c, NSError **e) {
        return [NSJSONSerialization JSONObjectWithData:c.responseData options:0 error:e];
    } completionBlock:^(FSNConnection *c) {
        if (c.error != nil)
        {
            if (completionHandler != nil)
            {
                completionHandler(nil, nil, nil, c.error);
            }
        }
        else
        {
            NSDictionary *data = (NSDictionary *)c.parseResult;
            NSDictionary *errorDict = [data objectForKey:@"error"];
            if (errorDict == nil)
            {
                NSNumber *expiresDate = [data objectForKey:@"expires_date"];

                if (_defaultReceiptVerificationCompletionHandler != nil)
                {
                    _defaultReceiptVerificationCompletionHandler(productIdentifier, receiptData, expiresDate, nil);
                }

                if (completionHandler != nil)
                {
                    completionHandler(productIdentifier, receiptData, expiresDate, nil);
                }
            }
            else
            {
                if (completionHandler != nil)
                {
                    completionHandler(nil, nil, nil, [NSError errorWithDomain:IAPErrorDomain code:[[errorDict objectForKey:@"code"] intValue] userInfo:[NSDictionary dictionaryWithObject:[errorDict objectForKey:@"msg"] forKey:NSLocalizedDescriptionKey]]);
                }
            }
        }
    } progressBlock:nil];

    [connection start];
}



#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products...");

    // Release previous product list (if any)
    _allProducts = [[response.products sortedArrayUsingComparator:^NSComparisonResult(SKProduct *p1, SKProduct *p2) {
        return [p1.price compare:p2.price];
    }] retain];
    [_productsRequest release];
    if (_productsRequestCompletionHandler != nil)
    {
        _productsRequestCompletionHandler(_allProducts, nil);
        _productsRequestCompletionHandler = nil;
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load list of products.");

    [_productsRequest release];
    if (_productsRequestCompletionHandler != nil)
    {
        _productsRequestCompletionHandler(nil, error);
        _productsRequestCompletionHandler = nil;
    }
}



#pragma mark - SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    // Call restore callback
    if (_restoreTransactionsCompletionHandler != nil)
    {
        _restoreTransactionsCompletionHandler(nil, error);
        _restoreTransactionsCompletionHandler = nil;
    }
}



- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");

    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    // Call buy callback
    if (_buyProductCompletionHandler != nil)
    {
        _buyProductCompletionHandler(transaction, nil);
        _buyProductCompletionHandler = nil;
    }

    // Verify receipt
    [self verifySubscriptionReceiptWithProductIdentifier:transaction.payment.productIdentifier withReceiptData:transaction.transactionReceipt withCompletionHandler:_verifySubscriptionCompletionHandler];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");

    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    // Call restore callback
    if (_restoreTransactionsCompletionHandler != nil)
    {
        _restoreTransactionsCompletionHandler(transaction, nil);
        //_restoreTransactionsCompletionHandler = nil;
    }

    // Verify receipt
    [self verifySubscriptionReceiptWithProductIdentifier:transaction.payment.productIdentifier withReceiptData:transaction.transactionReceipt withCompletionHandler:_verifySubscriptionCompletionHandler];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }

    // Call buy callback
    if (_buyProductCompletionHandler != nil)
    {
        _buyProductCompletionHandler(nil, transaction.error);
        _buyProductCompletionHandler = nil;
    }

    // Call restore callback
    if (_restoreTransactionsCompletionHandler != nil)
    {
        _restoreTransactionsCompletionHandler(nil, transaction.error);
        //_restoreTransactionsCompletionHandler = nil;
    }

    // Release verify handler if any
    _verifySubscriptionCompletionHandler = nil;
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark - Subscription sheet

- (void)subscriptionActionSheetWithSearchString:(NSString *)searchString withCompletionHandler:(ActionSheetCompletionHandler)completionHandler withBuyCompletionHandler:(BuyProductCompletionHandler)buyCompletionHandler withVerifyCompletionHandler:(VerifySubscriptionCompletionHandler)verifyCompletionHandler
{
    [self requestProductsWithCompletionHandler:^(NSArray *products, NSError *error) {
        if (error != nil)
        {
            completionHandler(nil, error);
            return;
        }

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Abonēšana"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        for (SKProduct *product in products)
        {
            if ([product.productIdentifier rangeOfString:searchString].location != NSNotFound)
            {
//                NSString *title = @"";

                for (NSDictionary *productInfo in _productInfo)
                {
                    NSString *pId = [productInfo objectForKey:@"id"];
                    if ([pId isEqualToString:product.productIdentifier])
                    {
                        //title = [productInfo objectForKey:@"title"];
                    }
                }

//                [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ %@", title, [product priceAsString]]];
            }
        }

        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];

        _buyProductCompletionHandler = [buyCompletionHandler copy];
        _verifySubscriptionCompletionHandler = [verifyCompletionHandler copy];
        completionHandler(actionSheet, nil);
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex)
    {
        if (_buyProductCompletionHandler != nil)
        {
            _buyProductCompletionHandler(nil, [NSError errorWithDomain:IAPErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"User cancelled" forKey:NSLocalizedDescriptionKey]]);
            _buyProductCompletionHandler = nil;
        }
        _verifySubscriptionCompletionHandler = nil;
    }
    else
    {
        SKProduct *product = [[IAPHelper sharedInstance].allProducts objectAtIndex:buttonIndex];
        [[IAPHelper sharedInstance] buyProduct:product withCompletionHandler:_buyProductCompletionHandler];
    }
}


@end