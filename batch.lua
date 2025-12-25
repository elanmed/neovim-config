local list = {}
for i = 1, 10 do
  table.insert(list, i)
end

local Batch = {}
Batch.__index = Batch

--- @generic IterState, IterVar
--- @param iter_factory fun(): ((fun(invariant_state: IterState, control_var: IterVar):IterVar), IterState, IterVar)
function Batch:new(iter_factory)
  local this = {
    _iter_factory = iter_factory,
    _size = math.huge,
  }

  -- failed lookups on `this` (i.e. method calls) delegate to `Batch`
  -- by checking the __index of it's metatable, so we need to set
  -- `Batch`'s __index to itself
  setmetatable(this, Batch)
  return this
end

--- @param size number
function Batch:size(size)
  self._size = size
  return self
end

--- @generic T
--- @param cb fun(entry: T):nil
--- @param on_complete fun():nil
function Batch:each(cb, on_complete)
  -- local co = coroutine.create(function()
  --   local idx = 1
  --   for val in self._iter() do
  --     cb(val)
  --     if idx % self._size == 0 then
  --       coroutine.yield()
  --     end
  --     idx = idx + 1
  --   end
  -- end)
  --
  -- local step
  -- step = function()
  --   coroutine.resume(co)
  --   if coroutine.status(co) == "suspended" then
  --     vim.schedule(step)
  --   elseif coroutine.status(co) == "dead" then
  --     vim.schedule(on_complete)
  --   end
  -- end
  -- step()

  -- each time iter_fn is called, it returns the next element
  -- the closure is the iterator, the parent function is the iterator factory
  -- -- i.e. ipairs is the iterator factory
  -- calling the iterator factory returns:
  -- -- the iterator function
  -- -- the invariant state
  -- -- the initial value for the control variable
  -- the iterator function is called with: the invariant state, and the control variable
  -- -- if the first value returned by the iterator function is nil, the loop stops
  --   do
  --   local iterator_fn, invariant_state, control_var = explist
  --   while true do
  --     local var_1, ... , var_n = _f(_s, _var)
  --     control_var = var_1
  --     if control_var == nil then break end
  --     block
  --   end
  -- end

  local iter_fn, invariant_state, control_var = self._iter_factory()
  local step
  step = function()
    print "step"
    local num_processed = 0
    while num_processed < self._size do
      local values = { iter_fn(invariant_state, control_var), }
      control_var = values[1]

      if control_var == nil then
        vim.schedule(on_complete)
        return
      end

      cb(unpack(values))
      num_processed = num_processed + 1
    end
    vim.schedule(step)
  end
  step()
end

--- @param promise fun(resolve: fun():nil):nil
local await = function(promise)
  local thread = coroutine.running()
  assert(thread ~= nil, "`await` can only be called in a coroutine")
  promise(function() coroutine.resume(thread) end)
  coroutine.yield()
end

--- @param fn fun():nil
local async = function(fn)
  return function()
    local ok, err = coroutine.resume(coroutine.create(fn))
    if not ok then error(err) end
  end
end

local main = async(function()
  print "Before `await`"
  local promise = function(resolve)
    Batch
        :new(function() return ipairs(list) end)
        :size(2)
        :each(
          function(entry) print(entry) end,
          resolve
        )
  end
  await(promise)
  print "After `await`"
end)
main()
