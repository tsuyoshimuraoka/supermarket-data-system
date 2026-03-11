import { LightningElement } from 'lwc';
import parseAndImport from '@salesforce/apex/ExcelImportController.parseAndImport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExcelUploader extends LightningElement {
    selectedObjectType = '';
    selectedFile = null;
    isUploading = false;
    showSuccess = false;
    showError = false;
    successMessage = '';
    errorMessage = '';
    importResult = {};

    objectTypeOptions = [
        { label: '週間部門別PL', value: 'PL' },
        { label: '週間単品売上', value: 'Sales' }
    ];

    get hasErrors() {
        return this.importResult && this.importResult.errorCount > 0;
    }

    handleObjectTypeChange(event) {
        this.selectedObjectType = event.detail.value;
        this.resetMessages();
    }

    handleFileChange(event) {
        const files = event.target.files;
        if (files.length > 0) {
            this.selectedFile = files[0];
            this.resetMessages();
        }
    }

    handleUpload() {
        // バリデーション
        if (!this.selectedObjectType) {
            this.showToast('エラー', 'インポート種別を選択してください', 'error');
            return;
        }

        if (!this.selectedFile) {
            this.showToast('エラー', 'CSVファイルを選択してください', 'error');
            return;
        }

        // ファイル読み込み
        this.isUploading = true;
        this.resetMessages();

        const reader = new FileReader();
        reader.onload = () => {
            const base64Data = reader.result;
            this.uploadFile(base64Data);
        };
        reader.onerror = () => {
            this.showError = true;
            this.errorMessage = 'ファイルの読み込みに失敗しました';
            this.isUploading = false;
        };
        reader.readAsDataURL(this.selectedFile);
    }

    uploadFile(base64Data) {
        parseAndImport({
            base64Data: base64Data,
            fileName: this.selectedFile.name,
            objectType: this.selectedObjectType
        })
        .then(result => {
            this.importResult = result;
            this.isUploading = false;

            if (result.success) {
                this.showSuccess = true;
                this.successMessage = `✓ インポート完了`;
                this.showToast('成功', `${result.successCount}件のレコードをインポートしました`, 'success');
            } else {
                this.showError = true;
                this.errorMessage = `✗ インポート失敗: ${result.errorMessage}`;
                this.showToast('エラー', result.errorMessage, 'error');
            }
        })
        .catch(error => {
            this.isUploading = false;
            this.showError = true;
            this.errorMessage = `✗ エラー: ${error.body?.message || error.message}`;
            this.showToast('エラー', this.errorMessage, 'error');
        });
    }

    resetMessages() {
        this.showSuccess = false;
        this.showError = false;
        this.successMessage = '';
        this.errorMessage = '';
        this.importResult = {};
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
