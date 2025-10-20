function getIndexInParent(el) {
    return Array.from(el.parentNode.children).indexOf(el);
}

function moveItem(array, fromIndex, toIndex) {
    const arrayCopy = array.slice();
    const item = arrayCopy[fromIndex];
    arrayCopy.splice(fromIndex, 1); // remove field that's moving
    arrayCopy.splice(toIndex, 0, item); // add it back
    return arrayCopy;
}
