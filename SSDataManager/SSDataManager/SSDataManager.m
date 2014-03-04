//
//  SSDataManager.m
//  SSDataManager
//
//  Created by Susim on 10/31/13.
//  Copyright (c) 2013 Susim. All rights reserved.
//

#import "SSDataManager.h"
#import "AppDelegate.h"
#import "Employee.h"

@implementation SSDataManager
+ (void)addEmployeeWithEmpID:(NSString *)empId empName:(NSString *)empName onCompletion:(CompletionHandler)handler {
	AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   	Employee *emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:appDel.managedObjectContext];
    __block BOOL isDuplicate = NO;
    [self fetchAllEmployeeOnCompletion:^(NSFetchedResultsController *fetchedObject, NSError *error) {
         [fetchedObject.fetchedObjects enumerateObjectsUsingBlock:^(Employee *obj, NSUInteger idx, BOOL *stop) {
             if ([obj.empId isEqualToString:empId]) {
                 isDuplicate = YES;
                 *stop = YES;
             }
         }];
    }];
    if (isDuplicate) {
        handler(@"Duplicate",nil);
    }else {
        emp.empId = empId;
        emp.empName = empName;
        NSError *error;
        [appDel.managedObjectContext save:&error];
        if (error) {
            handler (nil,error);
        }else {
            handler (@"Info Saved" ,nil);
        }
    }

}
+ (void)fetchAllEmployeeOnCompletion:(CompletionHandler)handler {
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectModel* model = [[NSManagedObjectModel alloc] initWithContentsOfURL:appDel.modelURL];
    NSFetchRequest *fetchRequest = [model fetchRequestTemplateForName:@"allEmployeeFetchRequest"];
    NSSortDescriptor* sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"empId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptors]];
    NSFetchedResultsController *fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDel.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error ;
    [fetchResultsController performFetch:&error];
    if (error) {
        handler (nil,error);
    }else {
    	handler (fetchResultsController,nil);
    }
    
}
@end
