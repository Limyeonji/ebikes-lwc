import { LightningElement, wire } from 'lwc';

// Lightning Message Service
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import PRODUCT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';

// field values 가져오기
import { getFieldValue } from 'lightning/uiRecordApi';

// Product__c Schema
import PRODUCT_OBJECT from '@salesforce/schema/Product__c';
import NAME_FIELD from '@salesforce/schema/Product__c.Name';
import PICTURE_URL_FIELD from '@salesforce/schema/Product__c.Picture_URL__c';
import CATEGORY_FIELD from '@salesforce/schema/Product__c.Category__c';
import LEVEL_FIELD from '@salesforce/schema/Product__c.Level__c';
import MSRP_FIELD from '@salesforce/schema/Product__c.MSRP__c';
import BATTERY_FIELD from '@salesforce/schema/Product__c.Battery__c';
import CHARGER_FIELD from '@salesforce/schema/Product__c.Charger__c';
import MOTOR_FIELD from '@salesforce/schema/Product__c.Motor__c';
import MATERIAL_FIELD from '@salesforce/schema/Product__c.Material__c';
import FOPK_FIELD from '@salesforce/schema/Product__c.Fork__c';
import FRONT_BRAKES_FIELD from '@salesforce/schema/Product__c.Front_Brakes__c';
import REAR_BRAKES_FIELD from '@salesforce/schema/Product__c.Rear_Brakes__c';

export default class ProductCard extends NavigationMixin(LightningElement) {
    categoryField = CATEGORY_FIELD;
    levelField = LEVEL_FIELD;
    msrpField = MSRP_FIELD;
    batteryField = BATTERY_FIELD;
    chargerField = CHARGER_FIELD;
    motorField = MOTOR_FIELD;
    materialField = MATERIAL_FIELD;
    forkField = FOPK_FIELD;
    frontBrakesField = FRONT_BRAKES_FIELD;
    rearBrakesField = REAR_BRAKES_FIELD;

    //레코드 아이디
    recordId;

    // 특정형식으로 표시되는 제품 이름, 사진URL
    productName;
    productPictureUrl;
    
    // messageContext 객체   
    @wire(MessageContext) messageContext;

    // 리스트에서 선택된 제품의 id를 messageContext에서 읽고 저장할 변수
    productSelectionSubscription;

    connectedCallback() {
        // 필터에서 넘어온 메세지를 읽음
        this.productSelectionSubscription = subscribe(
            this.messageContext,
            PRODUCT_SELECTED_MESSAGE,
            (message) => this.handleProductSelected(message.productId)
        );
    }

    handleRecordLoaded(event) {
        // const { records } -> 객체 구조분해할당 방식(destructuring) 
        const { records } = event.detail;
        const recordData = records[this.recordId];

        //필드 값에 해당하는 value값 가져오기
        this.productName = getFieldValue(recordData, NAME_FIELD); 
        this.productPictureUrl = getFieldValue(recordData, PICTURE_URL_FIELD);
    }

    //메세지에서 읽어온 id를 recordId에 넣어줌
    handleProductSelected(productId) {
        this.recordId = productId;
    }

    // 해당 제품의 recordPage로 이동
    handleNavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: PRODUCT_OBJECT.objectApiName,
                actionName: 'view'
            }
        });
    }
}