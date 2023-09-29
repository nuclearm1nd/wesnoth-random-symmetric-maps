(import-macros
  {: if-not
   } "../macro/macros")

(local
  {: merge!
   } (wesnoth.require :util))

(local
  default_settings
  {:size 3})

(local settings_legend
  {:size
     ["Tiny" "Small" "Normal" "Large" "Huge"]})

(if-not (rawget _G :globals)
  (rawset _G :globals
    {: default_settings
     : settings_legend
     :settings (merge! {} default_settings)}))

