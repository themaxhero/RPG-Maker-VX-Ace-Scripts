#===============================================================================
# Max Hero's Party Manager ACE
#-------------------------------------------------------------------------------
# made by: Marcelo "maxhero" Amancio
# You can use this script in any project that you want as long as you put
# `Marcelo "maxhero" Amancio` on your project's credit.
#===============================================================================

#===============================================================================
# Add :party_manager to $maxhero_scripts for integration with future scripts
#===============================================================================
$maxhero_scripts =
  $maxhero_scripts ? $maxhero_scripts << :party_manager : [:party_manager]

#===============================================================================
# ** Vocab
#-------------------------------------------------------------------------------
# Adding to Vocab related stuff
#===============================================================================

module Vocab
  PMWhichActorAdd = "Which actor do you want to add?"
  PMWhichActorRem = "Which actor do you want to remove?"
  PMAreYouSure = "Are you sure?"
  PMYes = "Yes! Yes! Yes!"
  PMNo = "No! No! No!"
  PMNoneToAdd = "There's no actor to add"
  PMNoneToRemove = "There's no actor to remove"
end

#===============================================================================
# ** SceneManager
#-------------------------------------------------------------------------------
# Changing SceneManager a little to accept parameters for scenes.
#===============================================================================

module SceneManager
  def self.call(scene_class, *args)
    @stack.push(@scene)
    @scene = scene_class.new(*args)
  end
end

#===============================================================================
# ** DataManager
#-------------------------------------------------------------------------------
# Changing DataManager a little to save blocked and locked actors.
#===============================================================================
module DataManager
  class << self
    #---------------------------------------------------------------------------
    # * Create Save Contents
    #---------------------------------------------------------------------------
    alias mhpm_msc make_save_contents
    def self.make_save_contents
      contents = mhpm_msc
      contents[:mhpm_available_actors] = PartyManager.available_actors
      contents[:mhpm_locked_actors]    = PartyManager.locked_actors
      contents
    end
    #---------------------------------------------------------------------------
    # * Extract Save Contents
    #---------------------------------------------------------------------------
    alias mhpm_msc extract_save_contents
    def self.extract_save_contents(contents)
      mhpm_msc(contents)
      PartyManager.available_actors = contents[:mhpm_available_actors]
      PartyManager.locked_actors    = contents[:mhpm_locked_actors]
    end
  end
end

#===============================================================================
# ** PartyManager 
#-------------------------------------------------------------------------------
# This module is the API where you can comunicate with the script.
#===============================================================================

module PartyManager
  #-----------------------------------------------------------------------------
  # - Edit @@available_actors value to set initial available actors on the start 
  # of the game.
  # - Edit @@locked_actors value to set initial locked on party actors.
  #-----------------------------------------------------------------------------
  @@available_actors = [2, 3, 4, 5, 6, 7, 8, 9, 10]
  @@locked_actors = [1]
  
  #-----------------------------------------------------------------------------
  # * Available Actors
  #-----------------------------------------------------------------------------
  def self.available_actors
    return @@available_actors 
  end
  
  #-----------------------------------------------------------------------------
  # * Locked Actors
  #-----------------------------------------------------------------------------
  def self.locked_actors
    return @@locked_actors 
  end
  
  #-----------------------------------------------------------------------------
  # * Available Actors
  #-----------------------------------------------------------------------------
  def self.available_actors=(value)
    @@available_actors = value
  end
  
  #-----------------------------------------------------------------------------
  # * Locked Actors
  #-----------------------------------------------------------------------------
  def self.locked_actors=(value)
    @@locked_actors = value
  end
  
  #-----------------------------------------------------------------------------
  # * Lock Actor
  #-----------------------------------------------------------------------------
  def self.lock_actor(actor_id)
    if @@locked_actors.include? actor_id
      return
    else
      @@locked_actors.push(actor_id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Unlock Actor
  #-----------------------------------------------------------------------------
  def self.unlock_actor(actor_id)
    if @@locked_actors.include? actor_id
      @@locked_actors -= [actor_id]
    else
      return
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Make Available
  #-----------------------------------------------------------------------------
  def self.make_available(actor_id)
    if @@available_actors.include? actor_id
      return
    else
      @@available_actors.push(actor_id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Make Unavailable
  #-----------------------------------------------------------------------------
  def self.make_unavailable(actor_id)
    if @@available_actors.include? actor_id
      @@available_actors -= [actor_id]
    else
      return
    end
  end
end

#===============================================================================
# ** Character Ani(mation)
#-------------------------------------------------------------------------------
# Animation of character walking animation for window
#-------------------------------------------------------------------------------

class Character_Ani
  
  attr_accessor :filename, :index, :start_x, :end_x
  attr_accessor :start_y, :end_y, :sprite, :frame
  
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize(filename, index, viewport)
    @counter = 0
    @frame = 0
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = Cache.character(filename)
    sign = filename[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = sprite.bitmap.width / 3
      ch = sprite.bitmap.height / 4
    else
      cw = sprite.bitmap.width / 12
      ch = sprite.bitmap.height / 8
      anime_x = (sprite.bitmap.width / 4) * (index % 4)
      anime_y = (sprite.bitmap.height / 2) * (index / 4).ceil
    end
    
    @sprite.src_rect.width = cw
    @sprite.src_rect.height = ch
    
    if (anime_x.nil? && anime_y.nil?)
      @start_x = @start_y = 0
      @end_x = cw * 3
      @end_y = ch
    else
      @start_x = anime_x
      @start_y = anime_y
      @end_x = @start_x + (cw * 3)
      @end_y = @start_y + ch
    end
    
    @sprite.src_rect.y = @start_y
  end
  
  #-----------------------------------------------------------------------------
  # * X =
  #-----------------------------------------------------------------------------
  def x=(value)
    @sprite.x = value
  end
  
  #-----------------------------------------------------------------------------
  # * Y =
  #-----------------------------------------------------------------------------
  def y=(value)
    @sprite.y = value
  end
  
  #-----------------------------------------------------------------------------
  # * Z =
  #-----------------------------------------------------------------------------
  def z=(value)
    @sprite.z = value
  end
  
  #-----------------------------------------------------------------------------
  # * Width
  #-----------------------------------------------------------------------------
  def width
    @sprite.width
  end
  
  #-----------------------------------------------------------------------------
  # * Height
  #-----------------------------------------------------------------------------
  def height
    @sprite.height
  end
  
  #-----------------------------------------------------------------------------
  # * Viewport =
  #-----------------------------------------------------------------------------
  def viewport=(value)
    @sprite.viewport = value
  end
  
  #-----------------------------------------------------------------------------
  # * Viewport
  #-----------------------------------------------------------------------------
  def viewport
    @sprite.viewport
  end
  
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  def update
    @counter = (@counter + 1) % 20
    @frame = (@frame + 1) % 4 if @counter == 0
    if @frame == 3
      @sprite.src_rect.x = @start_x + (@sprite.src_rect.width * 1)
    else
      @sprite.src_rect.x = @start_x + (@sprite.src_rect.width * @frame)
    end
  end
end

#===============================================================================
# ** Window_PMStatus
#-------------------------------------------------------------------------------
# Window_PMStatus is basically a Window_Status with some few modifications.
# Window_PMStatus is also responsible for drawing selected actor's stuff.
#===============================================================================
class Window_PMStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    top_offset = fitting_height(2)
    left_offset = 160
    width = Graphics.width - left_offset
    height = Graphics.height - top_offset
    super(left_offset, top_offset, width, height)
    @actor = actor
    refresh
    activate
  end
  #--------------------------------------------------------------------------
  # * actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
  end
  #--------------------------------------------------------------------------
  # * Line Color
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # * Draw Horz Line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # * Draw Basic Info
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + line_height * 0)
    draw_actor_icons(@actor, x, y + line_height * 1)
    draw_actor_hp(@actor, x, y + line_height * 2)
    draw_actor_mp(@actor, x, y + line_height * 3)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_block1   (line_height * 0)
    draw_horz_line(line_height * 1)
    draw_block2   (line_height * 2)
    draw_horz_line(line_height * 6)
    draw_block3   (line_height * 7)
    draw_horz_line(line_height * 13)
  end
  #--------------------------------------------------------------------------
  # * Draw Block 1
  #--------------------------------------------------------------------------
  def draw_block1(y)
    draw_actor_name(@actor, 4, y)
    draw_actor_class(@actor, 100, y)
    draw_actor_nickname(@actor, 210, y)
  end
  #--------------------------------------------------------------------------
  # * Draw Block 2
  #--------------------------------------------------------------------------
  def draw_block2(y)
    draw_actor_face(@actor, 8, y)
    draw_basic_info(136, y)
  end
  #--------------------------------------------------------------------------
  # * Draw Block 3
  #--------------------------------------------------------------------------
  def draw_block3(y)
    draw_parameters(8, y)
    draw_equipments(172, y)
  end
  #--------------------------------------------------------------------------
  # * Draw Parameters
  #--------------------------------------------------------------------------
  def draw_parameters(x, y)
    6.times {|i| draw_actor_param(@actor, x, y + line_height * i, i + 2) }
  end
  #--------------------------------------------------------------------------
  # * Draw Equipments
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    @actor.equips.each_with_index do |item, i|
      draw_item_name(item, x, y + line_height * i)
    end
  end
end

#===============================================================================
# ** Window_PMDialogBack
#===============================================================================
class Window_PMDialogBack < Window_Base
  def initialize
    x = (Graphics.width / 2) - (window_width / 2)
    y = (Graphics.height / 2) - (window_height / 2)
    super(x, y, window_width, window_height)
  end
  def refresh
    self.contents.clear
    draw_text(0, 0, window_width, 32, Vocab::PMAreYouSure)
  end
  def window_width
    Graphics.width - (Graphics.width * 0.2)
  end
  def window_height
    return fitting_height(4)
  end
end


#===============================================================================
# ** Window_PMDialog
#-------------------------------------------------------------------------------
# This class shows a "Yes" or "No" dialog.
#===============================================================================

class Window_PMDialog < Window_Command
  
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize(on_accept, on_cancel)
    x = (Graphics.width / 2) - (window_width / 2)
    y = (Graphics.height / 2) - 16
    super(x, y)
    set_handler(:yes, on_accept)
    set_handler(:no, on_cancel)
    set_handler(:cancel, on_cancel)
    self.opacity = 0
  end
  
  #-----------------------------------------------------------------------------
  # * Make Command List
  #-----------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::PMYes, :yes)
    add_command(Vocab::PMNo, :no)
  end
  
  #-----------------------------------------------------------------------------
  # * Window Width
  #-----------------------------------------------------------------------------
  def window_width
    return 160
  end
  
  #-----------------------------------------------------------------------------
  # * Window Height
  #-----------------------------------------------------------------------------
  def window_height
    return fitting_height(4)
  end
end

#===============================================================================
# ** Window_PMCommand 
#-------------------------------------------------------------------------------
# Window_PMCommand is where the actors names and character are shown.
#===============================================================================

class Window_PMCommand < Window_Command
  
  attr_accessor :actors
  
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize(actors, behaviour, superior)
    @actors = actors
    @behaviour = behaviour
    @handler = {}
    @characters = []
    @sprite = 0
    @superior = superior
    super(0, 72)
    set_handlers
    prepare_characters
  end
  
  #-----------------------------------------------------------------------------
  # * Make Command List
  #-----------------------------------------------------------------------------
  def make_command_list
    for id in @actors
      actor = $game_actors[id]
      
      # Unless actor does not exist.
      unless actor.nil?
        
        # Getting name and creating a bind with the symbol from the name.
        actor_name = actor.name
        actor_symbol = actor_name.to_sym
        
        # Add command to the list.
        add_command(actor_name, actor_symbol)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Set Handlers
  #-----------------------------------------------------------------------------
  def set_handlers
    for id in @actors
      actor = $game_actors[id]
        
      # Unless actor does not exist.
      unless actor.nil?
        actor_symbol = actor.name.to_sym
        
        # Get the proper handler based on which behaviour is being used.
        proc =
          case @behaviour
          when :add
            Proc.new{
              @superior.open_dialog(
                Proc.new{
                  $game_party.add_actor(@superior.actor_id_from_cmd)
                  SceneManager.call(Scene_Map)
                },
                Proc.new{
                  @superior.cancel_dialog
                }
              )
            }
          when :rem
            Proc.new{
              @superior.open_dialog(
                Proc.new{
                  $game_party.remove_actor(@superior.actor_id_from_cmd)
                  SceneManager.call(Scene_Map)
                },
                Proc.new{
                  @superior.cancel_dialog
                }
              )
            }
          end
        
        # Set handler for the given actor.
        set_handler(actor_symbol, proc)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Prepare Characters
  #-----------------------------------------------------------------------------
  def prepare_characters
    _y = self.y + (padding / 2)
    _height = @actors.size == 1 ? 72 : (self.height - padding)
    viewport = Viewport.new(self.x, _y, self.width, _height)
    item_id = 0
    for id in @actors
      filename = $game_actors[id].character_name
      index = $game_actors[id].character_index
      sprite = Character_Ani.new(filename, index,  viewport)
      sprite.viewport.z = self.z + 1
      sprite.x = item_rect(item_id).x + padding
      sprite.y = item_rect(item_id).y + padding
      item_id += 1
      @characters << sprite
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Draw Item
  #-----------------------------------------------------------------------------
  def draw_item(index)
    unless @characters.empty?
      m = item_height * (bottom_row - ((@actors.size - 1) / 2))
      x = item_rect(index).x + padding
      y = item_rect(index).y + padding - m
      width = @characters[index].width
      height = item_rect(index).height
      name = $game_actors[@actors[index]].name
      @characters[index].x = x
      @characters[index].y = y
      char_height = @characters[index].height
      draw_text(x + width, y - (char_height / 2) + (padding / 2) + m,
                item_rect(index).width - width - padding, height, name)
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Animate Characters
  #-----------------------------------------------------------------------------
  def animate_characters
    for char in @characters
      animate_character(char)
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Animate Character
  #-----------------------------------------------------------------------------
  def animate_character(char)
    char.update
  end
  
  #-----------------------------------------------------------------------------
  # * Item Width
  #-----------------------------------------------------------------------------
  def item_width
    super
  end
  
  #-----------------------------------------------------------------------------
  # * Item Height
  #-----------------------------------------------------------------------------
  def item_height
    super + 16
  end
  
  #-----------------------------------------------------------------------------
  # * Item Rect
  #-----------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = (index / col_max * item_height)
    rect
  end
    
  #-----------------------------------------------------------------------------
  # * Item React for Text
  #-----------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 40
    rect.width -= 80
    rect
  end
  
  #-----------------------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------------------
  def refresh
    super
    animate_characters
  end
  
  #-----------------------------------------------------------------------------
  # * Dispose
  #-----------------------------------------------------------------------------
  def terminate
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.visible = false if ivar.is_a?(Sprite)
      ivar.dispose if ivar.is_a?(Sprite)
    end
    super
  end
end

#===============================================================================
# ** Scene_PartyManager
#-------------------------------------------------------------------------------
# This class performs the party manager screen processing.
#===============================================================================

class Scene_PartyManager < Scene_MenuBase
  
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize(mode, cursor_pos = 0)
    @mode = mode
    @in_dialog = false
    @actors = []
    @ini_cursor_pos = cursor_pos
    @last_index = 0
  end
  
  #-----------------------------------------------------------------------------
  # * Start
  #-----------------------------------------------------------------------------
  def start
    @actor = PartyManager.available_actors[0]
    create_help_window
    
    case @mode
    when :add
      @help_window.set_text(Vocab::PMWhichActorAdd)
    when :rem
      @help_window.set_text(Vocab::PMWhichActorRem)
    end

    @help_window.visible = false
    
    setup
    
    unless @menu_actors.empty?
      create_main_viewport
      create_background
      @help_window.visible = true
      @command_window.set_handler(:cancel, method(:return_map))
      @command_window.select(@ini_cursor_pos)
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Return Map
  #-----------------------------------------------------------------------------
  def return_map
    SceneManager.call(Scene_Map)
  end
  
  #-----------------------------------------------------------------------------
  # * Setup
  #-----------------------------------------------------------------------------
  def setup
    party = $game_party.all_members.map {|actor| actor.id}
    case @mode
    when :add
      @menu_actors = PartyManager.available_actors - party
      msg = Vocab::PMNoneToAdd
    when :rem
      @menu_actors = 
        if party.size == 1
          []
        else
          party - PartyManager.locked_actors
        end
        
      msg = Vocab::PMNoneToRemove
    end
    
    if @menu_actors.empty?
      invoke_msg(msg)
      return_map
    else
      @command_window = Window_PMCommand.new(@menu_actors, @mode, self)
      @command_window.height = 72 if @menu_actors.size == 1
      @status_win = Window_PMStatus.new($game_actors[@menu_actors[0]])
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Actors
  #-----------------------------------------------------------------------------
  def actors
    return @command_window.actors
  end
  
  #-----------------------------------------------------------------------------
  # * Set status actor
  #-----------------------------------------------------------------------------
  def set_status_actor(actor_id)
    @status_win.actor = $game_actors[actor_id]
  end
  
  #-----------------------------------------------------------------------------
  # * Actor id from cmd
  #-----------------------------------------------------------------------------
  def actor_id_from_cmd
    @command_window.actors[@command_window.index]
  end
  
  #-----------------------------------------------------------------------------
  # * Create Dialog Background
  #-----------------------------------------------------------------------------
  def create_dialog_background
    color = Color.new(0,0,0)
    @in_dialog = true
    @dialog_bg = Sprite.new
    @dialog_bg.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @dialog_bg.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, color)
    @dialog_bg.opacity = (255 * 0.8)
    @dialog_bg.z = @dialog_window.z - 2
  end
  
  #-----------------------------------------------------------------------------
  # * Dispose Dialog Background
  #-----------------------------------------------------------------------------
  def dispose_dialog_background
    @dialog_bg.dispose unless @dialog_bg.nil?
  end
  
  #-----------------------------------------------------------------------------
  # * Open Dialog
  #-----------------------------------------------------------------------------
  def open_dialog(on_accept, on_cancel)
    @command_window.active = false
    @dialog_back = Window_PMDialogBack.new
    @dialog_window = Window_PMDialog.new(on_accept, on_cancel)
    @dialog_window.z = @command_window.z + @help_window.z + @status_win.z
    create_dialog_background
    @dialog_back.z = @dialog_bg.z + 1
  end
  
  #-----------------------------------------------------------------------------
  # * Cancel Dialog
  #-----------------------------------------------------------------------------
  def cancel_dialog
    @in_dialog = false
    @dialog_back.dispose
    @dialog_window.dispose
    @dialog_back = nil
    @dialog_window = nil
    dispose_dialog_background
    @command_window.active = true
  end
  
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  def update
    super
    @status_win.refresh unless (@command_window.index != @last_index)
    @command_window.refresh
    @dialog_back.refresh if @in_dialog
    set_status_actor(actor_id_from_cmd)
    @last_index = @command_window.index
  end
  
  #-----------------------------------------------------------------------------
  # * Invoke message
  #-----------------------------------------------------------------------------
  def invoke_msg(message)
    $game_message.face_name = ""
    $game_message.face_index = 0
    $game_message.background = 0
    $game_message.position = 2
    $game_message.add(message)
  end
  
  #-----------------------------------------------------------------------------
  # * Terminate
  #-----------------------------------------------------------------------------
  def terminate
    Graphics.freeze
    dispose_all_windows
    dispose_main_viewport if @viewport
    dispose_background if @background_sprite
  end
end
