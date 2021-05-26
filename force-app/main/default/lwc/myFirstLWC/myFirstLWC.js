import { LightningElement, track } from 'lwc';

export default class MyFirstLWC extends LightningElement {
    
    
    name='hello'

    updateName(event){
        this.name=event.target.value;

    }
}