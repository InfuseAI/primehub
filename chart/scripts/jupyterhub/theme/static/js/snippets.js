var snippets = document.querySelectorAll('.snippet');

[].forEach.call(snippets, function(snippet) {
  snippet.firstChild.insertAdjacentHTML('beforebegin', '<button type="button" class="btn" data-clipboard-snippet><img class="clippy" width="13" src="/hub/static/images/clippy.svg" alt="Copy to clipboard"></button>');
});

var clipboardSnippets = new ClipboardJS('[data-clipboard-snippet]', {
    target: function(trigger) {
        return trigger.nextElementSibling;
    }
});

clipboardSnippets.on('success', function(e) {
    e.clearSelection();
});

