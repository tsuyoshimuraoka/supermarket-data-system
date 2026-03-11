import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class WeeklyDepartmentPLForm extends NavigationMixin(LightningElement) {

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;

        // バリデーション
        if (!fields.Store__c) {
            this.showToast('エラー', '店舗を選択してください', 'error');
            return;
        }
        if (!fields.Department__c) {
            this.showToast('エラー', '部門を選択してください', 'error');
            return;
        }
        if (!fields.Date__c) {
            this.showToast('エラー', '日付を入力してください', 'error');
            return;
        }

        // フォーム送信
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        const recordId = event.detail.id;
        this.showToast('成功', 'レコードが保存されました', 'success');

        // レコード詳細ページに遷移
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Weekly_Department_PL__c',
                actionName: 'view'
            }
        });
    }

    handleError(event) {
        const error = event.detail;
        let message = 'レコードの保存に失敗しました';

        if (error && error.detail) {
            message = error.detail;
        } else if (error && error.message) {
            message = error.message;
        }

        this.showToast('エラー', message, 'error');
    }

    handleCancel() {
        // ホームに戻る
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Weekly_Department_PL__c',
                actionName: 'home'
            }
        });
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
