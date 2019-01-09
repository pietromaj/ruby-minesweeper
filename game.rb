require "gosu"
require 'pry-byebug'
require 'pry'

load 'tile.rb'

module ZOrder
  BACKGROUND, BOUNDARIES, TILES, NUMBERS = *0..3
end


##=================##

def tile_name(i, j)
  "$tile_" + i.to_s + "_" + j.to_s
end

$mark_image = Gosu::Image.new("bomb.png")

##=================##

class Game < Gosu::Window
  GAME_SIZE = 10
  BACKGROUND_COLOR = 0xcc_aaaaaa
  NUMBER_OF_BOMBS = 10

  def initialize()
    @click = false
    @board_width = @board_height = GAME_SIZE * Tile::TILE_SIZE + GAME_SIZE * Tile::TILE_MARGIN
    super @board_width, @board_height
    generate_tiles
    generate_bombs
    generate_numbers
  end

  def assign_bomb(i, j)
    tile = eval(tile_name(i, j))
    tile.is_bomb = true
  end

  def assign_number(i, j, number)
    tile = eval(tile_name(i, j))
    tile.number = number
  end

  def calculate_bombs_around(tile)
    i = tile.position_i
    j = tile.position_j
    bomb_counter = 0
    for x in (i-1..i+1) do
      for y in (j-1..j+1) do
        if !([-1,GAME_SIZE].include? x) and !([-1,GAME_SIZE].include? y)
          neighbor_tile = eval(tile_name(x, y))
          bomb_counter += 1 if neighbor_tile.is_bomb
        end
      end
    end
    bomb_counter
  end

  def generate_bombs
    array = []
    #ARRAY OF ALL POSSIBLE TILES
    for i in (0..GAME_SIZE-1) do
      for j in (0..GAME_SIZE-1) do
        array << (i.to_s + j.to_s)
      end
    end
    
    bombs = []
    #RANDOM X NUMBER OF BOMBS PICKED FROM ARRAY
    for x in (1..NUMBER_OF_BOMBS) do
      pick = array.sample
      bombs << pick
      array = array - [pick]
    end

    #ASSIGN EACH BOMB TO HIS TILE
    for i in (0..GAME_SIZE-1) do
      for j in (0..GAME_SIZE-1) do
        if bombs.include? (i.to_s + j.to_s)
          assign_bomb(i, j)
        end
      end
    end
  end

  def generate_numbers
    for i in (0..GAME_SIZE-1) do
      for j in (0..GAME_SIZE-1) do
        tile = eval(tile_name(i, j))
        unless tile.is_bomb
         tile.number = calculate_bombs_around(tile)
        end
      end
    end
  end

  def generate_tiles
    for i in (0..GAME_SIZE) do
      for j in (0..GAME_SIZE) do
        tile = eval(tile_name(i, j) +' = Tile.new')
        tile.position_i = i
        tile.position_j = j
      end
    end
  end

  def finish
    for i in (0..GAME_SIZE-1) do
      for j in (0..GAME_SIZE-1) do
        tile = eval(tile_name(i, j))
        tile.open
      end
    end
  end

  def needs_cursor?
    true
  end

  def tile_name(i, j)
    "$tile_" + i.to_s + "_" + j.to_s
  end

  def draw
    Gosu.draw_rect(0, 0, 640, 480, BACKGROUND_COLOR, ZOrder::BACKGROUND)
    for i in (0..GAME_SIZE-1) do
      for j in (0..GAME_SIZE-1) do
        tile = eval(tile_name(i, j))
        tile ||= eval(tile_name(i, j) +' = Tile.new')
        tile.draw(i: i, j: j, z: ZOrder::TILES)
      end
    end
  end

  def button_down(id)
    detected_i = (mouse_x.to_i / (Tile::TILE_SIZE+Tile::TILE_MARGIN))
    detected_j = (mouse_y.to_i / (Tile::TILE_SIZE+Tile::TILE_MARGIN))
    tile = eval(tile_name(detected_i, detected_j))
    if tile.is_bomb
      self.finish if id == Gosu::MsLeft
    else
      tile.open if id == Gosu::MsLeft
    end

    if tile.state != 'open' and id == Gosu::MsRight
      tile.marked ? tile.unmark : tile.mark
    end
  end

  def update
  end
end

Game.new.show if __FILE__ == $0
