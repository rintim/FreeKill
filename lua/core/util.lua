-- SPDX-License-Identifier: GPL-3.0-or-later

local Util = {}

Util.DummyFunc = function() end
Util.DummyTable = setmetatable({}, {
  __newindex = function() error("Cannot assign to dummy table") end
})

local metamethods = {
  "__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm", "__idiv",
  "__band", "__bor", "__bxor", "__bnot", "__shl", "__shr",
  "__concat", "__len", "__eq", "__lt", "__le", "__call",
  -- "__index", "__newindex",
}

-- 别对类用 暂且会弄坏isSubclassOf 懒得研究先
Util.lockTable = function(t)
  local mt = getmetatable(t) or Util.DummyTable
  local new_mt = {
    __index = t,
    __newindex = function() error("Cannot assign to locked table") end,
    __metatable = false,
  }
  for _, e in ipairs(metamethods) do
    new_mt[e] = mt[e]
  end
  return setmetatable({}, new_mt)
end

function printf(fmt, ...) print(string.format(fmt, ...)) end

-- the iterator of QList object
local qlist_iterator = function(list, n)
  if n < list:length() - 1 then
    return n + 1, list:at(n + 1) -- the next element of list
  end
end

function fk.qlist(list)
  return qlist_iterator, list, -1
end

--- 对数组的每个元素执行一次给定的函数。
---@generic T
---@param self T[] @ 调用函数的数组，同时也是函数`func`中的第三个参数
---@param func fun(element: T, index: integer, array: T[]): void @ 为数组中每个元素执行的函数
---@return void
function table:forEach(func)
  for i, v in ipairs(self) do
    func(v, i, self)
  end
end

--- 测试一个数组内的所有元素是否都能通过指定函数的测试。
---@generic T
---@param self T[] @ 调用函数的数组，同时也是函数`func`中的第三个参数
---@param func fun(element: T, index: integer, array: T[]): boolean @ 为数组中的每个元素执行的函数
---@return boolean @ 如果测试函数对数组中至少一个元素返回一个`true`，则为`true`，反之为`false`
function table:every(func)
  for i, v in ipairs(self) do
    if not func(v, i, self) then
      return false
    end
  end
  return true
end

--- 测试数组中是否至少有一个元素通过了由提供的函数实现的测试。
---@generic T
---@param self T[] @ 调用函数的数组，同时也是函数`func`中的第三个参数
---@param func fun(element: T, index: integer, array: T[]): boolean @ 为数组中的每个元素执行的函数
---@return boolean @ 如果测试函数为每个数组元素返回`true`，则为`true`，反之为`false`
function table:some(func)
  for i, v in ipairs(self) do
    if func(v, i, self) then
      return true
    end
  end
  return false
end

--- 返回数组中满足提供的测试函数的第一个元素的值。
---@generic T
---@param self T[] @ 调用函数的数组，同时也是函数`func`中的第三个参数
---@param func fun(element: T, index: integer, array: T[]): boolean @ 为数组中的每个元素执行的函数
---@return T @ 数组中第一个满足所提供测试函数的元素的值，均不满足则返回`nil`
function table:find(func)
  for i, v in ipairs(self) do
    if func(v, i, self) then
      return v
    end
  end
  return nil
end

--- 创建给定数组一部分的浅拷贝，其包含通过所提供函数实现的测试的所有元素。
---@generic T
---@param self T[] @ 调用函数的数组，同时也是函数`func`中的第三个参数
---@param func fun(element: T, index: integer, array: T[]): boolean @ 为数组中的每个元素执行的函数
---@return T[] @ 满足测试函数的元素所组成的数组，均不满足则返回空数组
function table.filter(self, func)
  local ret = {}
  for i, v in ipairs(self) do
    if func(v, i, self) then
      table.insert(ret, v)
    end
  end
  return ret
end

--- 创建一个新数组，这个新数组由原数组中的每个元素都调用一次提供的函数后的返回值组成。
---@generic T
---@param self T[] @ 调用函数的数组，同时也是函数`func`中的第三个参数
---@param func fun(element: T, index: integer, array: T[]): T @ 为数组中的每个元素执行的函数
---@return T[] @ 一个新数组，每个元素都是回调函数的返回值
function table:map(func)
  local ret = {}
  for i, v in ipairs(self) do
    table.insert(ret, func(v, i, self))
  end
  return ret
end

-- frequenly used filter & map functions
Util.IdMapper = function(e) return e.id end
Util.Id2CardMapper = function(id) return Fk:getCardById(id) end
Util.Id2PlayerMapper = function(id)
  return Fk:currentRoom():getPlayerById(id)
end
Util.NameMapper = function(e) return e.name end
Util.Name2GeneralMapper = function(e) return Fk.generals[e] end
Util.Name2SkillMapper = function(e) return Fk.skills[e] end

--- 返回一个元素顺序相反的新数组。
---@generic T
---@param self T[] @ 调用函数的数组
---@return T[] @ 调用函数的数组经过反序处理后的数组
function table.reverse(self)
  local ret = {}
  for _, e in ipairs(self) do
    table.insert(ret, 1, e)
  end
  return ret
end

--- 判断数组是否包含一个指定的值。
---@generic T
---@param self T[] @ 调用函数的数组
---@param element T @ 需要查找的值
---@return boolean @ 如果数组中包含给定的值，则为`true`，反之为`false`
function table:contains(element)
  if #self == 0 then return false end
  for _, e in ipairs(self) do
    if e == element then return true end
  end
end

--- 打乱数组的元素；这会改变原数组的排序方法。
---@generic T
---@param self T[] @ 调用函数的数组
---@return void
function table:shuffle()
  for i = #self, 2, -1 do
      local j = math.random(i)
      self[i], self[j] = self[j], self[i]
  end
end

--- 添加一个元素中的所有元素。
---@generic T
---@param self T[] @ 调用函数的数组
---@param list T[] @ 需要添加的元素的数组
---@return void
function table:insertTable(list)
  for _, e in ipairs(list) do
    table.insert(self, e)
  end
end

--- 返回数组中第一次出现给定元素的下标，如果不存在则返回`-1`。
---@generic T
---@param self T[] @ 调用函数的数组
---@param value T @ 数组中要查找的元素。
---@param from integer @ 开始搜索的索引（默认为`1`）
---@return integer
function table:indexOf(value, from)
  from = from or 1
  for i = from, #self do
    if self[i] == value then return i end
  end
  return -1
end

--- 删除数组中第一次出现的给定元素；若成功删除则返回`true`，反之返回`false`。
---@generic T
---@param self T[] @ 调用函数的数组
---@param value T @ 数组中要删除的元素。
---@return boolean @ 是否进行了删除操作
function table:removeOne(element)
  if #self == 0 or type(self[1]) ~= type(element) then return false end

  for i = 1, #self do
    if self[i] == element then
      table.remove(self, i)
      return true
    end
  end
  return false
end

-- Note: only clone key and value, no metatable
-- so dont use for class or instance
--- 深拷贝一个给定的`table`。
---
--- > 注意: 该方法不拷贝元数据，故不要用于类和实例。
---@generic T, U
---@param self table<T, U> @ 调用函数的`table`
---@return table<T, U> @ 经过深拷贝的`table`
function table.clone(self)
  local ret = {}
  for k, v in pairs(self) do
    if type(v) == "table" then
      ret[k] = table.clone(v)
    else
      ret[k] = v
    end
  end
  return ret
end

-- similar to table.clone but not recursively
--- 浅拷贝一个给定的`table`。
---@generic T, U
---@param self table<T, U> @ 调用函数的`table`
---@return table<T, U> @ 经过浅拷贝的`table`
function table.simpleClone(self)
  local ret = {}
  for k, v in pairs(self) do
    ret[k] = v
  end
  return ret
end

-- similar to table.clone but not clone class/instances
--- 深拷贝一个给定的`table`，在复制过程中过滤掉其中的类和实例。
---@generic T, U
---@param self table<T, U> @ 调用函数的`table`
---@return table<T, U> @ 经过深拷贝的`table`
function table.cloneWithoutClass(self)
  local ret = {}
  for k, v in pairs(self) do
    if type(v) == "table" then
      if v.class or v.super then
        ret[k] = v
      else
        ret[k] = table.cloneWithoutClass(v)
      end
    else
      ret[k] = v
    end
  end
  return ret
end

-- if table does not contain the element, we insert it
--- 将指定的元素添加到数组的末尾，但不会添加已经存在的元素。
---@generic T
---@param self T[] @ 调用函数的数组
---@param element T @ 添加到数组末尾的元素
---@return void
function table:insertIfNeed(element)
  if not table.contains(self, element) then
    table.insert(self, element)
  end
end

--- 返回数组中随机的一个或指定个元素
---@generic T
---@param self T[] @ 调用函数的数组
---@param n integer @ 需要元素的个数
---@return T|T[] @ 当不给定个数时，返回随机的元素；当给定个数时，无论个数是否为1，都会返回随机元素的数组
function table:random(n)
  local n0 = n
  n = n or 1
  if #self == 0 then return nil end
  local tmp = {table.unpack(self)}
  local ret = {}
  while n > 0 and #tmp > 0 do
    local i = math.random(1, #tmp)
    table.insert(ret, table.remove(tmp, i))
    n = n - 1
  end
  return n0 == nil and ret[1] or ret
end

--- 返回一个新的数组对象，这一对象是一个由`begin`和`_end`决定的原数组的浅拷贝（包括`begin`，不包括`_end`），其中`begin`和`_end`代表了数组元素的索引。
---@generic T
---@param self T[] @ 调用函数的数组
---@param begin integer @ 提取起始处的索引（默认为`1`）；如果索引是负数，则从数组末尾开始计算；如果`begin >= _end`，则不提取任何元素
---@param _end integer @ 提取终止处的索引（默认为`#self + 1`）；如果索引是负数，则从数组末尾开始计算；如果`_end <= begin`，则不提取任何元素
---@return T[] @ 一个含有被提取元素的新数组
function table:slice(begin, _end)
  local len = #self
  begin = begin or 1
  _end = _end or len + 1

  if begin <= 0 then begin = len + 1 + begin end
  if _end <= 0 then _end = len + 1 + _end end
  if begin >= _end then return {} end

  local ret = {}
  for i = begin, _end - 1, 1 do
    table.insert(ret, self[i])
  end
  return ret
end

function table:assign(targetTbl)
  for key, value in pairs(targetTbl) do
    if self[key] then
      if type(value) == "table" then
        table.insertTable(self[key], value)
      else
        table.insert(self[key], value)
      end
    else
      self[key] = value
    end
  end
end

-- allow a = "Hello"; a[1] == "H"
local str_mt = getmetatable("")
str_mt.__index = function(str, k)
  if type(k) == "number" then
    if math.abs(k) > str:len() then
      error("string index out of range")
    end
    local start, _end
    if k > 0 then
      start, _end = utf8.offset(str, k), utf8.offset(str, k + 1)
    elseif k < 0 then
      local len = str:len()
      start, _end = utf8.offset(str, len + k + 1), utf8.offset(str, len + k + 2)
    else
      error("str[0] is undefined behavior")
    end
    return str:sub(start, _end - 1)
  end
  return string[k]
end

str_mt.__add = function(a, b)
  return a .. b
end

str_mt.__mul = function(a, b)
  return a:rep(b)
end

-- override default string.len
string.rawlen = string.len
function string:len()
  return utf8.len(self)
end

--- 通过搜索给定的字符串将调用函数的字符串分割成一个有序的子串列表，将这些子串放入一个数组，并返回该数组。
---@param self string @ 调用函数的字符串
---@param delimiter string @ 描述每个分割应该发生在哪里的字符串
---@return string[]
function string:split(delimiter)
  if #self == 0 then return {} end
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(self, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(self, from, delim_from - 1))
    from  = delim_to + 1
    delim_from, delim_to = string.find(self, delimiter, from)
  end
  table.insert(result, string.sub(self, from))
  return result
end

--- 判断字符串的开头是否为给定的字符串
---@param self string @ 调用函数的字符串
---@param start string @ 给定的字符串
---@return boolean @ 如果字符串的开头是给定的字符串，则为`true`，反之为`false`
function string:startsWith(start)
  return self:sub(1, #start) == start
end

--- 判断字符串的结尾是否为给定的字符串（字符串均可认定为以空结尾）
---@param self string @ 调用函数的字符串
---@param e string @ 给定的字符串
---@return boolean @ 如果字符串的结尾是给定的字符串，则为`true`，反之为`false`
function string:endsWith(e)
  return e == "" or self:sub(-#e) == e
end

---@class Sql
Sql = {
  ---@param filename string
  open = function(filename)
    return fk.OpenDatabase(filename)
  end,

  ---@param db fk.SQLite3
  close = function(db)
    fk.CloseDatabase(db)
  end,

  --- Execute an SQL statement.
  ---@param db fk.SQLite3
  ---@param sql string
  exec = function(db, sql)
    fk.ExecSQL(db, sql)
  end,

  --- Execute a `SELECT` SQL statement.
  ---@param db fk.SQLite3
  ---@param sql string
  ---@return table[] @ Array of Json object, the key is column name and value is row value
  exec_select = function(db, sql)
    return json.decode(fk.SelectFromDb(db, sql))
  end,
}

FileIO = {
  pwd = fk.QmlBackend_pwd,
  ls = function(filename)
    if filename == nil then
      return fk.QmlBackend_ls(".")
    else
      return fk.QmlBackend_ls(filename)
    end
  end,
  cd = fk.QmlBackend_cd,
  exists = fk.QmlBackend_exists,
  isDir = fk.QmlBackend_isDir
}

os.getms = fk.GetMicroSecond

---@class Stack : Object
Stack = class("Stack")
function Stack:initialize()
  self.t = {}
  self.p = 0
end

function Stack:push(e)
  self.p = self.p + 1
  self.t[self.p] = e
end

function Stack:isEmpty()
  return self.p == 0
end

function Stack:pop()
  if self.p == 0 then return nil end
  self.p = self.p - 1
  return self.t[self.p + 1]
end


--- useful function to create enums
---
--- only use it in a terminal
---@param table string
---@param enum string[]
function CreateEnum(table, enum)
  local enum_format = "%s.%s = %d"
  for i, v in ipairs(enum) do
    print(string.format(enum_format, table, v, i))
  end
end

function switch(param, case_table)
  local case = case_table[param]
  if case then return case() end
  local def = case_table["default"]
  return def and def() or nil
end

---@class TargetGroup : Object
local TargetGroup = {}

function TargetGroup:getRealTargets(targetGroup)
  if not targetGroup then
    return {}
  end

  local realTargets = {}
  for _, targets in ipairs(targetGroup) do
    table.insert(realTargets, targets[1])
  end

  return realTargets
end

function TargetGroup:includeRealTargets(targetGroup, playerId)
  if not targetGroup then
    return false
  end

  for _, targets in ipairs(targetGroup) do
    if targets[1] == playerId then
      return true
    end
  end

  return false
end

function TargetGroup:removeTarget(targetGroup, playerId)
  if not targetGroup then
    return
  end

  for index, targets in ipairs(targetGroup) do
    if (targets[1] == playerId) then
      table.remove(targetGroup, index)
      return
    end
  end
end

function TargetGroup:pushTargets(targetGroup, playerIds)
  if not targetGroup then
    return
  end

  if type(playerIds) == "table" then
    table.insert(targetGroup, playerIds)
  elseif type(playerIds) == "number" then
    table.insert(targetGroup, { playerIds })
  end
end

---@class AimGroup : Object
local AimGroup = {}

AimGroup.Undone = 1
AimGroup.Done = 2
AimGroup.Cancelled = 3

function AimGroup:initAimGroup(playerIds)
  return { [AimGroup.Undone] = playerIds, [AimGroup.Done] = {}, [AimGroup.Cancelled] = {} }
end

function AimGroup:getAllTargets(aimGroup)
  local targets = {}
  table.insertTable(targets, aimGroup[AimGroup.Undone])
  table.insertTable(targets, aimGroup[AimGroup.Done])
  return targets
end

function AimGroup:getUndoneOrDoneTargets(aimGroup, done)
  return done and aimGroup[AimGroup.Done] or aimGroup[AimGroup.Undone]
end

function AimGroup:setTargetDone(aimGroup, playerId)
  local index = table.indexOf(aimGroup[AimGroup.Undone], playerId)
  if index ~= -1 then
    table.remove(aimGroup[AimGroup.Undone], index)
    table.insert(aimGroup[AimGroup.Done], playerId)
  end
end

function AimGroup:addTargets(room, aimEvent, playerIds)
  local playerId = type(playerIds) == "table" and playerIds[1] or playerIds
  table.insert(aimEvent.tos[AimGroup.Undone], playerId)

  if type(playerIds) == "table" then
    for i = 2, #playerIds do
      aimEvent.subTargets = aimEvent.subTargets or {}
      table.insert(aimEvent.subTargets, playerIds[i])
    end
  end

  room:sortPlayersByAction(aimEvent.tos[AimGroup.Undone])
  if aimEvent.targetGroup then
    TargetGroup:pushTargets(aimEvent.targetGroup, playerIds)
  end
end

function AimGroup:cancelTarget(aimEvent, playerId)
  local cancelled = false
  for status = AimGroup.Undone, AimGroup.Done do
    local indexList = {}
    for index, pId in ipairs(aimEvent.tos[status]) do
      if pId == playerId then
        table.insert(indexList, index)
      end
    end

    if #indexList > 0 then
      cancelled = true
      for i = 1, #indexList do
        table.remove(aimEvent.tos[status], indexList[i])
      end
    end
  end

  if cancelled then
    table.insert(aimEvent.tos[AimGroup.Cancelled], playerId)
    if aimEvent.targetGroup then
      TargetGroup:removeTarget(aimEvent.targetGroup, playerId)
    end
  end
end

function AimGroup:removeDeadTargets(room, aimEvent)
  for index = AimGroup.Undone, AimGroup.Done do
    aimEvent.tos[index] = room:deadPlayerFilter(aimEvent.tos[index])
  end

  if aimEvent.targetGroup then
    local targets = TargetGroup:getRealTargets(aimEvent.targetGroup)
    for _, target in ipairs(targets) do
      if not room:getPlayerById(target):isAlive() then
        TargetGroup:removeTarget(aimEvent.targetGroup, target)
      end
    end
  end
end

function AimGroup:getCancelledTargets(aimGroup)
  return aimGroup[AimGroup.Cancelled]
end

return { TargetGroup, AimGroup, Util }
