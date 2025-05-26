local ScriptSignal = {}
ScriptSignal.__index = ScriptSignal

local ScriptConnection = {}
ScriptConnection.__index = ScriptConnection

function ScriptSignal.new()
	return setmetatable({
		_active = true,
		_head = nil
	}, ScriptSignal)
end

function ScriptSignal.Is(object)
	return typeof(object)=='table'
		and getmetatable(object)==ScriptSignal
end

function ScriptSignal:IsActive()
	return self._active
end

function ScriptSignal:Connect(handler)
	assert(
		type(handler) == 'function',
		"Must be function"
	)

	if self._active ~= true then
		return setmetatable({
			Connected = false,
			_node = nil
		}, ScriptConnection)
	end

	local _head = self._head

	local node = {
		_signal = self,
		_connection = nil,
		_handler = handler,

		_next = _head,
		_prev = nil
	}

	if _head then
		_head._prev=node
	end

	self._head = node

	local connection = setmetatable({
		Connected = true,
		_node = node
	}, ScriptConnection)

	node._connection = connection

	return connection
end

function ScriptSignal:Once(handler)
	assert(
		type(handler) == 'function',
		"Must be function"
	)

	local connection
	connection = self:Connect(function(...)
		if connection == nil then
			return
		end

		connection:Disconnect()
		connection = nil

		handler(...)
	end)

	return connection
end
ScriptSignal.ConnectOnce = ScriptSignal.Once

function ScriptSignal:Wait()
	local thread do
		thread = coroutine.running()

		local connection
		connection = self:Once(function(...)
			if connection == nil then
				return
			end
			if coroutine.status(thread) == "suspended" then
				coroutine.resume(thread,...)
			end
		end)
	end

	return coroutine.yield()
end

function ScriptSignal:Fire(...)
	local node = self._head
	while node do
		coroutine.wrap(node._handler)(...)

		node = node._next
	end
end

function ScriptSignal:DisconnectAll()
	local node = self._head
	while node do
		local _connection = node._connection

		if _connection then
			_connection.Connected = false
			_connection._node = nil
			node._connection = nil
		end

		node = node._next
	end

	self._head = nil
end

function ScriptSignal:Destroy()
	if self._active ~= true then
		return
	end

	self:DisconnectAll()
	self._active = false
end

function ScriptConnection:Disconnect()
	if self.Connected ~= true then
		return
	end

	self.Connected = false

	local _node = self._node
	local _prev = _node._prev
	local _next = _node._next

	if _next then
		_next._prev = _prev
	end

	if _prev then
		_prev._next = _next
	else
		_node._signal._head = _next
	end

	_node._connection = nil
	self._node = nil
end

return ScriptSignal
