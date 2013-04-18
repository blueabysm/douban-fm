# Douban FM client for Emacs

This is a Douban FM client for Emacs

## Require

Emacs Verion >= 24
[![](emacs-web)](https://github.com/nicferrier/emacs-web)
[![](mplayer)](http://www.mplayerhq.hu/design7/news.html)

## Usage:

```lisp
(require 'douban-fm)
(global-set-key (kbd "M-[") 'douban-fm-play)
(global-set-key (kbd "M-]") 'douban-fm-pause)
(global-set-key (kbd "C-c C-k") 'douban-fm-stop)
```
