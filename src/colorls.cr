require "./colorls/version"
require "./colorls/types"
require "./colorls/color_map"
require "./colorls/string_utils"
require "./colorls/yaml_config"
require "./colorls/file_info"
require "./colorls/git"
require "./colorls/layout"
require "./colorls/core"
require "./colorls/flags"

lib LibC
  fun strxfrm(dest : Char*, src : Char*, n : SizeT) : SizeT
  fun setlocale(category : Int32, locale : Char*) : Char*
  LC_COLLATE = 3
end

module Colorls
  lib LibC
    struct Winsize
      ws_row : UInt16
      ws_col : UInt16
      ws_xpixel : UInt16
      ws_ypixel : UInt16
    end

    TIOCGWINSZ = 0x5413

    fun ioctl(fd : Int32, request : UInt64, ...) : Int32
  end

  def self.terminal_width : Int32
    ws = LibC::Winsize.new
    if LibC.ioctl(1, LibC::TIOCGWINSZ, pointerof(ws)) == 0 && ws.ws_col > 0
      ws.ws_col.to_i32
    else
      ENV["COLUMNS"]?.try(&.to_i32?) || 80
    end
  end

  class_getter screen_width : Int32 = terminal_width
end
