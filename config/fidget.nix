{lib, ...}: {
  plugins.fidget = {
    enable = true;
    settings = {
      notification = {
        window = {
          winblend = 0;
        };
      };
      progress = {
        display = {
          done_icon = "";
          done_ttl = 5;
          format_message = lib.nixvim.mkRaw ''
            function(msg)
              if string.find(msg.title, "Indexing") then
                return nil -- Ignore \"Indexing...\" progress messages
              end
              if msg.message then
                return msg.message
              else
                return msg.done and "Completed" or "In progress..."
              end
            end
          '';
        };
      };
      text = {
        spinner = "dots";
      };
    };
  };

  extraConfigLua = ''
    local code_companion = {}

    function code_companion.start_fidget()
        local has_fidget, fidget = pcall(require, "fidget")
        if not has_fidget then
            return
        end

        if code_companion.fidget_progress_handle then
            code_companion.fidget_progress_handle.message = "Abort."
            code_companion.fidget_progress_handle:cancel()
            code_companion.fidget_progress_handle = nil
        end

        code_companion.fidget_progress_handle = fidget.progress.handle.create({
            title = "",
            message = "Thinking...",
            lsp_client = { name = "CodeCompanion" },
        })
    end

    function code_companion.stop_fidget()
        local has_fidget, _ = pcall(require, "fidget")
        if not has_fidget then
            return
        end

        if code_companion.fidget_progress_handle then
            code_companion.fidget_progress_handle.message = "Done."
            code_companion.fidget_progress_handle:finish()
            code_companion.fidget_progress_handle = nil
        end
    end

    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = { "CodeCompanionRequestStarted", "CodeCompanionRequestFinished" },
        group = group,
        callback = function(event)
            if event.match == "CodeCompanionRequestStarted" then
                code_companion.start_fidget()
            elseif event.match == "CodeCompanionRequestFinished" then
                code_companion.stop_fidget()
            end
        end,
    })
  '';
}
# local M = {}
#
# function M.start_fidget()
#     local has_fidget, fidget = pcall(require, "fidget")
#     if not has_fidget then
#         return
#     end
#
#     if M.fidget_progress_handle then
#         M.fidget_progress_handle.message = "Abort."
#         M.fidget_progress_handle:cancel()
#         M.fidget_progress_handle = nil
#     end
#
#     M.fidget_progress_handle = fidget.progress.handle.create({
#         title = "",
#         message = "Thinking...",
#         lsp_client = { name = "CodeCompanion" },
#     })
# end
#
# function M.stop_fidget()
#     local has_fidget, _ = pcall(require, "fidget")
#     if not has_fidget then
#         return
#     end
#
#     if M.fidget_progress_handle then
#         M.fidget_progress_handle.message = "Done."
#         M.fidget_progress_handle:finish()
#         M.fidget_progress_handle = nil
#     end
# end
#
# function M.setup_fidget()
#     local has_fidget, _ = pcall(require, "fidget")
#     if has_fidget then
#         -- New AU group:
#         local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
#
#         -- Attach:
#         vim.api.nvim_create_autocmd({ "User" }, {
#             pattern = "CodeCompanionRequest*",
#             group = group,
#             callback = function(request)
#                 if request.match == "CodeCompanionRequestStarted" then
#                     M.start_req_fidget()
#                 elseif request.match == "CodeCompanionRequestFinished" then
#                     M.stop_req_fidget()
#                 end
#             end,
#         })
#     end
# end
#
# return M

