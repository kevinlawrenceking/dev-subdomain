var quill = new Quill("#snow-editor", {
    theme: "snow",
    modules: {
        toolbar: [
            [{
                font: []
            }, {
                size: ['13px', '15px', '16px']
            }],
            ["bold", "italic", "underline", "strike"],
            [{
                color: []
            }, {
                background: []
            }],

            [{
                header: [!1, 1, 2, 3, 4, 5, 6]
            }, "blockquote", "code-block"],
            [{
                list: "ordered"
            }, {
                list: "bullet"
            }, {
                indent: "-1"
            }, {
                indent: "+1"
            }],
            ["direction", {
                align: []
            }],

            ["clean"]
        ]
    }
});

// Strip color and background-color from pasted content to prevent
// invisible text (e.g. white text pasted from dark-background websites).
quill.clipboard.addMatcher(Node.ELEMENT_NODE, function(node, delta) {
    delta.ops = delta.ops.map(function(op) {
        if (op.attributes) {
            delete op.attributes.color;
            delete op.attributes.background;
        }
        return op;
    });
    return delta;
});
