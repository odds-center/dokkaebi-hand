--- 경량 이벤트/시그널 시스템 (C# event Action<T> 대체)
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _listeners = {} }, Signal)
end

function Signal:connect(fn)
    table.insert(self._listeners, fn)
    return fn  -- disconnect용 참조 반환
end

function Signal:disconnect(fn)
    for i, listener in ipairs(self._listeners) do
        if listener == fn then
            table.remove(self._listeners, i)
            return true
        end
    end
    return false
end

function Signal:emit(...)
    for _, fn in ipairs(self._listeners) do
        fn(...)
    end
end

function Signal:clear()
    self._listeners = {}
end

return Signal
