-- My vim configs are a mess, but since I switched to hx, I haven't bothered to improve them.

-- Add additional capabilities supported by nvim-cmp
-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- local lspconfig = require('lspconfig')

-- require("copilot").setup({
--  suggestion = { enabled = false },
--  panel = { enabled = false },
-- })
-- require("copilot_cmp").setup()

-- luasnip setup
-- local luasnip = require 'luasnip'

-- nvim-cmp setup
-- local cmp = require 'cmp'
-- cmp.setup {
--   snippet = {
--     expand = function(args)
--       luasnip.lsp_expand(args.body)
--     end,
--   },
--   mapping = cmp.mapping.preset.insert({
--     ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
--     ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
--     -- C-b (back) C-f (forward) for snippet placeholder navigation.
--     ['<C-Space>'] = cmp.mapping.complete(),
--     ['<CR>'] = cmp.mapping.confirm {
--       behavior = cmp.ConfirmBehavior.Replace,
--       select = false,
--     },
--     ['<Tab>'] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_next_item()
--       elseif luasnip.expand_or_jumpable() then
--         luasnip.expand_or_jump()
--       else
--         fallback()
--       end
--     end, { 'i', 's' }),
--     ['<S-Tab>'] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_prev_item()
--       elseif luasnip.jumpable(-1) then
--         luasnip.jump(-1)
--       else
--         fallback()
--       end
--     end, { 'i', 's' }),
--   }),
--   sources = {
-- --    { name = "copilot", group_index = 2 },
--     { name = 'nvim_lsp' },
--     { name = 'luasnip' },
--   },


-- }
-- -- Haskell
-- local ht = require('haskell-tools')
-- local bufnr = vim.api.nvim_get_current_buf()
-- local opts = { noremap = true, silent = true, buffer = bufnr, }
-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
-- vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)
-- -- Hoogle search for the type signature of the definition under the cursor
-- vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
-- -- Evaluate all code snippets
-- vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
-- -- Toggle a GHCi repl for the current package
-- vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
-- -- Toggle a GHCi repl for the current buffer
-- vim.keymap.set('n', '<leader>rf', function()
--   ht.repl.toggle(vim.api.nvim_buf_get_name(0))
-- end, opts)
-- vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)

-- -- Mappings.
-- -- See `:help vim.diagnostic.*` for documentation on any of the below functions
-- local opts = { noremap=true, silent=true }
-- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- -- Use an on_attach function to only map the following keys
-- -- after the language server attaches to the current buffer
-- local on_attach = function(client, bufnr)
--   -- Enable completion triggered by <c-x><c-o>
--   vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

--   -- Mappings.
--   -- See `:help vim.lsp.*` for documentation on any of the below functions
--   local bufopts = { noremap=true, silent=true, buffer=bufnr }
--   vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
--   vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
--   vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
--   vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
--   vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
--   vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
--   vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
--   vim.keymap.set('n', '<space>wl', function()
--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--   end, bufopts)
--   vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
--   vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
--   vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
--   vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
--   vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format {
--       filter = function(client) return client.name ~= "tsserver" end,
--       async = true
--   } end, bufopts)
-- end

-- vim.g.on_attach = on_attach

-- local lsp_flags = {
--   -- This is the default in Nvim 0.7+
--   debounce_text_changes = 150,
-- }
-- require'lspconfig'.tailwindcss.setup{
--     on_attach = on_attach,
--     flags = lsp_flags,
-- }

-- require'lspconfig'.purescriptls.setup{
--     on_attach = on_attach,
--     flags = lsp_flags,
--     -- Server-specific settings...
--     settings = {
--         addSpagoSources = true -- e.g. any purescript language-server config here
--     }
-- }

-- require'lspconfig'.clangd.setup{
--     on_attach = on_attach,
--     flags = lsp_flags,
--     capabilities = capabilities
-- }

-- require('lspconfig').ruff.setup {}

-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- local null_ls = require("null-ls")
-- null_ls.setup({
--     sources = {
--         null_ls.builtins.formatting.black,
--         null_ls.builtins.formatting.purs_tidy,
--         null_ls.builtins.formatting.prettier,
--         null_ls.builtins.formatting.isort,
--         null_ls.builtins.diagnostics.ruff,
--         null_ls.builtins.diagnostics.mypy
--         -- null_ls.builtins.formatting.astyle,
--     },
--    on_attach = function(client, bufnr)
--             vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
-- --            vim.api.nvim_create_autocmd("BufWritePre", {
-- --                group = augroup,
-- --                buffer = bufnr,
-- --                callback = function()
-- --                    vim.lsp.buf.format({
-- --                    bufnr = bufnr,
-- --                    async = true,
-- --                    filter = function(client) return client.name ~= "tsserver" end,
-- --                    })
-- --                end,
-- --            })
--     end,
--     debug = true,
-- })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require'nvim-treesitter.configs'.setup {
      highlight = {
          enable = true
      }
}

require("trouble").setup {
}
-- require("typescript").setup {
    -- server = {
    --     on_attach = on_attach,
    --     }
    -- }
