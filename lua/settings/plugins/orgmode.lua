local ok, orgmode = pcall(require, 'orgmode')
if not ok then
  return
end

orgmode.setup_ts_grammar()
orgmode.setup({
  org_agenda_files = { '~/Desktop/org/*' },
  org_default_notes_file = '~/Desktop/org/refile.org',
})
