;;; init-kaomoji.el --- kaomoji -*- lexical-binding: t -*-
;;; Commentary:
;; fork form https://github.com/kuanyui/kaomoji.el
;;; Code:

(defun spike-leung/kaomoji--search (query)
  "Search `spike-leung/kaomoji-table' for QUERY with fuzzy matching."
  (let ((results '()))
    (dolist (entry spike-leung/kaomoji-table)
      (when (cl-some (lambda (keyword)
                       (string-match-p (regexp-quote (downcase query))
                                       (downcase keyword)))
                     (car entry))
        (push (cons (string-join (car entry) ", ") (cdr entry)) results)))
    (nreverse results)))

(defun spike-leung/kaomoji--annotate (cand)
  "Annotate candidate CAND with its kaomoji in a separate column with styling."
  (when-let ((entry (assoc cand spike-leung/kaomoji--candidates)))
    (concat
     (propertize " " 'display '(space :align-to 50))
     (propertize
      (cdr entry)
      'face
      (cond
       ((fboundp 'modus-themes-get-color-value)
        `(:foreground ,(modus-themes-get-color-value `rust)))
       ((fboundp 'ef-themes-get-color-value)
        `(:foreground ,(ef-themes-get-color-value `rust)))
       (t
        nil))))))

(defvar spike-leung/kaomoji--candidates nil
  "List of candidates for consult.")

(defun spike-leung/kaomoji--select (prompt choices)
  "PROMPT user to select from CHOICES with consult support."
  (setq spike-leung/kaomoji--candidates choices)
  (if (fboundp 'consult--read)
      (consult--read
       (mapcar #'car choices)
       :prompt prompt
       :sort nil
       :require-match t
       :history 'spike-leung/kaomoji--history
       :annotate #'spike-leung/kaomoji--annotate
       :category 'spike-leung/kaomoji)
    (completing-read prompt choices nil t)))

;;;###autoload
(defun spike-leung/kaomoji (query)
  "Interactively select and insert a kaomoji.
With prefix arg or when QUERY is provided, search kaomoji by name."
  (interactive
   (list (when current-prefix-arg
           (read-string "Search kaomoji: "))))
  (let* ((choices (if query
                      (spike-leung/kaomoji--search query)
                    (mapcar (lambda (entry)
                              (cons (string-join (car entry) ", ") (cdr entry)))
                            spike-leung/kaomoji-table)))
         (selected (spike-leung/kaomoji--select "Select kaomoji: " choices)))
    (insert (alist-get selected choices nil nil #'equal))))

(defvar spike-leung/kaomoji-table
  '(;; Joy
    (("happy")                                  . "σ(´∀｀*)")
    (("happy_1")                                  . "(´｡• ᵕ •｡`)")
    (("happy_2")                                  . "(„• ᴗ •„)")
    ;; Love
    (("heart")                                  . "♥")
    (("love")                                   . "(´｡• ᵕ •｡`) ♡")
    (("love_1")                                   . "(´｡• ω •｡`) ♡")
    ;; Cheers
    (("yeah")                                  . "(๑˃ᴗ˂)ﻭ")
    (("yeah_1")                                  . "(๑>◡<๑)")
    (("cheers")                                 . "(ﾉ>ω<)ﾉ")
    (("cheers_1")                                 . "⸜(*ˊᗜˋ*)⸝")
    (("cheers_2")                                 . "｡:.ﾟヽ(*´∀`)ﾉﾟ.:｡")
    (("cheers_3")                                 . "ヾ(*´∀ ˋ*)ﾉ")
    ;; Shy
    (("shy")                                    . "( 〃▽〃)")
    (("shy_1")                                    . "(*/ω＼)")
    (("don't see")                              . "(つд⊂)")
    (("don't see_1")                              . "(/ω＼)")
    ;; cry
    (("cry")                                    . "(ᗒᗣᗕ)՞")
    (("cry_1")                                    . "( ╥ω╥ )")
    (("cry_2")                                    . "(つω`｡)")
    (("cry_3")                                    . "(T_T)")
    (("cry_4")                                    . "(｡•́︿•̀｡)")
    (("cry_5")                                    . "(╥﹏╥)")
    (("cry_6")                                    . "(ಥ﹏ಥ)")
    ;; pain
    (("pain")                                   . "(×_×)")
    (("pain_1")                                   . "_:(´ཀ`」 ∠):_")
    ;; doesn't matter
    (("doesn't matter")                         . "┐(￣ヘ￣)┌")
    (("doesn't matter_1")                         . "┐(︶▽︶)┌")
    (("doesn't matter_2")                         . "┐(シ)┌")
    (("alas" "无奈")                            . "╮(╯_╰)╭")
    ;; anger
    (("angry")                                  . "(・`ω´・)")
    (("angry_1")                                  . "ヽ( `д´*)ノ")
    (("fuck you")                               . "凸(￣ヘ￣)")
    ;; confuse
    (("confuse")                                . "(＠_＠)")
    (("confuse_1")                                . "(・・?)")
    ;; doubt
    (("doubt")                                  . "(￢_￢)")
    (("doubt_1")                                  . "(￢‿￢ )")
    (("doubt_2")                                  . "(„¬ᴗ¬„)")
    (("doubt_3")                                  . "(→_→)")
    (("doubt_4")                                  . "(←_←)")
    ;; wink
    (("wink")                                   . "(｡•̀ᴗ-)✧")
    (("wink_1")                                   . "(>ᴗ•)")
    ;; surprise, shock
    (("shocked")                                . "(⊙_⊙)")
    (("shocked_1")                                . "(O_O;)")
    (("shocked_2")                                . "(｡ŏ_​ŏ)")
    (("shocked_3")                                . "(ﾟдﾟ)")
    ;; greeting
    (("greeting")                               . "(*・ω・)ﾉ")
    (("greeting_1")                               . "(´• ω •`)ﾉ")
    (("greeting_2")                               . "(・∀・)ノ")
    (("greeting_3")                               . "(o´ω`o)ﾉ")
    ;; hug
    (("hug")                                    . "(⊃｡•́‿•̀｡)⊃")
    ;; hide
    (("hide")                                   . "​​|･ω･)")
    (("hide_1")                                   . "|ω･)ﾉ)")
    (("hide_2")                                   . "ヾ(･|")
    ;; writing
    (("writing")                                . "__φ(．．)")
    (("writing_1")                                . "__φ(。。)")
    (("writing_2")                                . "___〆(・∀・)")
    ;; bear
    (("bear")                                   . "ʕ •ᴥ• ʔ")
    (("bear_1")                                   . "ʕ ᵔᴥᵔ ʔ")
    ;; music
    (("music")                                  . "ヽ(o´∀`)ﾉ♪♬")
    (("music_1")                                  . "(￣▽￣)/♫•*¨*•.¸¸♪")
    (("music_2")                                  . "♬♫♪◖(● o ●)◗♪♫♬")
    (("dance")                                  . "⁽⁽◝( • ω • )◜⁾⁾")
    ;; others
    (("lazy")                                   . "_​(:3 」∠)_​")
    (("relax")                                  . "(´-ω-｀)")
    (("sad")                                    . "(´･_​･`)")
    (("owo")                                    . "(´・ω・`)")
    (("really?")                                . "(≖ᴗ≖๑)")
    (("facepalm" "无语")                        . "(－‸ლ)")
    (("come here")                              . "ლ(´ڡ`ლ)")))

(provide 'init-kaomoji)
;;; init-kaomoji.el ends here
