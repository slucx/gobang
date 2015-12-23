-- @description gobang
-- @author slucx
-- @release 0.1

local math = math
local table = table
local love = love

-- 数据
local gobang = {}

-- 画布大小
gobang.max = {
  x = 90,
  y = 50,
}
-- 单元格像素值
gobang.unit_size = 15           -- 最小10, 再小了你也看不见
-- 宽度像素值
gobang.w = gobang.max.x * gobang.unit_size
-- 高度像素值
gobang.h = gobang.max.y * gobang.unit_size
-- 棋盘 0<=x<gobang.max.x 0<=y<gobang.max.y
gobang.used = 0
gobang.stat = {}            -- 标记下过的位置, {x = {y = player}}
-- 玩家
gobang.color = {                -- 任意添加，每种颜色代表一个玩家
  { 255, 0, 0, 128 },    -- 玩家1的棋子颜色
  { 0, 0, 255, 128 },    -- 玩家2的骑子颜色
  { 0, 255, 0, 128 },    -- 玩家3的骑子颜色
}
gobang.max_player = #gobang.color           -- 最多几个人玩
gobang.last_player = 0
gobang.player = 1               -- 当前玩家(1/2)
-- 连续几个子算赢
gobang.win_cnt = 6
-- 时间管理
gobang.time = {
  time = 0,
  timeout = 3,
}
-- flags
gobang.flags = {}
gobang.flags.game_over = false

----------------------------------------
function gobang:append(x, y)
  if self.flags.game_over then return end

  x = math.floor(x / self.unit_size)
  y = math.floor(y / self.unit_size)

  print(x, y)
  if self.stat[x] and self.stat[x][y] then
    return
  end

  if not self.stat[x] then self.stat[x] = {} end
  self.stat[x][y] = self.player

  self.used = self.used + 1
  self.last_player = self.player
  self.player = self.player + 1
  if self.player > self.max_player then
    self.player = 1
  end
end

-- 检测算法
function gobang:check_base(x, y, p)
  if x < 0 or x >= self.max.x then return false end
  if y < 0 or y >= self.max.y then return false end
  if not self.stat[x] then return false  end

  return self.stat[x][y] == p
end

function gobang:check()
  if self.used >= self.max.x * self.max.y then
    -- 棋盘已经用完，和棋
    self.last_player = 0
    self.flags.game_over = true
    return
  end

  for x, v in pairs(self.stat) do
    for y, p in pairs(v) do  -- (x, y, p)
      local cnt = 1

      -- 左右
      for i=1, self.win_cnt - 1 do
        if self:check_base(x-i, y, p) then
          cnt = cnt + 1
        else
          break
        end
      end
      for i=1, self.win_cnt - 1 do
        if self:check_base(x+i, y, p) then
          cnt = cnt + 1
        else
          break
        end
      end

      if cnt >= self.win_cnt then
        self.flags.game_over = true
        return
      else
        cnt = 1
      end

      -- 上下
      for i=1, self.win_cnt - 1 do
        if self:check_base(x, y-i, p) then
          cnt = cnt + 1
        else
          break
        end
      end
      for i=1, self.win_cnt - 1 do
        if self:check_base(x, y+i, p) then
          cnt = cnt + 1
        else
          break
        end
      end

      if cnt >= self.win_cnt then
        self.flags.game_over = true
        return
      else
        cnt = 1
      end

      -- 左上右下
      for i=1, self.win_cnt - 1 do
        if self:check_base(x-i, y-i, p) then
          cnt = cnt + 1
        else
          break
        end
      end
      for i=1, self.win_cnt - 1 do
        if self:check_base(x+i, y+i, p) then
          cnt = cnt + 1
        else
          break
        end
      end

      if cnt >= self.win_cnt then
        self.flags.game_over = true
        return
      else
        cnt = 1
      end

      -- 左下右上
      for i=1, self.win_cnt - 1 do
        if self:check_base(x-i, y+i, p) then
          cnt = cnt + 1
        else
          break
        end
      end
      for i=1, self.win_cnt - 1 do
        if self:check_base(x+i, y-i, p) then
          cnt = cnt + 1
        else
          break
        end
      end

      if cnt >= self.win_cnt then
        self.flags.game_over = true
        return
      else
        cnt = 1
      end
    end
  end
end

----------------------------------------

-- interfaces
function love.load()
  love.window.setTitle("GoBang")
  love.window.setMode(gobang.w, gobang.h)
  love.graphics.setFont(love.graphics.newFont(20))
  love.graphics.setBackgroundColor(255, 255, 255, 255)
  love.graphics.setLineStyle("smooth")
  love.graphics.setLineWidth(0.1)
end

function love.draw()
  love.graphics.setColor(0, 0, 0, 10)

  local size = gobang.unit_size
  local weight = gobang.w
  local high = gobang.h

  -- 横线
  for i=0, high, size do
    love.graphics.line(0, i, weight, i)
  end

  -- 竖线
  for i=0, weight, size do
    love.graphics.line(i, 0, i, high)
  end

  -- 棋子状态
  for x, v in pairs(gobang.stat) do
    for y, p in pairs(v) do
      love.graphics.setColor(gobang.color[p])
      love.graphics.rectangle("fill",
                              x * gobang.unit_size + 1,
                              y * gobang.unit_size + 1,
                              gobang.unit_size - 2,
                              gobang.unit_size - 2)
    end
  end

  -- 游戏是否结束
  if gobang.flags.game_over then
    love.graphics.setColor(255,0,0,255)
    if gobang.last_player ~= 0 then
      love.graphics.print(
        "Game Over, " .. gobang.last_player .. " Win",
        gobang.w/2 - gobang.unit_size * 2,
        gobang.h/2
      )
    else
      love.graphics.print(
        "No one Win!!!!!",
        gobang.w/2 - gobang.unit_size * 2,
        gobang.h/2
      )
    end
    love.graphics.print(
      "Any keys exit!!!!",
      gobang.w/2 - gobang.unit_size * 2,
      gobang.h/2 + gobang.unit_size *2
    )
  end
end

function love.update(dt)
  gobang.time.time = gobang.time.time + dt
  if gobang.time.time > gobang.time.timeout then
  end

  gobang:check()
end

function love.mousepressed(x, y)
  gobang:append(x, y)
end

function love.keypressed(k)
  if gobang.flags.game_over then
    love.event.quit()
  end
end

