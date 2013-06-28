$ = Zepto
h = 12
w = 10
speed = 500
 
field = null
 
log = (obj) -> console.log JSON.stringify obj
 
reset = ->
  field = for i in [1..h]
    for j in [1..w]
      0
 
symbols = ['.', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']
div = $('.field')
info = $('.info')
render = ->
  div.empty()
  for row, y in field
    for cell, x in row
      for c in current
        if c.x == x and c.y == y
          cell = c.e
      div.append symbols[cell]
    div.append '<br>'
  ss = ( symbols[i] for i in [1..unlocked] )
  info.text "Unlocked bricks: #{ss.join(', ')}"
 
rand = (n) -> Math.floor Math.random()*n
 
set = (pos, val) ->
  if pos.y >= 0
    field[pos.y][pos.x] = val
 
current = null
unlocked = 3
newBrick = ->
  current = ({ x: w/2, y: i, e: rand(unlocked)+1 } for i in [-1..0])
  render()
  checkEnd()
 
isValid = (x, y) ->
  x >= 0 && x < w && y < h && (y < 0 || field[y][x] == 0)
 
move = (dir) ->
  canMove = true
  for c in current
    newx = c.x + dir
    unless isValid newx, c.y
      canMove = false
 
  if canMove
    for c in current
      c.x = c.x + dir
    render()
 
canFall = ->
  for c in current
    unless isValid c.x, c.y + 1
      return false
  true
 
commit = ->
  for c in current
    set c, c.e
 
checkMerge = ->
  merged = false
  for row, y in field
    for cell, x in row
      continue if cell == 0
      area = getArea x, y, cell
      if area.length >= 3
        mergeArea area
        merged = true
  if merged
    setTimeout ->
      render()
      checkFall()
    , 200
 
getArea = (x, y, el, acc = [], acc2 = [], i = 0) ->
  return if i > 50
  key = "#{x},#{y}"
  if acc2.indexOf(key) == -1 && x >= 0 && x < w && y >= 0 && y < h && field[y][x] == el
    acc.push [x, y]
    acc2.push key
    getArea x, y-1, el, acc, acc2, i+1
    getArea x-1, y, el, acc, acc2, i+1
    getArea x+1, y, el, acc, acc2, i+1
    getArea x, y+1, el, acc, acc2, i+1
  acc
 
mergeArea = (area) ->
  last = area.pop()
  for [x, y] in area
    field[y][x] = 0
  [x, y] = last
  field[y][x] += 1
  unlocked = field[y][x] if field[y][x] > unlocked
  # start from beginning if overflow
  field[y][x] = 1 if field[y][x] >= symbols.length
 
transpose = (arr) ->
  for i in [1..arr[0].length]
    for j in [1..arr.length]
      arr[j-1][i-1]
 
checkFall = (merge = false) ->
  falled = merge
  transp = transpose field
  for col, x in transp
    newCol = []
    start = null
    for cell, y in col
      if cell > 0
        start = y if start == null
        newCol.push cell
    need = col.length - newCol.length
    if need > 0
      if col.length - start > newCol.length
        falled = true
      for i in [1..need]
        newCol.unshift 0
      transp[x] = newCol
  field = transpose transp
 
  if falled
    setTimeout ->
      render()
      checkMerge()
    , 200
 
fall = ->
  if canFall()
    for c in current
      c.y += 1
    render()
  if !canFall()
    commit()
    render()
    checkFall true
    newBrick()
  mloop = setTimeout fall, speed
 
rotate = ->
  c = current[0]
  c2 = current[1]
  if c.y == c2.y
    newy = c.y + c2.x - c.x
    newx = c2.x
  else
    newx = c.x - c2.y + c.y
    newy = c2.y
  if isValid newx, newy
    c.x = newx
    c.y = newy
    render()
 
$(".left").tap -> move -1
$(".right").tap -> move 1
$(".turn").tap -> rotate()
 
mloop = null
 
checkEnd = ->
  if !canFall()
    isEnd = false
    for c in current
      if c.y <= 0
        isEnd = true
    if isEnd
      clearTimeout mloop
      $(".status").text('Game Over!')
 
$(".start").tap ->
  clearTimeout mloop if mloop
  $(".status").empty()
  reset()
  newBrick()
  mloop = setTimeout fall, speed
 
$(".stop").tap ->
  clearTimeout mloop if mloop
