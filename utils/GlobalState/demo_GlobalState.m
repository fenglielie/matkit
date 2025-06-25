state = GlobalState.get_instance();
state.data.userName = 'Alice';
state.data.counter = 0;

fprintf('Initial user: %s\n', state.data.userName);

accessState();

fprintf('Initial counter: %d\n', state.data.counter);

incrementCounter();
incrementCounter();

fprintf('Final counter: %d\n', GlobalState.get_instance().data.counter);

function accessState()
    fprintf('Hello, %s\n', GlobalState.get_instance().data.userName);
end

function incrementCounter()
    s = GlobalState.get_instance();
    s.data.counter = s.data.counter + 1;
end
