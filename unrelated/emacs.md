# OCaml とは全く関係ない emacs テクメモ

## Kill Ring

`kill` した文字列一覧

* `(popup-menu 'yank-menu)`
* `anything-show-kill-ring` (requires `anything`)

## `list-buffers` つまり `C-x C-b` の挙動が変った死ね

予期したバッファレイアウトにならなくなったので死ぬ。そこで

```
(global-change-key (kbd "<backtab>") 'shell-round-visit-buffer)

(defun good-old-list-buffers () 
  (interactive)
  (if (not (string-equal (buffer-name (current-buffer)) "*Buffer List*"))
      (save-selected-window (buffer-menu-other-window))))
(global-change-key (kbd "C-x C-b") 'good-old-list-buffers)
```

## Interesting functions

### `(bounds-of-thing-at-point THING)`

```
(defun hogehogera ()
   (interactive)
   (let* ( (bds (bounds-of-thing-at-point 'filename))
          (p1 (car bds))
	  (p2 (cdr bds)) )
	      (message "%d %d" p1 p2)))
```
