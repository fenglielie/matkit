state = GlobalState.getInstance();
state.data.userName = 'Alice';
state.data.counter = 0;

fprintf('Initial user: %s\n', state.data.userName);

accessState();

fprintf('Initial counter: %d\n', state.data.counter);

incrementCounter();
incrementCounter();

fprintf('Final counter: %d\n', GlobalState.getInstance().data.counter);

function accessState()
    fprintf('Hello, %s\n', GlobalState.getInstance().data.userName);
end

function incrementCounter()
    s = GlobalState.getInstance();
    s.data.counter = s.data.counter + 1;
end
