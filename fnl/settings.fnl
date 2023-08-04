(local dialog_wml
  (wml.load "~add-ons/Random_Symmetric_Maps/gui/settings_dialog.cfg"))

(lambda preshow [window]
  (let [{: settings : settings_legend} globals]
    (each [k v (pairs settings)]
      (let [item (. window k)]
        (set item.value v)))
    (each [k _ (pairs settings)]
      (let [item (. window k)
            set-caption
              (fn []
                (let [caption (. window (.. k "_label"))
                      v (-> window (. k) (. :value))]
                  (set caption.label
                       (-> settings_legend
                           (. k)
                           (. v)))))]
        (set item.on_modified set-caption)
        (set-caption)))))

(lambda postshow [window]
  (let [{: settings} globals]
    (each [k _ (pairs settings)]
      (tset settings k
            (-> window
                (. k)
                (. :value))))))

(lambda settings_dialog []
	(gui.show_dialog
    (wml.get_child dialog_wml :resolution)
    preshow
    postshow
    ))

{: settings_dialog
 }

