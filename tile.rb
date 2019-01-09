class Tile
  TILE_SIZE = 24
  TILE_COLOR = 0xcc_cccccc
  TILE_MARGIN = 2
  OPENED_COLOR = 0xcc_999999

  attr_accessor :size, :color, :position_i, :position_j, :state, :is_bomb, :number, :opened_around, :marked

  def initialize
    self.size = TILE_SIZE
    self.color = TILE_COLOR
    self.state = "closed"
    self.is_bomb = false
  end

  def number_color(number)
    case number
      when 1
        0xcc_2244ff
      when 2
        0xcc_22ffff
      when 3
        0xcc_ff2211
      when 4
        0xcc_dd0402
      else
        0xcc_880000
    end
  end

  def opened_color
    self.is_bomb ? 0xcc_ff0000 : Tile::OPENED_COLOR
  end

  def open
    self.state = "open"
    self.color = opened_color
    self.open_around if self.number == 0 and !self.opened_around
  end

  def open_around
    self.opened_around = true
    i = self.position_i
    j = self.position_j
    for x in (i-1..i+1) do
      for y in (j-1..j+1) do
        if !([-1, Game::GAME_SIZE].include? x) and !([-1, Game::GAME_SIZE].include? y)
          neighbor_tile = eval(tile_name(x, y))
          neighbor_tile.open if !neighbor_tile.is_bomb and neighbor_tile.state != 'opened'
        end
      end
    end
  end

  def mark
    self.marked = true
  end

  def unmark
    self.marked = false
  end

  def tile_name(i, j)
    "$tile_" + i.to_s + "_" + j.to_s
  end

  def draw(i: self.position_i, j: self.position_j, z: ZOrder::TILES)
    self.position_i ||= i
    self.position_j ||= j
    tile_margin_factor = tmf = TILE_MARGIN
    x = (i*self.size+(tmf*i))
    y = (j*self.size+(tmf*j))
    Gosu.draw_rect(x, y, self.size, self.size, self.color, z)
    if self.state == "open" and self.number != 0
      @text = Gosu::Image.from_text self.number, 20
      @text.draw x+Tile::TILE_SIZE/4, y+Tile::TILE_SIZE/4-2, 3, 1, 1, number_color(self.number)
    end

    if self.state != 'open' and self.marked
      $mark_image.draw(x+Tile::TILE_SIZE/4, y+Tile::TILE_SIZE/4-2, 3, 0.1, 0.1)
    end

  end
end