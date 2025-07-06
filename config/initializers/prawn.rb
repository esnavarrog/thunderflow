require 'prawn'

Prawn::Font::AFM.hide_m17n_warning = true

module PrawnConfig
  PAGE_SIZE = 'A4'
  MARGIN = [50, 50, 50, 50] # [top, right, bottom, left]
  FONT_SIZE = 12
end