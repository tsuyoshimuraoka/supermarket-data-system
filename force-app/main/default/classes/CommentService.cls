/**
 * CommentService - レビューコメント管理サービス
 * 店舗レビューへのコメント作成・取得機能を提供
 */
public with sharing class CommentService {

    /**
     * コメント作成
     * @param reviewId 店舗レビューID
     * @param commentText コメント内容
     * @param commentType コメント種別
     * @param parentCommentId 親コメントID（スレッド用、オプション）
     * @return 作成されたコメントのID
     */
    @AuraEnabled
    public static Id createComment(Id reviewId, String commentText, String commentType, Id parentCommentId) {
        try {
            if (reviewId == null || String.isBlank(commentText)) {
                throw new AuraHandledException('コメントの作成に失敗しました: Review ID and comment text are required');
            }

            Review_Comment__c comment = new Review_Comment__c(
                Store_Review__c = reviewId,
                Comment__c = commentText,
                Comment_Type__c = commentType,
                Parent_Comment__c = parentCommentId,
                Comment_Date__c = System.now(),
                Commenter__c = UserInfo.getUserId()  // Set programmatically
            );

            insert comment;
            return comment.Id;

        } catch (Exception e) {
            if (e instanceof AuraHandledException) {
                throw e;
            }
            throw new AuraHandledException('コメントの作成に失敗しました: ' + e.getMessage());
        }
    }

    /**
     * レビューに紐づくコメント取得（スレッド順）
     * @param reviewId 店舗レビューID
     * @return コメントリスト
     */
    @AuraEnabled(cacheable=true)
    public static List<CommentWrapper> getCommentsForReview(Id reviewId) {
        try {
            if (reviewId == null) {
                throw new AuraHandledException('コメントの取得に失敗しました: Review ID is required');
            }

            // コメント取得（コメント者情報含む）
            List<Review_Comment__c> comments = [
                SELECT Id, Comment__c, Comment_Type__c, Comment_Date__c,
                       Parent_Comment__c, 
                       Commenter__c, Commenter__r.Name, Commenter__r.SmallPhotoUrl
                FROM Review_Comment__c
                WHERE Store_Review__c = :reviewId
                ORDER BY Comment_Date__c ASC
            ];

            // Wrapperに変換
            List<CommentWrapper> wrappers = new List<CommentWrapper>();
            for (Review_Comment__c comment : comments) {
                wrappers.add(new CommentWrapper(comment));
            }

            return wrappers;

        } catch (Exception e) {
            if (e instanceof AuraHandledException) {
                throw e;
            }
            throw new AuraHandledException('コメントの取得に失敗しました: ' + e.getMessage());
        }
    }

    /**
     * レビューステータス更新（コメント追加時に自動更新）
     * @param reviewId 店舗レビューID
     * @param newStatus 新しいステータス
     */
    @AuraEnabled
    public static void updateReviewStatus(Id reviewId, String newStatus) {
        try {
            if (reviewId == null || String.isBlank(newStatus)) {
                throw new AuraHandledException('ステータス更新に失敗しました: Review ID and status are required');
            }

            Store_Review__c review = [SELECT Id, Review_Status__c FROM Store_Review__c WHERE Id = :reviewId LIMIT 1];
            review.Review_Status__c = newStatus;
            update review;

        } catch (Exception e) {
            if (e instanceof AuraHandledException) {
                throw e;
            }
            throw new AuraHandledException('ステータス更新に失敗しました: ' + e.getMessage());
        }
    }

    /**
     * コメントWrapper クラス（LWCでの表示用）
     */
    public class CommentWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String comment;
        @AuraEnabled public String commentType;
        @AuraEnabled public DateTime commentDate;
        @AuraEnabled public Id parentCommentId;
        @AuraEnabled public String commenterName;
        @AuraEnabled public String commenterPhotoUrl;

        public CommentWrapper(Review_Comment__c comment) {
            this.id = comment.Id;
            this.comment = comment.Comment__c;
            this.commentType = comment.Comment_Type__c;
            this.commentDate = comment.Comment_Date__c;
            this.parentCommentId = comment.Parent_Comment__c;
            this.commenterName = comment.Commenter__r != null ? comment.Commenter__r.Name : '';
            this.commenterPhotoUrl = comment.Commenter__r != null ? comment.Commenter__r.SmallPhotoUrl : '';
        }
    }
}
