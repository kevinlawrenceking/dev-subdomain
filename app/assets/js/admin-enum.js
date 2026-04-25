/**
 * Admin Enum Dashboard - Inline CRUD for lookup tables
 * Depends on: Bootstrap 4+, MDI icons
 */
(function () {
    'use strict';

    // -- CSRF token from <meta> tag -------------------------------------------
    var csrfToken = '';
    var metaEl = document.querySelector('meta[name="csrf-token"]');
    if (metaEl) csrfToken = metaEl.getAttribute('content');

    // -- Helpers ---------------------------------------------------------------

    /** POST JSON via fetch, returns parsed JSON promise */
    function ajaxPost(url, body) {
        var formData = new FormData();
        Object.keys(body).forEach(function (k) {
            formData.append(k, body[k]);
        });
        return fetch(url, {
            method: 'POST',
            headers: { 'X-CSRF-Token': csrfToken },
            body: formData,
            credentials: 'same-origin'
        }).then(function (res) { return res.json(); });
    }

    /** Find closest ancestor matching selector */
    function closest(el, selector) {
        while (el && el !== document) {
            if (el.matches(selector)) return el;
            el = el.parentElement;
        }
        return null;
    }

    /** Get the panel element from any child */
    function getPanel(el) {
        return closest(el, '.admin-enum-panel');
    }

    /** Get the row list container inside a panel */
    function getList(panel) {
        return panel.querySelector('.admin-enum-list');
    }

    /** Update the count badge on a panel */
    function updateBadge(panel, delta) {
        var badge = panel.querySelector('[data-role="count"]');
        if (!badge) return;
        var current = parseInt(badge.textContent, 10) || 0;
        badge.textContent = Math.max(0, current + delta);
    }

    /** Remove "No items" placeholder if present */
    function removeEmpty(list) {
        var empty = list.querySelector('.admin-enum-empty');
        if (empty) empty.remove();
    }

    /** Add "No items" placeholder if list is now empty */
    function addEmptyIfNeeded(list) {
        var rows = list.querySelectorAll('.admin-enum-row');
        if (rows.length === 0 && !list.querySelector('.admin-enum-empty')) {
            var div = document.createElement('div');
            div.className = 'admin-enum-empty text-center text-muted py-3';
            div.textContent = 'No items';
            list.appendChild(div);
        }
    }

    /** Show an inline error message at the top of the list */
    function showError(list, msg) {
        clearError(list);
        var div = document.createElement('div');
        div.className = 'admin-enum-error';
        div.textContent = msg;
        list.insertBefore(div, list.firstChild);
        setTimeout(function () { if (div.parentNode) div.remove(); }, 5000);
    }

    /** Clear inline error from a list */
    function clearError(list) {
        var err = list.querySelector('.admin-enum-error');
        if (err) err.remove();
    }

    /** Build a parent <select> from embedded JSON data */
    function buildParentSelect(panel, selectedId) {
        var dataEl = panel.querySelector('.parent-options-data');
        if (!dataEl) return null;
        var options;
        try { options = JSON.parse(dataEl.textContent); } catch (e) { return null; }
        if (!options || !options.length) return null;

        var label = panel.getAttribute('data-parent-label') || 'Parent';
        var sel = document.createElement('select');
        sel.className = 'admin-enum-parent-select';
        sel.title = label;

        var blank = document.createElement('option');
        blank.value = '';
        blank.textContent = '-- ' + label + ' --';
        sel.appendChild(blank);

        options.forEach(function (opt) {
            var o = document.createElement('option');
            o.value = opt.id;
            o.textContent = opt.name;
            if (selectedId && String(opt.id) === String(selectedId)) o.selected = true;
            sel.appendChild(o);
        });

        return sel;
    }

    /** Check if a panel currently has an active input row */
    function hasActiveInput(panel) {
        return !!panel.querySelector('.admin-enum-input-row');
    }

    /** Build a standard row HTML element */
    function buildRowEl(pk, name, parentId, parentName, panel) {
        var hasParent = panel.getAttribute('data-has-parent') === 'true';
        var readOnly = panel.getAttribute('data-read-only') === 'true';

        var row = document.createElement('div');
        row.className = 'admin-enum-row d-flex align-items-center px-3 py-2';
        row.setAttribute('data-pk', pk);
        if (hasParent && parentId) row.setAttribute('data-parent-id', parentId);

        var nameSpan = document.createElement('span');
        nameSpan.className = 'admin-enum-name flex-grow-1';
        nameSpan.title = name;
        nameSpan.textContent = name;
        row.appendChild(nameSpan);

        if (hasParent && parentName) {
            var pSpan = document.createElement('span');
            pSpan.className = 'admin-enum-parent text-muted small me-2';
            pSpan.textContent = parentName;
            row.appendChild(pSpan);
        }

        if (!readOnly) {
            var editBtn = document.createElement('button');
            editBtn.className = 'btn btn-sm btn-link p-0 me-1';
            editBtn.setAttribute('data-action', 'edit');
            editBtn.title = 'Edit';
            editBtn.innerHTML = '<i class="mdi mdi-square-edit-outline"></i>';
            row.appendChild(editBtn);

            var delBtn = document.createElement('button');
            delBtn.className = 'btn btn-sm btn-link p-0 text-danger';
            delBtn.setAttribute('data-action', 'delete');
            delBtn.title = 'Delete';
            delBtn.innerHTML = '<i class="mdi mdi-trash-can-outline"></i>';
            row.appendChild(delBtn);
        }

        return row;
    }

    // -- ADD flow --------------------------------------------------------------

    function startAdd(panel) {
        if (hasActiveInput(panel)) return; // prevent double-click

        var list = getList(panel);
        var enumId = panel.getAttribute('data-enum-id');
        var hasParent = panel.getAttribute('data-has-parent') === 'true';

        removeEmpty(list);

        var inputRow = document.createElement('div');
        inputRow.className = 'admin-enum-input-row';

        var nameInput = document.createElement('input');
        nameInput.type = 'text';
        nameInput.placeholder = 'New name...';
        nameInput.setAttribute('maxlength', '100');
        inputRow.appendChild(nameInput);

        var parentSel = null;
        if (hasParent) {
            parentSel = buildParentSelect(panel, '');
            if (parentSel) inputRow.appendChild(parentSel);
        }

        var saveBtn = document.createElement('button');
        saveBtn.className = 'btn btn-sm btn-success';
        saveBtn.textContent = 'Save';
        inputRow.appendChild(saveBtn);

        var cancelBtn = document.createElement('button');
        cancelBtn.className = 'btn btn-sm btn-secondary';
        cancelBtn.textContent = 'Cancel';
        inputRow.appendChild(cancelBtn);

        list.insertBefore(inputRow, list.firstChild);
        nameInput.focus();

        function doSave() {
            var val = nameInput.value.trim();
            if (!val) { nameInput.focus(); return; }

            saveBtn.disabled = true;
            var body = { enum_id: enumId, name: val };
            if (parentSel && parentSel.value) body.parent_id = parentSel.value;

            ajaxPost('/ajax/admin-enum-add.cfm', body).then(function (resp) {
                if (resp.success) {
                    var parentName = parentSel ? parentSel.options[parentSel.selectedIndex].text : '';
                    if (parentSel && !parentSel.value) parentName = '';
                    var newRow = buildRowEl(resp.data.id, val, body.parent_id || '', parentName, panel);
                    inputRow.replaceWith(newRow);
                    updateBadge(panel, 1);
                } else {
                    showError(list, resp.message || 'Add failed.');
                    saveBtn.disabled = false;
                }
            }).catch(function () {
                showError(list, 'Network error. Please try again.');
                saveBtn.disabled = false;
            });
        }

        saveBtn.addEventListener('click', doSave);
        nameInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') { e.preventDefault(); doSave(); }
            if (e.key === 'Escape') cancelBtn.click();
        });
        cancelBtn.addEventListener('click', function () {
            inputRow.remove();
            addEmptyIfNeeded(list);
        });
    }

    // -- EDIT flow -------------------------------------------------------------

    function startEdit(row) {
        var panel = getPanel(row);
        if (!panel) return;

        // Don't allow edit if there's already an active input row in this panel
        if (hasActiveInput(panel)) return;

        var list = getList(panel);
        var enumId = panel.getAttribute('data-enum-id');
        var hasParent = panel.getAttribute('data-has-parent') === 'true';
        var pk = row.getAttribute('data-pk');
        var currentName = row.querySelector('.admin-enum-name').textContent;
        var currentParentId = row.getAttribute('data-parent-id') || '';

        var inputRow = document.createElement('div');
        inputRow.className = 'admin-enum-input-row';

        var nameInput = document.createElement('input');
        nameInput.type = 'text';
        nameInput.value = currentName;
        nameInput.setAttribute('maxlength', '100');
        inputRow.appendChild(nameInput);

        var parentSel = null;
        if (hasParent) {
            parentSel = buildParentSelect(panel, currentParentId);
            if (parentSel) inputRow.appendChild(parentSel);
        }

        var saveBtn = document.createElement('button');
        saveBtn.className = 'btn btn-sm btn-success';
        saveBtn.textContent = 'Save';
        inputRow.appendChild(saveBtn);

        var cancelBtn = document.createElement('button');
        cancelBtn.className = 'btn btn-sm btn-secondary';
        cancelBtn.textContent = 'Cancel';
        inputRow.appendChild(cancelBtn);

        var deleteBtn = document.createElement('button');
        deleteBtn.className = 'btn btn-sm btn-link p-0 text-danger ms-2';
        deleteBtn.title = 'Delete';
        deleteBtn.innerHTML = '<i class="mdi mdi-trash-can-outline"></i>';
        inputRow.appendChild(deleteBtn);

        row.style.display = 'none';
        row.parentNode.insertBefore(inputRow, row);
        nameInput.focus();
        nameInput.select();

        function doSave() {
            var val = nameInput.value.trim();
            if (!val) { nameInput.focus(); return; }

            saveBtn.disabled = true;
            var body = { enum_id: enumId, pk_value: pk, name: val };
            if (parentSel && parentSel.value) body.parent_id = parentSel.value;

            ajaxPost('/ajax/admin-enum-update.cfm', body).then(function (resp) {
                if (resp.success) {
                    // Update the row in place
                    row.querySelector('.admin-enum-name').textContent = val;
                    row.querySelector('.admin-enum-name').title = val;
                    if (hasParent && parentSel) {
                        row.setAttribute('data-parent-id', parentSel.value || '');
                        var pSpan = row.querySelector('.admin-enum-parent');
                        if (pSpan) {
                            pSpan.textContent = parentSel.value
                                ? parentSel.options[parentSel.selectedIndex].text
                                : '';
                        }
                    }
                    inputRow.remove();
                    row.style.display = '';
                } else {
                    showError(list, resp.message || 'Update failed.');
                    saveBtn.disabled = false;
                }
            }).catch(function () {
                showError(list, 'Network error. Please try again.');
                saveBtn.disabled = false;
            });
        }

        saveBtn.addEventListener('click', doSave);
        nameInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') { e.preventDefault(); doSave(); }
            if (e.key === 'Escape') cancelBtn.click();
        });
        cancelBtn.addEventListener('click', function () {
            inputRow.remove();
            row.style.display = '';
        });

        deleteBtn.addEventListener('click', function () {
            inputRow.remove();
            row.style.display = '';
            startDelete(row);
        });
    }

    // -- DELETE flow -----------------------------------------------------------

    function startDelete(row) {
        var panel = getPanel(row);
        if (!panel) return;
        var list = getList(panel);
        var enumId = panel.getAttribute('data-enum-id');
        var pk = row.getAttribute('data-pk');
        var name = row.querySelector('.admin-enum-name').textContent;

        // Build inline confirmation
        var confirm = document.createElement('div');
        confirm.className = 'admin-enum-confirm';

        var text = document.createElement('span');
        text.className = 'confirm-text';
        text.textContent = 'Delete \u201c' + name + '\u201d?';
        confirm.appendChild(text);

        var yesBtn = document.createElement('button');
        yesBtn.className = 'btn btn-sm btn-danger';
        yesBtn.textContent = 'Yes';
        confirm.appendChild(yesBtn);

        var noBtn = document.createElement('button');
        noBtn.className = 'btn btn-sm btn-secondary';
        noBtn.textContent = 'No';
        confirm.appendChild(noBtn);

        row.style.display = 'none';
        row.parentNode.insertBefore(confirm, row);

        yesBtn.addEventListener('click', function () {
            yesBtn.disabled = true;
            ajaxPost('/ajax/admin-enum-delete.cfm', {
                enum_id: enumId,
                pk_value: pk
            }).then(function (resp) {
                if (resp.success) {
                    confirm.remove();
                    row.classList.add('fade-out');
                    setTimeout(function () {
                        row.remove();
                        updateBadge(panel, -1);
                        addEmptyIfNeeded(list);
                    }, 350);
                } else {
                    showError(list, resp.message || 'Delete failed.');
                    confirm.remove();
                    row.style.display = '';
                }
            }).catch(function () {
                showError(list, 'Network error. Please try again.');
                confirm.remove();
                row.style.display = '';
            });
        });

        noBtn.addEventListener('click', function () {
            confirm.remove();
            row.style.display = '';
        });
    }

    // -- Event delegation on the grid ------------------------------------------

    document.addEventListener('click', function (e) {
        var target = e.target;

        // Resolve clicks on <i> inside buttons
        var btn = closest(target, '[data-action]');
        if (!btn) return;

        var action = btn.getAttribute('data-action');
        var panel = getPanel(btn);
        if (!panel) return;

        // Ignore actions on read-only panels (belt-and-suspenders)
        if (panel.getAttribute('data-read-only') === 'true' && action !== 'add') return;

        if (action === 'add') {
            if (panel.getAttribute('data-read-only') === 'true') return;
            startAdd(panel);
        } else if (action === 'edit') {
            var row = closest(btn, '.admin-enum-row');
            if (row) startEdit(row);
        } else if (action === 'delete') {
            var delRow = closest(btn, '.admin-enum-row');
            if (delRow) startDelete(delRow);
        }
    });

})();
