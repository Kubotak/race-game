#! ruby -Ks

require "starruby"
include StarRuby

class Race
  attr_reader :screen_fade, :current_player

  def initialize
    @current_scene  = :start
    @current_player = 0
    @screen_fade    = 0
  end

  def get_bg_image
    return "images/#{@current_scene}.png"
  end

  def play?
    return @current_scene == :play
  end
  
  def update_check
    @keys = Input.keys(:keyboard, :duration => 1)
    send "#{@current_scene}_scene"
  end

  def start_scene
    @screen_fade += 3 if @screen_fade < 255
    if @keys.include?(:up)
      @current_scene = :play
      @screen_fade   = 255
    end
  end

  def play_scene
    @current_scene  = :end if @keys.include?(:escape)
    @current_player = (@current_player - 1) % 6 if @keys.include?(:up)
    @current_player = (@current_player + 1) % 6 if @keys.include?(:down)
  end

  def end_scene
    @screen_fade = 0 if (@screen_fade -= 3) < 0
    exit if @keys.include?(:escape)
  end
end

class Player
  attr_reader :x, :y, :w, :h, :sx, :sy

  def initialize(idx)
    @x     = 20
    @y     = 20 + idx * 70
    @w     = 64
    @h     = 64
    @sx    = 0
    @sy    = 0
    @cnt   = 0
    @image = "images/player#{idx}.png"
  end

  def get_fg_image
    return @image
  end

  def run(current_player, keys)
    if goal?
      @sy = 64
      @cnt = 0 if (@cnt += 1) == 5
    else
      @x += rand(4)
      @x = 560 if (@x += 20) > 560 if current_player && keys.include?(:right)
      @x = 0   if (@x -= 20) < 0   if current_player && keys.include?(:left)
    end
    @sx = 0 if (@sx += 64) == 192 if @cnt == 0
  end

  def goal?
    return @x > 560
  end
end

SCREEN_W = 640
SCREEN_H = 480
SCREEN_X = 0
SCREEN_Y = 0

raceGame = Race.new
players = Array.new(6) {|i| Player.new(i) }

Game.run(SCREEN_W, SCREEN_H, :title => 'レース', :fps => 30) do |game|
  game.screen.clear
  game.screen.render_texture(Texture.load(raceGame.get_bg_image), SCREEN_X, SCREEN_Y,
                             :src_width => SCREEN_W, :src_height => SCREEN_H, :alpha => raceGame.screen_fade)

  if raceGame.play?
    players.each_with_index do |player, i|
      player.run(raceGame.current_player == i, Input.keys(:keyboard, :duration => 1))
      raceGame.current_player == i ? sa = 255 :sa = 100
      game.screen.render_texture(Texture.load(player.get_fg_image), player.x, player.y,
                                 :src_x => player.sx, :src_y => player.sy,
                                 :src_width => player.w, :src_height => player.h, :saturation => sa)
    end
  end

  raceGame.update_check
end



