local stub = require("luassert.stub")

local s = require("null-ls.state")

describe("state", function()
    local mock_client_id = 1234
    local mock_action_stub = stub.new()
    local mock_action = {
        title = "Mock action",
        -- need to wrap to pass validation
        action = function() mock_action_stub() end
    }

    after_each(function()
        mock_action_stub:clear()
        s.reset()
    end)

    describe("get", function()
        it("should get initial state", function()
            local state = s.get()

            assert.equals(state.client_id, nil)
            assert.same(state.actions, {})
        end)

        it("should get updated state", function()
            s.set({mock_key = "mock_val"})

            assert.equals(s.get().mock_key, "mock_val")
        end)
    end)

    describe("reset", function()
        it("should reset state to initial state", function()
            s.set({client_id = mock_client_id})

            s.reset()
            local state = s.get()

            assert.equals(state.client_id, nil)
            assert.same(state.actions, {})
        end)
    end)

    describe("set_client_id", function()
        it("should set state client_id", function()
            s.set_client_id(mock_client_id)

            assert.equals(s.get().client_id, mock_client_id)
        end)
    end)

    describe("stop_client", function()
        stub(vim.lsp, "stop_client")

        before_each(function() s.set({client_id = mock_client_id}) end)
        after_each(function() vim.lsp.stop_client:clear() end)

        it("should call stop_client with state client_id", function()
            s.stop_client()

            assert.stub(vim.lsp.stop_client).was_called_with(mock_client_id)
        end)

        it("should reset state", function()
            s.stop_client()

            assert.equals(s.get().client_id, nil)
        end)
    end)

    describe("push_action", function()
        it("should assign actions to state.actions[title]", function()
            s.push_action(mock_action)

            assert.equals(s.get().actions[mock_action.title], mock_action.action)
        end)
    end)

    describe("run_action", function()
        before_each(function() s.push_action(mock_action) end)

        it("should run action matching title", function()
            s.run_action(mock_action.title)

            assert.stub(mock_action_stub).was_called()
        end)
    end)

    describe("clear_actions", function()
        it("should clear state actions", function()
            s.push_action(mock_action)

            s.clear_actions()

            assert.equals(s.get().actions[mock_action.title], nil)
        end)
    end)
end)