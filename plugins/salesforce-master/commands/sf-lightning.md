---
description: Develop Lightning Web Components (LWC) and Aura components with best practices
---

# Salesforce Lightning Component Development

## Purpose
Guide Lightning Web Component (LWC) and Aura component development including JavaScript, HTML templates, CSS styling, component communication, and Salesforce platform integration.

## Instructions

### Step 1: Choose Component Framework

**Lightning Web Components (LWC)** - RECOMMENDED:
- Modern JavaScript (ES6+)
- Web standards-based (Shadow DOM, Custom Elements, Modules)
- Better performance
- Easier testing
- Preferred for new development

**Aura Components** - LEGACY:
- Older framework
- Used for existing implementations
- Required for Lightning Out, Communities (in some cases)
- Being phased out

### Step 2: Lightning Web Component Structure

**LWC File Structure**:
```
force-app/main/default/lwc/myComponent/
├── myComponent.html           # HTML template
├── myComponent.js             # JavaScript controller
├── myComponent.css            # Component-scoped CSS
├── myComponent.js-meta.xml    # Configuration metadata
└── __tests__/                 # Jest tests
    └── myComponent.test.js
```

**HTML Template** (myComponent.html):
```html
<template>
    <lightning-card title="My Component" icon-name="custom:custom63">
        <div class="slds-m-around_medium">
            <p>Hello, {name}!</p>
            <lightning-input
                label="Enter Name"
                value={name}
                onchange={handleNameChange}>
            </lightning-input>
            <lightning-button
                label="Click Me"
                onclick={handleClick}>
            </lightning-button>
        </div>
    </lightning-card>
</template>
```

**JavaScript Controller** (myComponent.js):
```javascript
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class MyComponent extends LightningElement {
    // Public property (can be set from parent or App Builder)
    @api recordId;

    // Tracked property (reactive)
    @track name = '';
    @track accounts = [];

    // Wire service to get data
    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Event handler
    handleNameChange(event) {
        this.name = event.target.value;
    }

    handleClick() {
        this.showToast('Success', `Hello, ${this.name}!`, 'success');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Lifecycle hooks
    connectedCallback() {
        // Component inserted in DOM
    }

    renderedCallback() {
        // Component finished rendering
    }

    disconnectedCallback() {
        // Component removed from DOM
    }
}
```

**Metadata Configuration** (myComponent.js-meta.xml):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>60.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>My Component</masterLabel>
    <description>Sample Lightning Web Component</description>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
        <target>lightningCommunity__Page</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Account</object>
                <object>Contact</object>
            </objects>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

### Step 3: Component Communication

**Parent to Child** (via @api properties):
```javascript
// Parent component HTML
<template>
    <c-child-component record-id={accountId}></c-child-component>
</template>

// Child component JS
export default class ChildComponent extends LightningElement {
    @api recordId; // Public property set by parent
}
```

**Child to Parent** (via custom events):
```javascript
// Child component JS
handleEvent() {
    const event = new CustomEvent('selected', {
        detail: { recordId: this.recordId }
    });
    this.dispatchEvent(event);
}

// Parent component HTML
<template>
    <c-child-component onselected={handleSelection}></c-child-component>
</template>

// Parent component JS
handleSelection(event) {
    const recordId = event.detail.recordId;
    // Handle the event
}
```

**Sibling Communication** (via Lightning Message Service):
```javascript
// Publisher component
import { publish, MessageContext } from 'lightning/messageService';
import SAMPLE_CHANNEL from '@salesforce/messageChannel/SampleChannel__c';

export default class Publisher extends LightningElement {
    @wire(MessageContext)
    messageContext;

    publishMessage() {
        const message = { recordId: this.recordId };
        publish(this.messageContext, SAMPLE_CHANNEL, message);
    }
}

// Subscriber component
import { subscribe, MessageContext } from 'lightning/messageService';
import SAMPLE_CHANNEL from '@salesforce/messageChannel/SampleChannel__c';

export default class Subscriber extends LightningElement {
    @wire(MessageContext)
    messageContext;

    subscription = null;

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            SAMPLE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.recordId = message.recordId;
    }
}
```

### Step 4: Data Operations

**Wire Adapter** (declarative data binding):
```javascript
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';

export default class MyComponent extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    account;

    get name() {
        return this.account.data ? this.account.data.fields.Name.value : '';
    }
}
```

**Imperative Apex Call**:
```javascript
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class MyComponent extends LightningElement {
    accounts = [];

    async loadAccounts() {
        try {
            this.accounts = await getAccounts();
        } catch (error) {
            console.error('Error loading accounts', error);
        }
    }
}
```

**DML Operations** (via lightning/uiRecordApi):
```javascript
import { createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';

// Create
async createAccount() {
    const fields = {};
    fields[NAME_FIELD.fieldApiName] = 'New Account';

    const recordInput = { apiName: ACCOUNT_OBJECT.objectApiName, fields };

    try {
        const account = await createRecord(recordInput);
        console.log('Account created:', account.id);
    } catch (error) {
        console.error('Error creating account', error);
    }
}

// Update
async updateAccount(recordId) {
    const fields = {};
    fields.Id = recordId;
    fields[NAME_FIELD.fieldApiName] = 'Updated Account';

    const recordInput = { fields };

    try {
        await updateRecord(recordInput);
    } catch (error) {
        console.error('Error updating account', error);
    }
}

// Delete
async deleteAccount(recordId) {
    try {
        await deleteRecord(recordId);
    } catch (error) {
        console.error('Error deleting account', error);
    }
}
```

### Step 5: Styling with SLDS

**Use Salesforce Lightning Design System (SLDS)**:
```html
<template>
    <div class="slds-box slds-theme_default">
        <lightning-layout multiple-rows>
            <lightning-layout-item size="12" medium-device-size="6" padding="around-small">
                <lightning-input label="Name" value={name}></lightning-input>
            </lightning-layout-item>
            <lightning-layout-item size="12" medium-device-size="6" padding="around-small">
                <lightning-input label="Email" type="email" value={email}></lightning-input>
            </lightning-layout-item>
        </lightning-layout>
    </div>
</template>
```

**Component-Scoped CSS** (myComponent.css):
```css
.custom-class {
    background-color: #f3f3f3;
    padding: 1rem;
    border-radius: 0.25rem;
}

:host {
    /* Styles for the component host element */
    display: block;
}
```

**SLDS Utility Classes**:
- Spacing: `slds-m-around_medium`, `slds-p-left_small`
- Text: `slds-text-heading_medium`, `slds-text-color_error`
- Alignment: `slds-text-align_center`, `slds-float_right`
- Grid: `slds-grid`, `slds-col`, `slds-size_1-of-2`

### Step 6: Testing LWC Components

**Jest Test Example** (\_\_tests\_\_/myComponent.test.js):
```javascript
import { createElement } from 'lwc';
import MyComponent from 'c/myComponent';

describe('c-my-component', () => {
    afterEach(() => {
        // Clean up DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays name correctly', () => {
        const element = createElement('c-my-component', {
            is: MyComponent
        });
        element.name = 'Test User';
        document.body.appendChild(element);

        const p = element.shadowRoot.querySelector('p');
        expect(p.textContent).toBe('Hello, Test User!');
    });

    it('handles button click', () => {
        const element = createElement('c-my-component', {
            is: MyComponent
        });
        document.body.appendChild(element);

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        // Add assertions for expected behavior
    });
});
```

**Run Tests**:
```bash
npm run test:unit
```

### Step 7: Aura Component Structure (Legacy)

**Aura Component Bundle**:
```
force-app/main/default/aura/MyAuraComponent/
├── MyAuraComponent.cmp        # Component markup
├── MyAuraComponentController.js  # Client-side controller
├── MyAuraComponentHelper.js   # Helper functions
├── MyAuraComponent.css        # Styles
└── MyAuraComponent.design     # Design configuration
```

**Component Markup** (.cmp):
```xml
<aura:component implements="flexipage:availableForRecordHome,force:hasRecordId">
    <aura:attribute name="recordId" type="String"/>
    <aura:attribute name="name" type="String" default=""/>

    <lightning:card title="My Aura Component">
        <p>Hello, {!v.name}!</p>
        <lightning:input label="Enter Name" value="{!v.name}"/>
        <lightning:button label="Click Me" onclick="{!c.handleClick}"/>
    </lightning:card>
</aura:component>
```

**Controller** (Controller.js):
```javascript
({
    handleClick : function(component, event, helper) {
        var name = component.get("v.name");
        helper.showToast("Success", "Hello, " + name + "!", "success");
    }
})
```

**Helper** (Helper.js):
```javascript
({
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})
```

### Step 8: Performance Optimization

**Best Practices**:
- Use `@wire` for data instead of imperative calls
- Implement lazy loading for large lists
- Use Lightning Data Service (LDS) for caching
- Minimize DOM manipulations
- Debounce user input handlers
- Use `renderedCallback` sparingly
- Avoid complex computed properties in templates
- Implement pagination for large datasets
- Use base Lightning components (they're optimized)

**Debounce Example**:
```javascript
handleSearch(event) {
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this.delayTimeout = setTimeout(() => {
        this.performSearch(searchKey);
    }, 300);
}
```

## Best Practices
- Prefer LWC over Aura for new development
- Use SLDS for styling consistency
- Implement comprehensive Jest tests (>80% coverage)
- Follow component naming conventions (camelCase)
- Use Lightning Data Service (LDS) for record operations
- Implement proper error handling
- Use @api sparingly (only for public properties)
- Avoid tight coupling between components
- Document component usage in metadata
- Use composition over inheritance
- Implement accessibility (ARIA attributes)
- Optimize for mobile (responsive design)

## Reference Resources
- LWC Developer Guide: https://developer.salesforce.com/docs/component-library/documentation/en/lwc
- Component Library: https://developer.salesforce.com/docs/component-library/overview/components
- SLDS: https://www.lightningdesignsystem.com/
- Jest Testing: https://jestjs.io/docs/getting-started
- Trailhead: Lightning Web Components
