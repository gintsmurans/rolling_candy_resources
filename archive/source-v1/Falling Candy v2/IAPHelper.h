//
//  IAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>


#define IAPErrorDomain @"IAPErrorDomain"


typedef void (^RequestProductsCompletionHandler)(NSArray * products, NSError *error);
typedef void (^BuyProductCompletionHandler)(SKPaymentTransaction *transaction, NSError *error);
typedef void (^ActionSheetCompletionHandler)(UIActionSheet *actionSheet, NSError *error);
typedef void (^VerifySubscriptionCompletionHandler)(NSString *productIdentifier, NSData *receiptData, NSNumber *expiresDate, NSError *error);



@interface MutableTransaction : NSObject <NSCoding>
@property (nonatomic, retain) NSString *productIdentifier;
@property (nonatomic, retain) NSData *transactionReceipt;
@property (nonatomic, retain) NSNumber *transactionDate;
@property (nonatomic, retain) NSNumber *expiresDate;

+ (id)mutableTransactionWithTransaction:(SKPaymentTransaction *)transaction;
+ (id)mutableTransactionWithTransaction:(SKPaymentTransaction *)transaction andWithExpiresDate:(NSNumber *)expiresDate;
+ (id)mutableTransactionWithData:(NSData *)data;
+ (id)mutableTransactionWithDictionary:(NSDictionary *)dict;
- (NSData *)data;
- (NSDictionary *)dictionary;
@end




@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIActionSheetDelegate>
{
    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _productsRequestCompletionHandler;
    BuyProductCompletionHandler _buyProductCompletionHandler;
    BuyProductCompletionHandler _restoreTransactionsCompletionHandler;
    VerifySubscriptionCompletionHandler _verifySubscriptionCompletionHandler;

    NSArray *_productInfo;
    NSSet *_productIdentifiers;
}

@property (nonatomic, retain) NSArray *allProducts;
@property (nonatomic, retain) NSString *apiVerifyTransactionUrl;
@property (nonatomic, copy) VerifySubscriptionCompletionHandler defaultReceiptVerificationCompletionHandler;


+ (IAPHelper *)sharedInstance;
+ (void)showAlertWithError:(NSError *)error;

- (BOOL)isProductIdentifierPurchased:(NSString *)productIdentifier;
- (SKProduct *)findProductWithIdentifier:(NSString *)identifier;

- (id)initWithProductInfoArray:(NSArray *)productInfo andReceiptVerificationUrl:(NSString *)receiptVerificationUrl;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product withCompletionHandler:(BuyProductCompletionHandler)completionHandler;
- (void)buyProductWithId:(NSString *)productId withCompletionHandler:(BuyProductCompletionHandler)completionHandler;
- (void)restoreCompletedTransactionsWithCompletionHandler:(BuyProductCompletionHandler)completionHandler withVerifyCompletionHandler:(VerifySubscriptionCompletionHandler)verifyCompletionHandler;

- (void)verifySubscriptionReceiptWithProductIdentifier:(NSString *)productIdentifier withReceiptData:(NSData *)receiptData withCompletionHandler:(VerifySubscriptionCompletionHandler)completionHandler;

- (void)subscriptionActionSheetWithSearchString:(NSString *)searchString withCompletionHandler:(ActionSheetCompletionHandler)completionHandler withBuyCompletionHandler:(BuyProductCompletionHandler)buyCompletionHandler withVerifyCompletionHandler:(VerifySubscriptionCompletionHandler)verifyCompletionHandler;

@end
