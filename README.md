# Douban FM client for Emacs

This is a Douban FM client for Emacs

* Require

Emacs Verion >= 24

* Usage:

```lisp
(require 'douban-fm)
(global-set-key (kbd "M-[") 'douban-fm-play)
(global-set-key (kbd "M-]") 'douban-fm-pause)
(global-set-key (kbd "C-c C-k") 'douban-fm-stop)
```
