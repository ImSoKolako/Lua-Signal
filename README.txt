This is simple and quick signal module allows you to create your own events!
Inspired by https://github.com/RBLXUtils/FastSignal but replaced in Lua

--CONSTRUCTOR--
signal.new() - creates a Signal object.

--Predicate--
signal.Is(any) - returns true if a passed argument is a signal, otherwise false.

--Signal Methods--
Signal:Fire(...) - fires a signal to every connected functions.
Signal:Connect(callback: (...)) - connects to each Signal:Fire(), takes a callback which is going to be called and then returns a SignalConnection
Signal:Once(callback : (...)) - connects to first Signal:Fire(), takes a callback which is going to be called and then returns a SignalConnection
Signal:Wait() - yields the thread until Signal:Fire() happens. Returns all the arguments from the Signal:Fire()
Signal:Destroy() - destroys the signal, making it inactive.
Signal:IsActive() - returns true if a Signal is active.
Signal:DisconnectAll() - disconnects every single connection to a signal.

--SignalConnection methods--
SignalConnection:Disconnect() - disconnects a connection to Signal:Fire().
