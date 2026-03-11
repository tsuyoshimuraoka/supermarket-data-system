/**
 * CommentServiceTest - CommentServiceのテストクラス
 */
@isTest
private class CommentServiceTest {

    @testSetup
    static void setupTestData() {
        // テスト用店舗作成
        Store__c store = new Store__c(
            Name = 'Test Store',
            Store_Code__c = 'TEST001'
        );
        insert store;

        // テスト用レビュー作成
        Store_Review__c review = new Store_Review__c(
            Store__c = store.Id,
            Review_Date__c = Date.today(),
            Supervisor__c = UserInfo.getUserId(),
            Review_Status__c = 'Draft',
            Summary__c = 'Test Summary'
        );
        insert review;
    }

    @isTest
    static void testCreateComment() {
        Store_Review__c review = [SELECT Id FROM Store_Review__c LIMIT 1];

        Test.startTest();
        Id commentId = CommentService.createComment(
            review.Id,
            'This is a test comment',
            'SV Advice',
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, commentId, 'Comment ID should not be null');

        Review_Comment__c comment = [
            SELECT Id, Comment__c, Comment_Type__c, Commenter__c
            FROM Review_Comment__c
            WHERE Id = :commentId
        ];

        System.assertEquals('This is a test comment', comment.Comment__c);
        System.assertEquals('SV Advice', comment.Comment_Type__c);
        System.assertEquals(UserInfo.getUserId(), comment.Commenter__c);
    }

    @isTest
    static void testCreateCommentWithParent() {
        Store_Review__c review = [SELECT Id FROM Store_Review__c LIMIT 1];

        // 親コメント作成
        Id parentCommentId = CommentService.createComment(
            review.Id,
            'Parent comment',
            'SV Advice',
            null
        );

        Test.startTest();
        // 子コメント作成
        Id childCommentId = CommentService.createComment(
            review.Id,
            'Child comment',
            'Manager Response',
            parentCommentId
        );
        Test.stopTest();

        Review_Comment__c childComment = [
            SELECT Id, Parent_Comment__c
            FROM Review_Comment__c
            WHERE Id = :childCommentId
        ];

        System.assertEquals(parentCommentId, childComment.Parent_Comment__c);
    }

    @isTest
    static void testGetCommentsForReview() {
        Store_Review__c review = [SELECT Id FROM Store_Review__c LIMIT 1];

        // 複数コメント作成
        CommentService.createComment(review.Id, 'First comment', 'SV Advice', null);
        CommentService.createComment(review.Id, 'Second comment', 'Manager Response', null);
        CommentService.createComment(review.Id, 'Third comment', 'General', null);

        Test.startTest();
        List<CommentService.CommentWrapper> comments = CommentService.getCommentsForReview(review.Id);
        Test.stopTest();

        System.assertEquals(3, comments.size(), 'Should have 3 comments');
        System.assertEquals('First comment', comments[0].comment);
        System.assertEquals('Second comment', comments[1].comment);
        System.assertEquals('Third comment', comments[2].comment);
    }

    @isTest
    static void testGetCommentsEmpty() {
        Store_Review__c review = [SELECT Id FROM Store_Review__c LIMIT 1];

        Test.startTest();
        List<CommentService.CommentWrapper> comments = CommentService.getCommentsForReview(review.Id);
        Test.stopTest();

        System.assertEquals(0, comments.size(), 'Should have no comments');
    }

    @isTest
    static void testUpdateReviewStatus() {
        Store_Review__c review = [SELECT Id, Review_Status__c FROM Store_Review__c LIMIT 1];
        System.assertEquals('Draft', review.Review_Status__c);

        Test.startTest();
        CommentService.updateReviewStatus(review.Id, 'Submitted');
        Test.stopTest();

        review = [SELECT Id, Review_Status__c FROM Store_Review__c WHERE Id = :review.Id];
        System.assertEquals('Submitted', review.Review_Status__c);
    }

    @isTest
    static void testCreateCommentNullReviewId() {
        Test.startTest();
        try {
            CommentService.createComment(null, 'Test comment', 'General', null);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('failed'), 'Should contain error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateCommentEmptyText() {
        Store_Review__c review = [SELECT Id FROM Store_Review__c LIMIT 1];

        Test.startTest();
        try {
            CommentService.createComment(review.Id, '', 'General', null);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('failed'), 'Should contain error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testBulkComments() {
        Store_Review__c review = [SELECT Id FROM Store_Review__c LIMIT 1];

        Test.startTest();
        for (Integer i = 0; i < 50; i++) {
            CommentService.createComment(
                review.Id,
                'Bulk comment ' + i,
                'General',
                null
            );
        }
        Test.stopTest();

        List<CommentService.CommentWrapper> comments = CommentService.getCommentsForReview(review.Id);
        System.assertEquals(50, comments.size(), 'Should have 50 comments');
    }
}
