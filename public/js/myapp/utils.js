String.prototype.hashCode = function () {
    var h = 0, i = 0, l = this.length;
    if (l === 0) return h;
    for (; i < l; i++) {
        h = ((h << 5) - h) + this.charCodeAt(i);
        h |= 0; // Convert to 32bit integer
    }
    return h;
};