class calculator {
    constructor(previoustext, currenttext) {
        this.previoustext = previoustext;
        this.currenttext = currenttext;
    }
    clear() { }
    delete() { }
}


const numberbuttons = document.querySelectorAll('[data-number]')
const operationbuttons = document.querySelectorAll('[data-operation]')
const equalbutton = document.querySelector('[data-equal]')
const deletebutton = document.querySelector('[data-delete]')
const allclearbutton = document.querySelector('[data-allclear]')
const previoustext = document.querySelector('[data-previous]')
const currenttext = document.querySelector('[data-current]')