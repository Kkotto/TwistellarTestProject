import { LightningElement, api } from 'lwc';

export default class ServiceIndexDisplay extends LightningElement {
    @api indexFromParent;

    get position() {
        return this.indexFromParent + 1;
    }
}