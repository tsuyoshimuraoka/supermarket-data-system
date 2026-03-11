import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getCommentsForReview from '@salesforce/apex/CommentService.getCommentsForReview';
import createComment from '@salesforce/apex/CommentService.createComment';

export default class StoreReviewComponent extends LightningElement {
    @api reviewId;

    comments = [];
    newComment = '';
    commentType = 'General';
    isAddingComment = false;
    wiredCommentsResult;

    commentTypeOptions = [
        { label: 'SVアドバイス', value: 'SV Advice' },
        { label: '店長回答', value: 'Manager Response' },
        { label: '一般', value: 'General' }
    ];

    @wire(getCommentsForReview, { reviewId: '$reviewId' })
    wiredComments(result) {
        this.wiredCommentsResult = result;
        if (result.data) {
            this.comments = result.data;
        } else if (result.error) {
            this.showToast('エラー', 'コメントの取得に失敗しました', 'error');
        }
    }

    get hasComments() {
        return this.comments && this.comments.length > 0;
    }

    handleCommentChange(event) {
        this.newComment = event.target.value;
    }

    handleTypeChange(event) {
        this.commentType = event.target.value;
    }

    handleAddComment() {
        if (!this.newComment || !this.newComment.trim()) {
            this.showToast('エラー', 'コメントを入力してください', 'error');
            return;
        }

        this.isAddingComment = true;

        createComment({
            reviewId: this.reviewId,
            commentText: this.newComment,
            commentType: this.commentType,
            parentCommentId: null
        })
        .then(() => {
            this.showToast('成功', 'コメントが追加されました', 'success');
            this.newComment = '';
            this.commentType = 'General';
            return refreshApex(this.wiredCommentsResult);
        })
        .catch(error => {
            this.showToast('エラー', error.body.message, 'error');
        })
        .finally(() => {
            this.isAddingComment = false;
        });
    }

    handleRefresh() {
        return refreshApex(this.wiredCommentsResult);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
